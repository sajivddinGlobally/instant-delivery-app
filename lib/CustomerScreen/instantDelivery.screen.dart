

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

import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/Model/DeleteAddressModel.dart';
import '../data/Model/GetAddressResponseModel.dart';
import '../data/controller/getAllAddress.dart';
import 'AddAddressPage.dart';
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
    _getCurrentLocation();
  }



  // Future<void> _getCurrentLocation() async {
  //   LocationPermission permission;
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Location permission denied")),
  //       );
  //       return;
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(
  //           "Location permission permanently denied. Please enable it from settings.",
  //         ),
  //       ),
  //     );
  //     return;
  //   }
  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  //   List<Placemark> placemarks = await placemarkFromCoordinates(
  //     position.latitude,
  //     position.longitude,
  //   );
  //
  //   Placemark place = placemarks.first;
  //
  //   String address =
  //       "${place.name?.isNotEmpty == true ? '${place.name}, ' : ''}"
  //       "${place.street?.isNotEmpty == true ? '${place.street}, ' : ''}"
  //       "${place.subLocality?.isNotEmpty == true ? '${place.subLocality}, ' : ''}"
  //       "${place.locality?.isNotEmpty == true ? '${place.locality}, ' : ''}"
  //       "${place.administrativeArea?.isNotEmpty == true ? '${place.administrativeArea}, ' : ''}"
  //       "${place.postalCode?.isNotEmpty == true ? '${place.postalCode}, ' : ''}"
  //       "${place.country ?? ''}";
  //
  //   final parts = address.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  //
  //   final uniqueParts = <String>{};
  //
  //   final cleanParts = parts.where((e) => uniqueParts.add(e)).toList();
  //
  //   address = cleanParts.join(', ');
  //
  //   pickupController.text = address;
  //
  //   setState(() {
  //     _currentLatLng = LatLng(position.latitude, position.longitude);
  //     _currentAddress = address;
  //     pickupController.text = address;
  //   });
  //
  //   _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLatLng!));
  // }





  Future<void> _getCurrentLocation() async {
    try {
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

      // 🔹 Step 1: Ensure GPS is ON
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      // 🔹 Step 2: Wait for high-accuracy position (less than 20m)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      // Sometimes first reading is old; confirm by stream for 1–2 sec
      await Future.delayed(const Duration(seconds: 2));
      Position freshPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      final lat = freshPosition.latitude;
      final lon = freshPosition.longitude;

      // 🔹 Step 3: Reverse geocode exact lat/lon
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      Placemark place = placemarks.first;

      String address =
          "${place.name?.isNotEmpty == true ? '${place.name}, ' : ''}"
          "${place.street?.isNotEmpty == true ? '${place.street}, ' : ''}"
          "${place.subLocality?.isNotEmpty == true ? '${place.subLocality}, ' : ''}"
          "${place.locality?.isNotEmpty == true ? '${place.locality}, ' : ''}"
          "${place.administrativeArea?.isNotEmpty == true ? '${place.administrativeArea}, ' : ''}"
          "${place.postalCode?.isNotEmpty == true ? '${place.postalCode}, ' : ''}"
          "${place.country ?? ''}";

      final parts = address.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final uniqueParts = <String>{};
      final cleanParts = parts.where((e) => uniqueParts.add(e)).toList();
      address = cleanParts.join(', ');

      setState(() {
        _currentLatLng = LatLng(lat, lon);
        _currentAddress = address;
        pickupController.text = address;
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLatLng!, zoom: 17.5),
        ),
      );
    } catch (e) {
      log("Location error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching current location: $e")),
      );
    }
  }


  bool isLoading = false;

  @override
  void dispose() {
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
          :

      Stack(
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




                    RideCardMyCode(
                      pickupController: pickupController,
                      dropController: dropController,

                    ),






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
                                .read(getDistanceProvider.notifier).fetchDistance(body);

                            await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    SelectTripScreen(
                                       pickupLat,
                                        pickupLon,
                                     dropLat,
                                       dropLon

                                    ),
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

  const RideCardMyCode({
    super.key,
    required this.pickupController,
    required this.dropController,

  });

  @override
  State<RideCardMyCode> createState() => _RideCardMyCodeState();
}
class _RideCardMyCodeState extends State<RideCardMyCode> {
  bool showPickupField = false;
  final pickCon = TextEditingController();


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
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PickupPage(
                              pickController: widget.pickupController,

                            ),
                          ),
                        ).then((_) {

                          setState(() {});
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

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
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PickupPage(
                            pickController: widget.pickupController,

                          ),
                        ),
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
                      readOnly: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DropPage(
                              dropController: widget.dropController,
                            ),
                          ),
                        ).then((_) {
                          setState(() {});
                        });
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: "Where is your Drop ?",
                        hintStyle: GoogleFonts.poppins(fontSize: 14.sp),
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
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey),
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


