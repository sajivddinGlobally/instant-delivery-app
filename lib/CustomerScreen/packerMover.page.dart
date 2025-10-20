import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/checkPriceOrAddItem.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PackerMoverPage extends StatefulWidget {
  const PackerMoverPage({super.key});

  @override
  State<PackerMoverPage> createState() => _PackerMoverPageState();
}

class _PackerMoverPageState extends State<PackerMoverPage> {
  int select = 0;
  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  bool showPickupClear = false;
  bool showDropClear = false;

  @override
  void initState() {
    super.initState();
    pickupController.addListener(() {
      setState(() {
        showPickupClear = pickupController.text.isNotEmpty;
      });
    });

    dropController.addListener(() {
      setState(() {
        showDropClear = dropController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    pickupController.dispose();
    super.dispose();
  }

  void _clearText() {
    pickupController.clear();
  }

  void _submitText() {
    // Do something with text
    print('Submitted: ${pickupController.text}');
  }

  String? selectedDateText;

  void _showToday() {
    DateTime today = DateTime.now();
    setState(() {
      selectedDateText = "${today.day}-${today.month}-${today.year}";
    });
  }

  void _showTomorrow() {
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    setState(() {
      selectedDateText = "${tomorrow.day}-${tomorrow.month}-${tomorrow.year}";
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006970), // header color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF006970), // button color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateText = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: 10.w),
          child: FloatingActionButton(
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
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text(
            "Packer & Mover",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF111111),
              letterSpacing: -1,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "FAQs",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Color(0xFF006970),
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      buildStepCircle(
                        icon: Icons.location_on,
                        color: Color(0xFF006970),
                      ),
                      buildLine(),
                      buildStepCircle(
                        icon: Icons.add,
                        color: Color(0xFF006970),
                      ),
                      buildLine(),
                      buildStepCircle(
                        icon: Icons.calendar_month,
                        color: Color(0xFF8B8B8B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Moving Details",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF006970),
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    "Add Item",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF006970),
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    "Schedule",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Divider(color: Color(0xFF086E86)),
            SizedBox(height: 20.h),
            Container(
              margin: EdgeInsets.only(left: 15.w, right: 15.w),
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                top: 10.h,
                bottom: 10.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                color: Color(0xFFF2F2F2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        select = 0;
                      });
                    },
                    child: Container(
                      width: 152.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        color: select == 0
                            ? Color(0xFF006970)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          "Living Room",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: select == 0
                                ? Color(0xFFFFFFFF)
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        select = 1;
                      });
                    },
                    child: Container(
                      width: 152.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        color: select == 1
                            ? Color(0xFF006970)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          "Living Room",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: select == 1
                                ? Color(0xFFFFFFFF)
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            fetchLocation(
              Color(0xFF006970),
              Icons.arrow_upward,
              pickupController,
              "Pickup location",
              showPickupClear,
            ),
            ServiceBuild(
              name: "Service lift available at pickup",
              work: "A working service lift will reduce the overall quote",
            ),
            fetchLocation(
              Color(0xFFDC1818),
              Icons.arrow_downward,
              dropController,
              "Drop location",
              showDropClear,
            ),
            ServiceBuild(
              name: "Service lift available at drop",
              work: "A working service lift will reduce the overall quote",
            ),
            SizedBox(height: 20.h),
            InkWell(
              onTap: () {
                _pickDate(context);
              },
              child: Container(
                margin: EdgeInsets.only(left: 15.w, right: 15.w),
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 10.h,
                  bottom: 10.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: Color(0xFF000000)),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Shifting date",
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                        Text(
                          selectedDateText == null
                              ? 'No date selected'
                              : selectedDateText!,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150.w, 35.h),
                    backgroundColor: Color(0xFF006970),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                      side: BorderSide.none,
                    ),
                  ),
                  onPressed: () {
                    _showToday();
                  },
                  child: Text(
                    "Today",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150.w, 35.h),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                      side: BorderSide(color: Color(0xFF006970), width: 1.w),
                    ),
                  ),
                  onPressed: () {
                    _showTomorrow();
                  },
                  child: Text(
                    "Tomorrow",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF006970),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25.h),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(330.w, 55.h),
                  backgroundColor: Color(0xFF006970),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    side: BorderSide.none,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => CheckPriceOraddItemPage(),
                    ),
                  );
                },
                child: Text(
                  "Check Price",
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget fetchLocation(
    Color color,
    IconData icon,
    TextEditingController controller,
    String labelText,
    bool showClear,
  ) {
    return Container(
      margin: EdgeInsets.only(top: 25.h, left: 15.w, right: 15.w),
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              controller.clear();
            },
            child: Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Icon(icon, color: Colors.white, size: 15.sp),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 15.w,
                  right: 15.w,
                  top: 10.h,
                  bottom: 10.h,
                ),
                border: InputBorder.none,
                labelText: labelText,
                labelStyle: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          if (showClear)
            InkWell(
              onTap: () {
                controller.clear();
              },
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Icon(
                  Icons.clear_sharp,
                  color: Colors.white,
                  size: 15.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ServiceBuild extends StatefulWidget {
  final String name;
  final String work;
  const ServiceBuild({super.key, required this.name, required this.work});

  @override
  State<ServiceBuild> createState() => _ServiceBuildState();
}

class _ServiceBuildState extends State<ServiceBuild> {
  bool isCheck = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 20.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff000000),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                widget.work,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff000000),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Spacer(),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              activeColor: Colors.blue,
              value: isCheck,
              onChanged: (value) {
                setState(() {
                  isCheck = !isCheck;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class buildStepCircle extends StatelessWidget {
  final IconData icon;
  final Color? color;
  const buildStepCircle({super.key, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.h,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, color: Colors.white, size: 16.sp),
    );
  }
}

class buildLine extends StatelessWidget {
  const buildLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(height: 1.2.h, color: Color(0xFF086E86)),
    );
  }
}
