/*



import 'dart:developer';

import 'package:delivery_mvp_app/data/Model/AddAddressModel.dart';
import 'package:delivery_mvp_app/data/Model/GetAddressResponseModel.dart';
import 'package:delivery_mvp_app/data/Model/UpdateAddressBodyModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';

class Addaddresspage extends StatefulWidget {
  final Datum? data; // Nullable for Add mode
  final bool edit;

  const Addaddresspage(this.data, this.edit, {super.key, });

  @override
  State<Addaddresspage> createState() => _AddaddresspageState();
}

class _AddaddresspageState extends State<Addaddresspage> {
  late final TextEditingController _addressController;
  static const kGoogleApiKey = "AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g";

  String _lat = '';
  String _lon = '';
  String _selectedType = 'Home';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _addressTypes = [
    {'label': 'Home', 'icon': Icons.home},
    {'label': 'Work', 'icon': Icons.work},
    {'label': 'Other', 'icon': Icons.location_on},
  ];

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();

    // Edit mode: Pre-fill data
    if (widget.edit && widget.data != null) {
      _addressController.text = widget.data!.name ?? '';
      _lat = widget.data!.lat.toString();
      _lon = widget.data!.lon.toString();
      _selectedType = widget.data!.type?.capitalize() ?? 'Home';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.edit ? 'Edit Address' : 'Add Pickup Address',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF006970),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Google Places Search
                GooglePlaceAutoCompleteTextField(
                  textEditingController: _addressController,
                  googleAPIKey: kGoogleApiKey,
                  inputDecoration: InputDecoration(
                    isDense: true,
                    hintText: "Search for address",
                    hintStyle: GoogleFonts.poppins(fontSize: 14.sp),
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
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
                    _addressController.text = p.description ?? '';
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
                  boxDecoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                  textStyle: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w500),
                ),
            
                SizedBox(height: 24.h),
            
                // Address Type Selection
                Text(
                  "Address Type",
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12.h),
            
                ..._addressTypes.map((type) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () => setState(() => _selectedType = type['label']),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w,),
                        decoration: BoxDecoration(
                          color: _selectedType == type['label']
                              ? const Color(0xFF006970).withOpacity(0.1)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: _selectedType == type['label']
                                ? const Color(0xFF006970)
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(type['icon'], color: _selectedType == type['label'] ? const Color(0xFF006970) : Colors.grey[600], size: 22.sp),
                            SizedBox(width: 12.w),
                            Text(type['label'], style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w500, color: _selectedType == type['label'] ? const Color(0xFF006970) : Colors.black87)),
                            const Spacer(),
                            Radio<String>(
                              value: type['label'],
                              groupValue: _selectedType,
                              onChanged: (v) => setState(() => _selectedType = v!),
                              activeColor: const Color(0xFF006970),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
            
                SizedBox(height: 30.h),
            
                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006970),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    onPressed: _isLoading ? null : _confirmAddress,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                      widget.edit ? "Update" : "Save",
                      style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Confirm & Save / Update Address
  Future<void> _confirmAddress() async {
    final trimmed = _addressController.text.trim();
    if (trimmed.isEmpty) {
      _showSnack("Please enter address");
      return;
    }
    if (_lat.isEmpty || _lon.isEmpty) {
      _showSnack("Please select a valid location");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = UpdateAddressBodyModel(
        id: widget.data?.id??"",
        name: trimmed,
        lat: _lat,
        lon: _lon,
        type: _selectedType.toLowerCase(),
      );
      final body2 = AddAddressModel(
        name: trimmed,
        lat: _lat,
        lon: _lon,
        type: _selectedType.toLowerCase(),
      );

      final service = APIStateNetwork(callPrettyDio());

      if (widget.edit && widget.data?.id != null) {
        // UPDATE API CALL
        await service.updateAddress(body);
        _showSnack("Address updated successfully!");
      } else {
        // ADD API CALL
        await service.addAddress(body2);
        _showSnack("Address saved successfully!");
      }

      if (!mounted) return;
      Navigator.pop(context, true); // Refresh parent
    } catch (e, st) {
      log("Address error: $e\n$st");
      _showSnack("Operation failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// Helper extension
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}*/


import 'dart:developer';