/*
class DropPage extends ConsumerStatefulWidget {
  final TextEditingController dropController;

  const DropPage({super.key, required this.dropController});

  @override
  ConsumerState<DropPage> createState() => _DropPageState();
}

class _DropPageState extends ConsumerState<DropPage> {
  late final TextEditingController _dropController;
  static const kGoogleApiKey = "AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g";

  String _lat = '';
  String _lon = '';
  bool  _isLoading = false;
  bool _fetchingCurrent = false;   // <-- UI spinner

  @override
  void initState() {
    super.initState();
    _dropController = TextEditingController(text: widget.dropController.text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(getAddressProvider);
  }

  @override
  void dispose() {
    _dropController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingCurrent = true);

    try {
      // 1. Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack("Location permission denied");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack("Location permission permanently denied");
        return;
      }

      // 2. GPS enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        _showSnack("Please enable location services");
        return;
      }

      // 3. High-accuracy position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      // 4. Reverse geocode
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;

      String address = [
        place.name,
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((e) => e?.isNotEmpty ?? false).join(', ');

      // 5. Update UI
      _dropController.text = address;
      _lat = position.latitude.toString();
      _lon = position.longitude.toString();
    } catch (e) {
      _showSnack("Failed to get location: $e");
    } finally {
      setState(() => _fetchingCurrent = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> deleteAddress(String? id) async {
    if (id == null || id.isEmpty) {
      _showSnack("Invalid address ID");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = DeleteAddressModel(id: id);

      final service = APIStateNetwork(callPrettyDio());
      await service.deleteAddress(body);

      _showSnack("Address deleted successfully!");

      // Only invalidate provider if using Riverpod
      ref.invalidate(getAddressProvider);

      // Do NOT pop here — let parent handle refresh
      // Navigator.pop(context, true); // Remove this

    } catch (e, st) {
      log("Delete Address error: $e\n$st");
      _showSnack("Failed to delete: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncResp = ref.watch(getAddressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Drop Details",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ---------- Google Places Search ----------
            GooglePlaceAutoCompleteTextField(
              textEditingController: _dropController,
              googleAPIKey: kGoogleApiKey,
              inputDecoration: InputDecoration(
                isDense: true,
                hintText: "Search drop location",
                hintStyle: GoogleFonts.poppins(fontSize: 14.sp),
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
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
                ),
                border: InputBorder.none,
              ),
              debounceTime: 400,
              isLatLngRequired: true,

              getPlaceDetailWithLatLng: (Prediction p) {
                if (p.lat != null && p.lng != null) {
                  _lat = p.lat!;
                  _lon = p.lng!;
                }
              },

              itemClick: (Prediction p) {
                _dropController.text = p.description ?? '';
                if (p.lat != null && p.lng != null) {
                  _lat = p.lat!;
                  _lon = p.lng!;
                }
                FocusScope.of(context).unfocus();
              },

              itemBuilder: (_, __, Prediction p) => Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 7),
                    Expanded(child: Text(p.description ?? '')),
                  ],
                ),
              ),
              seperatedBuilder: const Divider(height: 1),
              boxDecoration:
              BoxDecoration(border: Border.all(color: Colors.transparent)),
              textStyle: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // ----------  NEW: Current Location Button ----------
            ElevatedButton.icon(
              onPressed: _fetchingCurrent ? null : _useCurrentLocation,
              icon: _fetchingCurrent
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(
                _fetchingCurrent ? "Fetching…" : "Use Current Location",
                style: GoogleFonts.poppins(fontSize: 14.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 44.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),

            const SizedBox(height: 12),


            // ---------- Confirm Drop ----------
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: _dropController.text.trim().isEmpty
                  ? null
                  : () {
                widget.dropController.text = _dropController.text.trim();
                Navigator.pop(context);
              },
              child: Text(
                "Confirm Drop",
                style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            // ---------- Add Address Button ----------
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  Addaddresspage(Datum(),false)),
                );
                ref.invalidate(getAddressProvider);
                setState(() {});
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add Address"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                foregroundColor: Colors.white,
                minimumSize: Size(150.w, 40.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            const SizedBox(height: 30),



            // ---------- Saved Addresses ----------
            Text(
              "Saved Addresses",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),



            asyncResp.when(
              data: (model) {
                // Make a mutable copy of the list
                final addresses = List<Datum>.from(model.data ?? []);

                if (addresses.isEmpty) {
                  return const Text(
                    "No saved addresses",
                    style: TextStyle(color: Colors.grey),
                  );
                }

                return Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final addr = addresses[i];
                  
                      return ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.red),
                        title: Text(
                          addr.name ?? 'Unnamed',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          addr.type ?? '',
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                        ),

                  
                        trailing: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (value) async {
                      if (value == 'edit') {
                      // Edit Action
                      await Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => Addaddresspage(addr, true),
                      ),
                      );
                      ref.invalidate(getAddressProvider);
                      setState(() {});
                      } else if (value == 'delete') {
                      // Delete Action (same as before)
                      final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                      title: const Text("Delete Address?"),
                      content: Text("Remove '${addr.name ?? 'this address'}'?"),
                      actions: [
                      TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Cancel"),
                      ),
                      TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                      ),
                      ],
                      ),
                      );
                  
                      if (confirm == true) {
                      final deletedAddr = addresses.removeAt(i);
                      setState(() {});
                  
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                      content: const Text("Address deleted"),
                      action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                      addresses.insert(i, deletedAddr);
                      setState(() {});
                      },
                      ),
                      ),
                      );
                  
                      try {
                      await deleteAddress(deletedAddr.id);
                      } catch (e) {
                      addresses.insert(i, deletedAddr);
                      setState(() {});
                      _showSnack("Delete failed: $e");
                      }
                  
                      ref.invalidate(getAddressProvider);
                      }
                      }
                      },
                      itemBuilder: (context) => [
                      const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                      children: [
                      Icon(Icons.edit, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Edit"),
                      ],
                      ),
                      ),
                      const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                      children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Delete", style: TextStyle(color: Colors.red)),
                      ],
                      ),
                      ),
                      ],
                      ),
                        onTap: () {
                          _dropController.text = addr.name ?? '';
                          _lat = addr.lat.toString();
                          _lon = addr.lon.toString();
                          widget.dropController.text = _dropController.text.trim();
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Error: $e", style: const TextStyle(color: Colors.red)),
              ),
            ),





            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}*/

