import 'dart:developer';

import 'package:delivery_mvp_app/CustomerScreen/selectTrip.screen.dart';
import 'package:delivery_mvp_app/data/Model/getDistanceBodyModel.dart';
import 'package:delivery_mvp_app/data/controller/getDistanceController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:hive_flutter/adapters.dart';

class InstantDeliveryScreen extends ConsumerStatefulWidget {
  const InstantDeliveryScreen({super.key});

  @override
  ConsumerState<InstantDeliveryScreen> createState() =>
      _InstantDeliveryScreenState();
}

class _InstantDeliveryScreenState extends ConsumerState<InstantDeliveryScreen> {
  TextEditingController pickupController = TextEditingController();
  TextEditingController dropController = TextEditingController();
  TextEditingController nameContr = TextEditingController();
  TextEditingController phonContro = TextEditingController();

  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    final box = Hive.box("folder");
    nameContr.text =
        "${box.get("firstName") ?? ''} ${box.get("lastName") ?? ''}".trim();
    phonContro.text = box.get("phone") ?? "";
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

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

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks.first;

    // String address =
    //     "${place.name}, ${place.street}, ${place.subLocality}, ${place.locality},${place.subAdministrativeArea},${place.administrativeArea},${place.postalCode},${place.country}";

    String address =
        "${place.name?.isNotEmpty == true ? '${place.name}, ' : ''}"
        "${place.street?.isNotEmpty == true ? '${place.street}, ' : ''}"
        "${place.subLocality?.isNotEmpty == true ? '${place.subLocality}, ' : ''}"
        "${place.locality?.isNotEmpty == true ? '${place.locality}, ' : ''}"
        "${place.administrativeArea?.isNotEmpty == true ? '${place.administrativeArea}, ' : ''}"
        "${place.postalCode?.isNotEmpty == true ? '${place.postalCode}, ' : ''}"
        "${place.country ?? ''}";

    final parts = address
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final uniqueParts = <String>{};
    final cleanParts = parts.where((e) => uniqueParts.add(e)).toList();

    address = cleanParts.join(', ');