import 'package:delivery_mvp_app/data/Model/AddAddressModel.dart';
import 'package:delivery_mvp_app/data/Model/GetAddressResponseModel.dart';
import 'package:delivery_mvp_app/data/Model/UpdateAddressBodyModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';

class Addaddresspage extends StatefulWidget {
  final Datum? data;
  final bool edit;

  const Addaddresspage(this.data, this.edit, {super.key});

  @override
  State<Addaddresspage> createState() => _AddaddresspageState();
}

class _AddaddresspageState extends State<Addaddresspage> {

  late final TextEditingController _addressController;
  late final FocusNode _focusNode; // Added FocusNode
  static const kGoogleApiKey = "AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g";
  String _lat = '';
  String _lon = '';
  String _selectedType = 'Home';
  bool _isLoading = false;
  final List<Map<String, dynamic>> _addressTypes = [
    {'label': 'Home', 'icon': Icons.home},
    {'label': 'Work', 'icon': Icons.work},
    {'label': 'Other', 'icon': Icons.location_on},
  ];

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _focusNode = FocusNode(); // Initialize

    if (widget.edit && widget.data != null) {
      _addressController.text = widget.data!.name ?? '';
      _lat = widget.data!.lat.toString();
      _lon = widget.data!.lon.toString();
      _selectedType = widget.data!.type?.capitalize() ?? 'Home';

      // Cursor को end में रखें (edit mode में भी)
      _addressController.selection = TextSelection.fromPosition(
        TextPosition(offset: _addressController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _focusNode.dispose(); // Dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.edit ? 'Edit Address' : 'Add Pickup Address',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF006970),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Google Places Search
                GooglePlaceAutoCompleteTextField(
                  textEditingController: _addressController,
                  focusNode: _focusNode, // Added
                  googleAPIKey: kGoogleApiKey,
                  inputDecoration: InputDecoration(
                    isDense: true,
                    hintText: "Search for address",
                    hintStyle: GoogleFonts.poppins(fontSize: 14.sp),
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
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
                    _addressController.text = p.description ?? '';
                    if (p.lat != null && p.lng != null) {
                      _lat = p.lat!;
                      _lon = p.lng!;
                    }

                    // Cursor को end में रखें
                    _addressController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _addressController.text.length),
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
                  boxDecoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                  textStyle: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w500),
                ),

                SizedBox(height: 24.h),

                // Address Type Selection
                Text(
                  "Address Type",
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12.h),

                ..._addressTypes.map((type) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () => setState(() => _selectedType = type['label']),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: _selectedType == type['label']
                              ? const Color(0xFF006970).withOpacity(0.1)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: _selectedType == type['label']
                                ? const Color(0xFF006970)
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              type['icon'],
                              color: _selectedType == type['label']
                                  ? const Color(0xFF006970)
                                  : Colors.grey[600],
                              size: 22.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              type['label'],
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: _selectedType == type['label']
                                    ? const Color(0xFF006970)
                                    : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Radio<String>(
                              value: type['label'],
                              groupValue: _selectedType,
                              onChanged: (v) => setState(() => _selectedType = v!),
                              activeColor: const Color(0xFF006970),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                SizedBox(height: 30.h),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006970),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    onPressed: _isLoading ? null : _confirmAddress,
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      widget.edit ? "Update" : "Save",
                      style: GoogleFonts.poppins(
                          fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Confirm & Save / Update Address
  Future<void> _confirmAddress() async {
    final trimmed = _addressController.text.trim();
    if (trimmed.isEmpty) {
      _showSnack("Please enter address");
      return;
    }
    if (_lat.isEmpty || _lon.isEmpty) {
      _showSnack("Please select a valid location");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = APIStateNetwork(callPrettyDio());

      if (widget.edit && widget.data?.id != null) {
        // UPDATE
        final body = UpdateAddressBodyModel(
          id: widget.data!.id!,
          name: trimmed,
          lat: _lat,
          lon: _lon,
          type: _selectedType.toLowerCase(),
        );
        await service.updateAddress(body);
        _showSnack("Address updated successfully!");
      } else {
        // ADD
        final body = AddAddressModel(
          name: trimmed,
          lat: _lat,
          lon: _lon,
          type: _selectedType.toLowerCase(),
        );
        await service.addAddress(body);
        _showSnack("Address saved successfully!");
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e, st) {
      log("Address error: $e\n$st");
      _showSnack("Operation failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// Helper extension
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}