import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;

  final TextEditingController _controller = TextEditingController();
  String receivedMessage = "";
  final List<Map<String, dynamic>> messages = [];
  Map<String, dynamic>? assignedDriver;
  bool isSocketConnected = false; // Added to track socket connection status

  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _connectSocket();
  }

  void _connectSocket() {
    const socketUrl = 'http://192.168.1.43:4567'; // Change to your backend URL

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.on('connect', (_) {
      setState(() {
        isSocketConnected = true;
      });
      log('Socket connected');
      Fluttertoast.showToast(msg: "Socket connected");
      socket.on('user:driver_assigned', _handleAssigned);
      socket.on('receive_message', _handleReceivedMessage);
    });

    socket.on('disconnect', (_) {
      setState(() {
        isSocketConnected = false;
      });
      log('Socket disconnected');
      Fluttertoast.showToast(msg: "Socket disconnected");
    });

    socket.on('receive_message', (data) {
      if (!mounted) return;
      log('📩 Message received: $data');

      final messageText = data is Map && data.containsKey('message')
          ? data['message']
          : data.toString();

      setState(() {
        messages.add({'text': messageText, 'isMine': false});
      });
    });

    socket.onConnectError((data) {
      log('⚠️ Connection Error: $data');
    });
  }

  void _handleAssigned(dynamic data) {
    log('🚗 Driver Assigned: $data');

    final driverName = data['name'] ?? 'Unknown';
    final driverPhone = data['phone'] ?? 'N/A';

    Fluttertoast.showToast(
      msg: "Driver Assigned: $driverName ($driverPhone)",
      toastLength: Toast.LENGTH_LONG,
    );

    setState(() {
      assignedDriver = data;
    });
  }

  void _handleReceivedMessage(dynamic data) {
    if (!mounted) return;

    log('📩 Message received: $data');

    final messageText = data is Map && data.containsKey('message')
        ? data['message']
        : data.toString();

    setState(() {
      messages.add({'text': messageText, 'isMine': false});
    });
  }

  void _sendMessage() {
    if (!isSocketConnected) {
      Fluttertoast.showToast(msg: "Socket not connected!");
      return;
    }

    if (_controller.text.trim().isEmpty) return;

    final message = _controller.text.trim();

    // Send to server
    socket.emit('send_message', {'message': message});
    log('📤 Sent message: $message');

    setState(() {
      messages.add({'text': message, 'isMine': true});
    });

    _controller.clear();
  }

  @override
  void dispose() {
    socket.off('receive_message', _handleReceivedMessage);
    socket.off('user:driver_assigned', _handleAssigned);
    socket.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permission permanently denied. Please enable it from settings.",
          ),
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      body: _currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng!,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  top: 40.h,
                  left: 20.w,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Color(0xFFFFFFFF),
                    shape: CircleBorder(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF1D3557),
                      ),
                    ),
                  ),
                ),

                // Bottom Sheet
                DraggableScrollableSheet(
                  initialChildSize: 0.45,
                  minChildSize: 0.25,
                  maxChildSize: 0.75,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        children: [
                          Center(
                            child: Container(
                              width: 40.w,
                              height: 5.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),

                          /// DRIVER DETAILS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Your driver is arriving",
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  "2 min",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 25.r,
                                backgroundImage: AssetImage(
                                  "assets/driver.png",
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "John Smith",
                                    style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "Black Suzuki S-Presso LXI",
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      color: Colors.grey[700],
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16.sp,
                                      ),
                                      Text(
                                        "4.9",
                                        style: GoogleFonts.inter(
                                          fontSize: 13.sp,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "KA15AK0000",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "MH Registered",
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          Divider(),

                          /// PICKUP - DROP DETAILS
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.my_location,
                                color: Colors.green,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  "562/11-A, Kaikondrahalli, Bengaluru",
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on, color: Colors.red),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  "MG Road Metro, Bengaluru",
                                  style: GoogleFonts.inter(fontSize: 13.sp),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          Divider(),

                          /// PAYMENT DETAILS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Payment Method",
                                style: GoogleFonts.inter(fontSize: 14.sp),
                              ),
                              Text(
                                "Cash",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Estimated Fare",
                                style: GoogleFonts.inter(fontSize: 14.sp),
                              ),
                              Text(
                                "₹120",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          Divider(),
                          SizedBox(height: 20.h),
                          Text(
                            "Received Message:",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          messages.isEmpty
                              ? const Center(child: Text("No messages yet"))
                              : SingleChildScrollView(
                                  child: ListView.builder(
                                    padding: EdgeInsets.all(16.w),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      final msg = messages[index];
                                      final isMine = msg['isMine'] as bool;
                                      return Align(
                                        alignment: isMine
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                            vertical: 6.h,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14.w,
                                            vertical: 10.h,
                                          ),
                                          constraints: BoxConstraints(
                                            maxWidth: 250.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isMine
                                                ? Colors.blueAccent
                                                : Colors.grey.shade300,
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(
                                                16,
                                              ),
                                              topRight: const Radius.circular(
                                                16,
                                              ),
                                              bottomLeft: Radius.circular(
                                                isMine ? 16 : 0,
                                              ),
                                              bottomRight: Radius.circular(
                                                isMine ? 0 : 16,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            msg['text'],
                                            style: GoogleFonts.inter(
                                              fontSize: 14.sp,
                                              color: isMine
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          Container(
                            margin: EdgeInsets.only(top: 15.h, bottom: 20.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEDEF),
                              borderRadius: BorderRadius.circular(40.r),
                            ),
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: "Send a message to your driver...",
                                hintStyle: GoogleFonts.inter(fontSize: 12.sp),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 12.h,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.send, color: Colors.black),
                                  onPressed: _sendMessage,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              actionButton(
                                "assets/SvgImage/safety.svg",
                                "Safety",
                              ),
                              actionButton(
                                "assets/SvgImage/share.svg",
                                "Share Trip",
                              ),
                              actionButton("assets/SvgImage/calld.svg", "Call"),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          /// BOTTOM BUTTONS
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel Ride",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  child: Text(
                                    "Help",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget actionButton(String icon, String label) {
    return Column(
      children: [
        Container(
          width: 45.w,
          height: 45.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEEEDEF),
          ),
          child: Center(
            child: SvgPicture.asset(icon, width: 18.w, height: 18.h),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.black),
        ),
      ],
    );
  }
}