/*


class PickupPage extends ConsumerStatefulWidget {
  final TextEditingController pickController;

  const PickupPage({super.key, required this.pickController});

  @override
  ConsumerState<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends ConsumerState<PickupPage> {
  late final TextEditingController _pickupController;
  static const kGoogleApiKey = "AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g";

  String _lat = '';
  String _lon = '';

  bool _fetchingCurrent = false;   // <-- UI spinner

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: widget.pickController.text);
  }
  bool  _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(getAddressProvider);
  }

  @override
  void dispose() {
    _pickupController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  //  NEW: Fetch current location & reverse-geocode
  // --------------------------------------------------------------
  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingCurrent = true);

    try {
      // 1. Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack("Location permission denied");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack("Location permission permanently denied");
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        _showSnack("Please enable location services");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;

      String address = [
        place.name,
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((e) => e?.isNotEmpty ?? false).join(', ');

      _pickupController.text = address;
      _lat = position.latitude.toString();
      _lon = position.longitude.toString();
    } catch (e) {
      _showSnack("Failed to get location: $e");
    } finally {
      setState(() => _fetchingCurrent = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }


  Future<void> deleteAddress(String? id) async {
    if (id == null || id.isEmpty) {
      _showSnack("Invalid address ID");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = DeleteAddressModel(id: id);

      final service = APIStateNetwork(callPrettyDio());
      await service.deleteAddress(body);

      _showSnack("Address deleted successfully!");

      ref.invalidate(getAddressProvider);


    } catch (e, st) {
      log("Delete Address error: $e\n$st");
      _showSnack("Failed to delete: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncResp = ref.watch(getAddressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pickup Details",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ---------- Google Places Search ----------
            GooglePlaceAutoCompleteTextField(

              textEditingController: _pickupController,
              googleAPIKey: kGoogleApiKey,
              inputDecoration: InputDecoration(
                isDense: true,
                hintText: "Search pickup location",
                hintStyle: GoogleFonts.poppins(fontSize: 14.sp),
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
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
                ),
                border: InputBorder.none,
              ),
              debounceTime: 400,
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction p) {
                if (p.lat != null && p.lng != null) {
                  _lat = p.lat!;
                  _lon = p.lng!;
                }
              },
              itemClick: (Prediction p) {
                _pickupController.text = p.description ?? '';
                if (p.lat != null && p.lng != null) {
                  _lat = p.lat!;
                  _lon = p.lng!;
                }
                FocusScope.of(context).unfocus();
              },
              itemBuilder: (_, __, Prediction p) => Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 7),
                    Expanded(child: Text(p.description ?? '')),
                  ],
                ),
              ),
              seperatedBuilder: const Divider(height: 1),
              boxDecoration:
              BoxDecoration(border: Border.all(color: Colors.transparent)),
              textStyle: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // ----------  NEW: Current Location Button ----------
            ElevatedButton.icon(
              onPressed: _fetchingCurrent ? null : _useCurrentLocation,
              icon: _fetchingCurrent
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(
                _fetchingCurrent ? "Fetching…" : "Use Current Location",
                style: GoogleFonts.poppins(fontSize: 14.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 44.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: _pickupController.text.trim().isEmpty
                  ? null
                  : () {
                widget.pickController.text = _pickupController.text.trim();
                Navigator.pop(context);
              },
              child: Text(
                "Confirm Pickup",
                style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white),
              ),
            ),

            const SizedBox(height: 30),


            // ---------- Add Address Button ----------
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  Addaddresspage(
                      Datum(),
                      false)),
                );
                ref.invalidate(getAddressProvider);
                setState(() {});
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add Address"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                foregroundColor: Colors.white,
                minimumSize: Size(150.w, 40.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ---------- Confirm Pickup ----------




            // ---------- Saved Addresses ----------
            Text(
              "Saved Addresses",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            // asyncResp.when(
            //   data: (model) {
            //     final addresses = model.data ?? [];
            //     if (addresses.isEmpty) {
            //       return const Text(
            //         "No saved addresses",
            //         style: TextStyle(color: Colors.grey),
            //       );
            //     }
            //     return ListView.separated(
            //       shrinkWrap: true,
            //       physics: const NeverScrollableScrollPhysics(),
            //       itemCount: addresses.length,
            //       separatorBuilder: (_, __) => const Divider(height: 1),
            //       itemBuilder: (context, i) {
            //         final addr = addresses[i];
            //         return ListTile(
            //           leading: const Icon(Icons.location_on, color: Colors.green),
            //           title: Text(
            //             addr.name ?? 'Unnamed',
            //             style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            //           ),
            //           subtitle: Text(
            //             "${addr.type}",
            //             style: GoogleFonts.poppins(color: Colors.grey[600]),
            //           ),
            //           trailing: InkWell(
            //             onTap: ()async{
            //              await Navigator.push(context, MaterialPageRoute(builder: (context)=>Addaddresspage(addr,true)));
            //              ref.invalidate(getAddressProvider);
            //              setState(() {});
            //             },
            //               child: const Icon(Icons.arrow_forward_ios, size: 16)),
            //           onTap: () {
            //             _pickupController.text = addr.name ?? '';
            //             _lat = addr.lat.toString();
            //             _lon = addr.lon.toString();
            //
            //             // Update parent controller & go back
            //             widget.pickController.text = _pickupController.text.trim();
            //             Navigator.pop(context);
            //           },
            //         );
            //       },
            //     );
            //   },
            //   loading: () => const Padding(
            //     padding: EdgeInsets.all(16),
            //     child: CircularProgressIndicator(),
            //   ),
            //   error: (e, _) => Padding(
            //     padding: const EdgeInsets.all(16),
            //     child: Text("Error: $e", style: const TextStyle(color: Colors.red)),
            //   ),
            // ),


            asyncResp.when(
              data: (model) {
                // Mutable copy
                final addresses = List<Datum>.from(model.data ?? []);

                if (addresses.isEmpty) {
                  return const Text(
                    "No saved addresses",
                    style: TextStyle(color: Colors.grey),
                  );
                }


                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final addr = addresses[i];

                    return ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.green),
                      title: Text(
                        addr.name ?? 'Unnamed',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        addr.type ?? '',
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                      ),
                      trailing: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            // Edit Action
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Addaddresspage(addr, true),
                              ),
                            );
                            ref.invalidate(getAddressProvider);
                            setState(() {});
                          } else if (value == 'delete') {
                            // Delete Action (same as before)
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Delete Address?"),
                                content: Text("Remove '${addr.name ?? 'this address'}'?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final deletedAddr = addresses.removeAt(i);
                              setState(() {});

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Address deleted"),
                                  action: SnackBarAction(
                                    label: "UNDO",
                                    onPressed: () {
                                      addresses.insert(i, deletedAddr);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );

                              try {
                                await deleteAddress(deletedAddr.id);
                              } catch (e) {
                                addresses.insert(i, deletedAddr);
                                setState(() {});
                                _showSnack("Delete failed: $e");
                              }

                              ref.invalidate(getAddressProvider);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18, color: Colors.blue),
                                SizedBox(width: 8),
                                Text("Edit"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text("Delete", style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),


                      onTap: () {
                        _pickupController.text = addr.name ?? '';
                        _lat = addr.lat.toString();
                        _lon = addr.lon.toString();

                        widget.pickController.text = _pickupController.text.trim();
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Error: $e", style: const TextStyle(color: Colors.red)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}*/