    pickupController.text = address;

    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
      _currentAddress = address;
      pickupController.text = address;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLatLng!));
  }

  bool isLoading = false;
  @override
  void dispose() {
    nameContr.dispose();
    phonContro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(getDistanceProvider);
    var box = Hive.box("folder");
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Color(0xFFFFFFFF),
        shape: CircleBorder(),
        onPressed: () {
          Navigator.pop(context);
        },
        child: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
        ),
      ),
      body: _currentLatLng == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng!,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.45, // 🔹 Sheet shuru me 45% height lega
                  minChildSize: 0.25, // 🔹 Sabse chhoti height
                  maxChildSize: 0.45, // 🔹 Upar drag karke max kitna khule
                  builder: (context, scrollController) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
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
                        padding: EdgeInsets.zero,
                        children: [
                          SizedBox(height: 8.h),
                          Center(
                            child: Container(
                              width: 50.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "Instant Delivery",
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111111),
                              letterSpacing: -1,
                            ),
                          ),
                          // Container(
                          //   margin: EdgeInsets.only(
                          //     left: 10.w,
                          //     right: 10.w,
                          //     top: 12.h,
                          //   ),
                          //   child: RideCard(
                          //     pickupController: pickupController,
                          //     dropController: dropController,
                          //   ),
                          // ),
                          RideCardMyCode(
                            pickupController: pickupController,
                            dropController: dropController,
                            nameController: nameContr,
                            phoneController: phonContro,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xFFE5F0F1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.favorite_border, size: 16.sp),
                                  SizedBox(width: 7.w),
                                  Text(
                                    "Saved Address",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF006970),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     Container(
                          //       padding: EdgeInsets.only(
                          //         left: 10.w,
                          //         right: 10.w,
                          //         top: 5.h,
                          //         bottom: 5.h,
                          //       ),
                          //       decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(4.r),
                          //         color: Color(0xFFFFFFFF),
                          //         boxShadow: [
                          //           BoxShadow(
                          //             offset: Offset(0, 0),
                          //             spreadRadius: 0,
                          //             blurRadius: 1,
                          //             color: Color.fromARGB(63, 0, 0, 0),
                          //           ),
                          //         ],
                          //       ),
                          //       child: Row(
                          //         children: [
                          //           Container(
                          //             width: 30.w,
                          //             height: 30.h,
                          //             decoration: BoxDecoration(
                          //               shape: BoxShape.circle,
                          //               color: Color(0xFF086E86),
                          //             ),
                          //             child: Icon(
                          //               Icons.location_on,
                          //               color: Color(0xFFDE4B65),
                          //             ),
                          //           ),
                          //           SizedBox(width: 8.w),
                          //           Column(
                          //             crossAxisAlignment:
                          //                 CrossAxisAlignment.start,
                          //             children: [
                          //               Text(
                          //                 "ARH Hardware",
                          //                 style: GoogleFonts.inter(
                          //                   fontSize: 16.sp,
                          //                   fontWeight: FontWeight.w400,
                          //                   color: Color(0xFF000000),
                          //                   letterSpacing: -1,
                          //                 ),
                          //               ),
                          //               Text(
                          //                 "Sri Saranakara Road",
                          //                 style: GoogleFonts.inter(
                          //                   fontSize: 12.sp,
                          //                   fontWeight: FontWeight.w400,
                          //                   color: Color.fromARGB(127, 0, 0, 0),
                          //                   letterSpacing: -1,
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //     SizedBox(width: 10.w),
                          //     Container(
                          //       padding: EdgeInsets.only(
                          //         left: 10.w,
                          //         right: 10.w,
                          //         top: 5.h,
                          //         bottom: 5.h,
                          //       ),
                          //       decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(4.r),
                          //         color: Color(0xFFFFFFFF),
                          //         boxShadow: [
                          //           BoxShadow(
                          //             offset: Offset(0, 0),
                          //             spreadRadius: 0,
                          //             blurRadius: 1,
                          //             color: Color.fromARGB(63, 0, 0, 0),
                          //           ),
                          //         ],
                          //       ),
                          //       child: Row(
                          //         children: [
                          //           Container(
                          //             width: 30.w,
                          //             height: 30.h,
                          //             decoration: BoxDecoration(
                          //               shape: BoxShape.circle,
                          //               color: Color(0xFF086E86),
                          //             ),
                          //             child: Icon(
                          //               Icons.location_on,
                          //               color: Color(0xFFDE4B65),
                          //             ),
                          //           ),
                          //           SizedBox(width: 8.w),
                          //           Column(
                          //             crossAxisAlignment:
                          //                 CrossAxisAlignment.start,
                          //             children: [
                          //               Text(
                          //                 "ARH Hardware",
                          //                 style: GoogleFonts.inter(
                          //                   fontSize: 16.sp,
                          //                   fontWeight: FontWeight.w400,
                          //                   color: Color(0xFF000000),
                          //                   letterSpacing: -1,
                          //                 ),
                          //               ),
                          //               Text(
                          //                 "Sri Saranakara Road",
                          //                 style: GoogleFonts.inter(
                          //                   fontSize: 12.sp,
                          //                   fontWeight: FontWeight.w400,
                          //                   color: Color.fromARGB(127, 0, 0, 0),
                          //                   letterSpacing: -1,
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          SizedBox(height: 15.h),
                          Container(
                            margin: EdgeInsets.only(left: 15.w, right: 15.w),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50.h),
                                backgroundColor: Color(0xFF006970),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              onPressed: () async {
                                if (pickupController.text.isEmpty ||
                                    dropController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Please enter both pickup and drop locations",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  List<Location> pickupLocations =
                                      await locationFromAddress(
                                        pickupController.text,
                                      );
                                  double pickupLat =
                                      pickupLocations.first.latitude;
                                  double pickupLon =
                                      pickupLocations.first.longitude;

                                  List<Location> dropLocations =
                                      await locationFromAddress(
                                        dropController.text,
                                      );
                                  double dropLat = dropLocations.first.latitude;
                                  double dropLon =
                                      dropLocations.first.longitude;
                                  final body = GetDistanceBodyModel(
                                    // name: "${box.get("firstName")}",
                                    // mobNo: "${box.get("phone")}",
                                    name: nameContr.text.isNotEmpty
                                        ? nameContr.text
                                        : "${box.get("firstName")}",
                                    mobNo: phonContro.text.isNotEmpty
                                        ? phonContro.text
                                        : "${box.get("phone")}",
                                    origName: pickupController.text,
                                    picUpType: "Instant",
                                    destName: dropController.text,
                                    origLat: pickupLat,
                                    origLon: pickupLon,
                                    destLat: dropLat,
                                    destLon: dropLon,
                                  );
                                  await ref
                                      .read(getDistanceProvider.notifier)
                                      .fetchDistance(body);

                                  await Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => SelectTripScreen(),
                                    ),
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Error fetching coordinates: $e",
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                        left: 15.w,
                                        bottom: 15.h,
                                        right: 15.w,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
                                        side: BorderSide.none,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: isLoading
                                  ? Center(
                                      child: SizedBox(
                                        width: 30.w,
                                        height: 30.h,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.w,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "Next",
                                      style: GoogleFonts.inter(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class RideCard extends StatefulWidget {
  final TextEditingController pickupController;
  final TextEditingController dropController;
  const RideCard({
    super.key,
    required this.pickupController,
    required this.dropController,
  });

  @override
  State<RideCard> createState() => _RideCardState();
}

class _RideCardState extends State<RideCard> {
  bool oneWay = true;
  bool returnWay = true;

  // Replace 'YOUR_GOOGLE_PLACES_API_KEY' with your actual Google Places API key
  static const kGoogleApiKey = "AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.r),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 3,
            spreadRadius: 2,
            color: Color.fromARGB(28, 0, 0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40.h,
                  color: Color(0xFFEFEFEF),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF222222),
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "One Way",
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 40.h,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF222222),
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "Return Way",
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pickup",
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CircleAvatar(
                      backgroundColor: Color(0xFF086E86),
                      radius: 3.r,
                    ),
                    SizedBox(height: 4.h),
                    CircleAvatar(
                      backgroundColor: Color(0xFF086E86),
                      radius: 3.r,
                    ),
                    SizedBox(height: 4.h),
                    CircleAvatar(
                      backgroundColor: Color(0xFF086E86),
                      radius: 3.r,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "Drop",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: widget.pickupController,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: "Fetching location...",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      Divider(
                        color: Color.fromARGB(102, 120, 119, 141),
                        thickness: 2,
                        height: 2,
                      ),

                      TextField(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   CupertinoPageRoute(
                          //     builder: (context) => OpenDraggle(),
                          //     fullscreenDialog: true,
                          //   ),
                          // );
                        },
                        controller: widget.dropController,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: "Masjid Al Ma...",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      // GooglePlaceAutoCompleteTextField(
                      //   containerHorizontalPadding: 0,
                      //   containerVerticalPadding: 0,
                      //   textEditingController: widget.dropController,
                      //   googleAPIKey: kGoogleApiKey,
                      //   inputDecoration: InputDecoration(
                      //     contentPadding: EdgeInsets.zero,
                      //     border: InputBorder.none,
                      //     enabledBorder: InputBorder.none,
                      //     focusedBorder: InputBorder.none,
                      //     errorBorder: InputBorder.none,
                      //     disabledBorder: InputBorder.none,
                      //     hintText: "Where to?",
                      //     hintStyle: GoogleFonts.inter(
                      //       fontSize: 14.sp,
                      //       fontWeight: FontWeight.w500,
                      //       color: Colors.black54,
                      //     ),
                      //   ),
                      //   // debounceTime: 400,
                      //   // countries: ["in"],
                      //   isLatLngRequired: true,
                      //   getPlaceDetailWithLatLng: (postalCodeResponse) {
                      //     // Optional: Handle place details if needed
                      //     log(
                      //       "Place selected: ${postalCodeResponse.description}",
                      //     );
                      //   },
                      //   itemClick: (postalCodeResponse) {
                      //     widget.dropController.text =
                      //         postalCodeResponse.description ?? '';
                      //     // Focus back or hide keyboard if needed
                      //     FocusScope.of(context).unfocus();
                      //   },
                      //   itemBuilder: (context, index, Prediction prediction) {
                      //     return Container(
                      //       // padding: EdgeInsets.all(10),
                      //       child: Row(
                      //         children: [
                      //           Icon(Icons.location_on, color: Colors.grey),
                      //           SizedBox(width: 7),
                      //           Expanded(
                      //             child: Text(
                      //               prediction.description ?? '',
                      //               style: TextStyle(fontSize: 16),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   },
                      //   seperatedBuilder: null,
                      //   //rowMainAxisAlignment: MainAxisAlignment.start,
                      //   boxDecoration: BoxDecoration(
                      //     border: Border.all(color: Colors.transparent),
                      //   ),
                      //   textStyle: GoogleFonts.inter(
                      //     fontSize: 15.sp,
                      //     fontWeight: FontWeight.w500,
                      //     color: Colors.black,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.favorite_border, color: Colors.black),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////// My Design =======================

class RideCardMyCode extends StatefulWidget {
  final TextEditingController pickupController;
  final TextEditingController dropController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  const RideCardMyCode({
    super.key,
    required this.pickupController,
    required this.dropController,
    required this.nameController,
    required this.phoneController,
  });

  @override
  State<RideCardMyCode> createState() => _RideCardMyCodeState();
}

class _RideCardMyCodeState extends State<RideCardMyCode> {
  bool showPickupField = false;
  final nameContr = TextEditingController();
  final pickCon = TextEditingController();
  final phonContro = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final box = Hive.box("folder");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address Card
        Container(
          margin: EdgeInsets.only(top: 15.h),
          padding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            top: 18.h,
            bottom: 18.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 3,
                spreadRadius: 2,
                color: Color.fromARGB(28, 0, 0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: 12.sp, color: Colors.green),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    // "${box.get("firstName")} ${box.get("lastName")} ·",
                                    "${widget.nameController.text} ·",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp,
                                ),
                              ),
                              TextSpan(
                                // text: " ${box.get("phone")}",
                                text: " ${widget.phoneController.text}",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // "60 Feet Rd, Sanjay Nagar, Jagann...",
                          // widget.pickupController.text,
                          widget.pickupController.text.isNotEmpty
                              ? widget.pickupController.text
                              : "Fetching location...",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.r),
                          ),
                        ),
                        builder: (context) => PickupScreen(
                          pickController: widget.pickupController,
                          nameController: widget.nameController,
                          phoneController: widget.phoneController,
                        ),
                        // builder: (context) {
                        //   return FractionallySizedBox(
                        //     heightFactor: 0.70, // 👈 85% screen height
                        //     child: PickupScreen(
                        //       pickController: widget.pickupController,
                        //       nameController: nameContr,
                        //       phoneController: phonContro,
                        //     ),
                        //   );
                        // },
                      ).then((_) {
                        setState(() {});
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE5F0F1),
                      ),
                      child: Icon(Icons.arrow_forward_ios, size: 20.w),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14.sp, color: Colors.red),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: widget.dropController,
                      decoration: InputDecoration(
                        isDense: true,
                        hint: Text(
                          "Where is your Drop ?",
                          style: GoogleFonts.poppins(fontSize: 14.sp),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 10.w,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE5F0F1),
                    ),
                    child: Icon(Icons.add, size: 20.sp),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 20.h),
      ],
    );
  }
}

class PickupScreen extends StatefulWidget {
  final TextEditingController pickController;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  PickupScreen({
    super.key,
    required this.pickController,
    required this.nameController,
    required this.phoneController,
  });

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _pickupController;

  @override
  void initState() {
    super.initState();
    // // Initialize with default values
    // _nameController = TextEditingController(text: widget.nameController.text);
    // _phoneController = TextEditingController(text: widget.phoneController.text);
    // _pickupController = TextEditingController(text: widget.pickController.text);

    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _pickupController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pickupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // handles keyboard
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -55,
              left: 0,
              right: 0,
              child: Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Pickup Details",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 15.h),
                  TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      isDense: true,
                      hint: Text(
                        "Enter Name",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 10.w,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: Colors.blueAccent,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  TextField(
                    controller: _phoneController,
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      counterText: "",
                      isDense: true,
                      hint: Text(
                        "Phone Number",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 10.w,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: Colors.blueAccent,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  TextField(
                    controller: _pickupController,

                    decoration: InputDecoration(
                      isDense: true,
                      hint: Text(
                        "Enter Your Pickup",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 10.w,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: Colors.blueAccent,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF006970),
                      minimumSize: Size(double.infinity, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: () {
                      final trimmedName = _nameController.text.trim();
                      if (trimmedName.isNotEmpty) {
                        widget.nameController.text = trimmedName;
                      }
                      final trimmedPhone = _phoneController.text.trim();
                      if (trimmedPhone.isNotEmpty) {
                        widget.phoneController.text = trimmedPhone;
                      }
                      final trimmedPickup = _pickupController.text.trim();
                      if (trimmedPickup.isNotEmpty) {
                        widget.pickController.text = trimmedPickup;
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Confirm",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