// -----------------------------------------------------------------------------
//  PAGE
// -----------------------------------------------------------------------------
class PickupPage extends ConsumerStatefulWidget {
  final TextEditingController pickController;

  const PickupPage({super.key, required this.pickController});

  @override
  ConsumerState<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends ConsumerState<PickupPage> {
  late final TextEditingController _pickupController;
  late final FocusNode _focusNode;

  static const kGoogleApiKey = "AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g";

  String _lat = '';
  String _lon = '';

  bool _fetchingCurrent = false; // UI spinner for current location
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pickupController =
        TextEditingController(text: widget.pickController.text);
    _focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(getAddressProvider);
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  //  FETCH CURRENT LOCATION + REVERSE GEOCODE
  // --------------------------------------------------------------
  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingCurrent = true);

    try {
      // 1. Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack("Location permission denied");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack("Location permission permanently denied");
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        _showSnack("Please enable location services");
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      final placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      final place = placemarks.first;

      final address = [
        place.name,
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((e) => e?.isNotEmpty ?? false).join(', ');

      _pickupController.text = address;
      _lat = position.latitude.toString();
      _lon = position.longitude.toString();

      // move cursor to end
      _pickupController.selection = TextSelection.fromPosition(
        TextPosition(offset: _pickupController.text.length),
      );
    } catch (e) {
      _showSnack("Failed to get location: $e");
    } finally {
      setState(() => _fetchingCurrent = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // --------------------------------------------------------------
  //  DELETE ADDRESS (with undo)
  // --------------------------------------------------------------
  Future<void> deleteAddress(String? id) async {
    if (id == null || id.isEmpty) {
      _showSnack("Invalid address ID");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = DeleteAddressModel(id: id);
      final service = APIStateNetwork(callPrettyDio());
      await service.deleteAddress(body);

      _showSnack("Address deleted successfully!");
      ref.invalidate(getAddressProvider);
    } catch (e, st) {
      log("Delete Address error: $e\n$st");
      _showSnack("Failed to delete: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncResp = ref.watch(getAddressProvider);

    return Scaffold(
      appBar: AppBar(

        title:
        Text(
          "Pickup Details",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ---------- GOOGLE PLACES AUTOCOMPLETE ----------
            GooglePlaceAutoCompleteTextField(
              textEditingController: _pickupController,
              focusNode: _focusNode, // <-- important
              googleAPIKey: kGoogleApiKey,
              inputDecoration: InputDecoration(
                isDense: true,
                hintText: "Search pickup location",
                hintStyle: GoogleFonts.poppins(fontSize: 14.sp),
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
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
                ),
                border: InputBorder.none,
              ),
              debounceTime: 400,
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction p) {
                if (p.lat != null && p.lng != null) {
                  _lat = p.lat!;
                  _lon = p.lng!;
                }
              },
              itemClick: (Prediction p) {
                _pickupController.text = p.description ?? '';
                if (p.lat != null && p.lng != null) {
                  _lat = p.lat!;
                  _lon = p.lng!;
                }

                // ---- CURSOR TO END ----
                _pickupController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _pickupController.text.length),
                );

                // DO NOT call FocusScope.unfocus() → keep keyboard open
              },
              itemBuilder: (_, __, Prediction p) => Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 7),
                    Expanded(child: Text(p.description ?? '')),
                  ],
                ),
              ),
              seperatedBuilder: const Divider(height: 1),
              boxDecoration:
              BoxDecoration(border: Border.all(color: Colors.transparent)),
              textStyle: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // ---------- USE CURRENT LOCATION ----------
            ElevatedButton.icon(
              onPressed: _fetchingCurrent ? null : _useCurrentLocation,
              icon: _fetchingCurrent
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(
                _fetchingCurrent ? "Fetching…" : "Use Current Location",
                style: GoogleFonts.poppins(fontSize: 14.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 44.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------- CONFIRM PICKUP ----------
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: _pickupController.text.trim().isEmpty
                  ? null
                  : () {
                widget.pickController.text =
                    _pickupController.text.trim();
                Navigator.pop(context);
              },
              child: Text(
                "Confirm Pickup",
                style: GoogleFonts.poppins(
                    fontSize: 16.sp, color: Colors.white),
              ),
            ),

            const SizedBox(height: 30),

            // ---------- ADD ADDRESS ----------
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Addaddresspage(Datum(), false)),
                );
                ref.invalidate(getAddressProvider);
                setState(() {});
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add Address"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                foregroundColor: Colors.white,
                minimumSize: Size(150.w, 40.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ---------- SAVED ADDRESSES ----------
            Text(
              "Saved Addresses",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            asyncResp.when(
              data: (model) {
                final addresses = List<Datum>.from(model.data ?? []);

                if (addresses.isEmpty) {
                  return const Text(
                    "No saved addresses",
                    style: TextStyle(color: Colors.grey),
                  );
                }

                return Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final addr = addresses[i];

                      return ListTile(
                        leading:
                        const Icon(Icons.location_on, color: Colors.green),
                        title: Text(
                          addr.name ?? 'Unnamed',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          addr.type ?? '',
                          style:
                          GoogleFonts.poppins(color: Colors.grey[600]),
                        ),
                        trailing: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Addaddresspage(addr, true),
                                ),
                              );
                              ref.invalidate(getAddressProvider);
                              setState(() {});
                            } else if (value == 'delete') {
                              // ----- CONFIRM DELETE -----
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete Address?"),
                                  content: Text(
                                      "Remove '${addr.name ?? 'this address'}'?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text("Delete",
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              // ----- OPTIMISTIC UI (undo) -----
                              final removed = addresses.removeAt(i);
                              setState(() {});

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Address deleted"),
                                  action: SnackBarAction(
                                    label: "UNDO",
                                    onPressed: () {
                                      addresses.insert(i, removed);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );

                              try {
                                await deleteAddress(removed.id);
                              } catch (e) {
                                // rollback UI on failure
                                addresses.insert(i, removed);
                                setState(() {});
                                _showSnack("Delete failed: $e");
                              }

                              ref.invalidate(getAddressProvider);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text("Edit"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _pickupController.text = addr.name ?? '';
                          _lat = addr.lat.toString();
                          _lon = addr.lon.toString();

                          // move cursor
                          _pickupController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: _pickupController.text.length));

                          widget.pickController.text =
                              _pickupController.text.trim();
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Error: $e",
                    style: const TextStyle(color: Colors.red)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}



// -----------------------------------------------------------------------------
//  DROP PAGE (FULLY FIXED)
// -----------------------------------------------------------------------------
class DropPage extends ConsumerStatefulWidget {
  final TextEditingController dropController;

  const DropPage({super.key, required this.dropController});

  @override
  ConsumerState<DropPage> createState() => _DropPageState();
}

class _DropPageState extends ConsumerState<DropPage> {
  late final TextEditingController _dropController;
  late final FocusNode _focusNode; // Added FocusNode

  static const kGoogleApiKey = "AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g";

  String _lat = '';
  String _lon = '';
  bool _isLoading = false;
  bool _fetchingCurrent = false;

  @override
  void initState() {
    super.initState();
    _dropController = TextEditingController(text: widget.dropController.text);
    _focusNode = FocusNode(); // Initialize
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(getAddressProvider);
  }

  @override
  void dispose() {
    _dropController.dispose();
    _focusNode.dispose(); // Dispose
    super.dispose();
  }

  // --------------------------------------------------------------
  //  USE CURRENT LOCATION
  // --------------------------------------------------------------
  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingCurrent = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack("Location permission denied");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack("Location permission permanently denied");
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        _showSnack("Please enable location services");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      Placemark place = placemarks.first;

      String address = [
        place.name,
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((e) => e?.isNotEmpty ?? false).join(', ');

      _dropController.text = address;
      _lat = position.latitude.toString();
      _lon = position.longitude.toString();

      // Cursor को end में रखें
      _dropController.selection = TextSelection.fromPosition(
        TextPosition(offset: _dropController.text.length),
      );
    } catch (e) {
      _showSnack("Failed to get location: $e");
    } finally {
      setState(() => _fetchingCurrent = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // --------------------------------------------------------------
  //  DELETE ADDRESS WITH UNDO
  // --------------------------------------------------------------
  Future<void> deleteAddress(String? id) async {
    if (id == null || id.isEmpty) {
      _showSnack("Invalid address ID");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = DeleteAddressModel(id: id);
      final service = APIStateNetwork(callPrettyDio());
      await service.deleteAddress(body);

      _showSnack("Address deleted successfully!");
      ref.invalidate(getAddressProvider);
    } catch (e, st) {
      log("Delete Address error: $e\n$st");
      _showSnack("Failed to delete: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncResp = ref.watch(getAddressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Drop Details",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ---------- GOOGLE PLACES AUTOCOMPLETE ----------
            GooglePlaceAutoCompleteTextField(
              textEditingController: _dropController,
              focusNode: _focusNode, // Added
              googleAPIKey: kGoogleApiKey,
              inputDecoration: InputDecoration(
                isDense: true,
                hintText: "Search drop location",
                hintStyle: GoogleFonts.poppins(fontSize: 14.sp),
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
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
                ),
                border: InputBorder.none,
              ),
              debounceTime: 400,
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction p) {
                if (p.lat != null && p.lng != null) {
                  _lat = p.lat!;
                  _lon = p.lng!;
                }
              },
              itemClick: (Prediction p) {
                _dropController.text = p.description ?? '';
                if (p.lat != null && p.lng != null) {
                  _lat = p.lat!;
                  _lon = p.lng!;
                }

                // Cursor को end में रखें
                _dropController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _dropController.text.length),
                );

                // FocusScope.of(context).unfocus(); // REMOVED: कीबोर्ड बंद नहीं होगा
              },
              itemBuilder: (_, __, Prediction p) => Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 7),
                    Expanded(child: Text(p.description ?? '')),
                  ],
                ),
              ),
              seperatedBuilder: const Divider(height: 1),
              boxDecoration:
              BoxDecoration(border: Border.all(color: Colors.transparent)),
              textStyle: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // ---------- USE CURRENT LOCATION ----------
            ElevatedButton.icon(
              onPressed: _fetchingCurrent ? null : _useCurrentLocation,
              icon: _fetchingCurrent
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(
                _fetchingCurrent ? "Fetching…" : "Use Current Location",
                style: GoogleFonts.poppins(fontSize: 14.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 44.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------- CONFIRM DROP ----------
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed:
              // _dropController.text.trim().isEmpty
              //     ? null
              //     :
                  () {
                widget.dropController.text = _dropController.text.trim();
                Navigator.pop(context);
              },
              child: Text(
                "Confirm Drop",
                style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white),
              ),
            ),

            const SizedBox(height: 30),

            // ---------- ADD ADDRESS ----------
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Addaddresspage(Datum(), false)),
                );
                ref.invalidate(getAddressProvider);
                setState(() {});
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add Address"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                foregroundColor: Colors.white,
                minimumSize: Size(150.w, 40.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ---------- SAVED ADDRESSES ----------
            Text(
              "Saved Addresses",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            // asyncResp.when
            asyncResp.when(
              data: (model) {
                final addresses = List<Datum>.from(model.data ?? []);

                if (addresses.isEmpty) {
                  return const Text(
                    "No saved addresses",
                    style: TextStyle(color: Colors.grey),
                  );
                }

                return Expanded(
                  child: ListView.separated(
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final addr = addresses[i];

                      return ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.red),
                        title: Text(
                          addr.name ?? 'Unnamed',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          addr.type ?? '',
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                        ),
                        trailing: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Addaddresspage(addr, true),
                                ),
                              );
                              ref.invalidate(getAddressProvider);
                              setState(() {});
                            } else if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete Address?"),
                                  content: Text("Remove '${addr.name ?? 'this address'}'?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              final removed = addresses.removeAt(i);
                              setState(() {});

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Address deleted"),
                                  action: SnackBarAction(
                                    label: "UNDO",
                                    onPressed: () {
                                      addresses.insert(i, removed);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );

                              try {
                                await deleteAddress(removed.id);
                              } catch (e) {
                                addresses.insert(i, removed);
                                setState(() {});
                                _showSnack("Delete failed: $e");
                              }

                              ref.invalidate(getAddressProvider);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text("Edit"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text("Delete", style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _dropController.text = addr.name ?? '';
                          _lat = addr.lat.toString();
                          _lon = addr.lon.toString();

                          // Cursor को end में रखें
                          _dropController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _dropController.text.length),
                          );

                          widget.dropController.text = _dropController.text.trim();
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Error: $e", style: const TextStyle(color: Colors.red)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
