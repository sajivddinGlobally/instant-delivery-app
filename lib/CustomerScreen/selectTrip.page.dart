import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectTriPage extends StatefulWidget {
  const SelectTriPage({super.key});

  @override
  State<SelectTriPage> createState() => _SelectTriPageState();
}

class _SelectTriPageState extends State<SelectTriPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150.h,
                child: Text(
                  "dadfafasfadf",
                  style: GoogleFonts.inter(fontSize: 50.sp),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 50.h, left: 20.w),
                child: FloatingActionButton(
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
            ],
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 18.h),
                  Center(
                    child: Text(
                      "Choose a Trip",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000),
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Container(
                      width: 347.w,
                      height: 160.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Color(0xFF000000), width: 3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.h),
                          Center(
                            child: Image.asset(
                              "assets/car.png",
                              width: 106.w,
                              height: 60.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(width: 18.w),
                              Text(
                                "Delivery Go",
                                style: GoogleFonts.inter(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xfF000000),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Spacer(),
                              Text(
                                "₹170.71",
                                style: GoogleFonts.inter(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xfF000000),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(width: 18.w),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 18.w),
                            child: Row(
                              children: [
                                Text(
                                  "8:46pm",
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                CircleAvatar(
                                  backgroundColor: Color(0xFFD9D9D9),
                                  radius: 4.r,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  "4 min away",
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 18.w, top: 5.h),
                            width: 80.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                              color: Color(0xFF3B6CE9),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.bolt, color: Colors.white),
                                Text(
                                  "Faster",
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 18.w,
                            right: 18.w,
                            top: 10.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset("b.png",width: 50.w,height: 50.h,),
                                  SizedBox(width: 25.w,),
                                  

                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10.w, right: 10.w),
                            padding: EdgeInsets.only(
                              left: 10.w,
                              right: 10.w,
                              top: 5.h,
                              bottom: 5.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                              color: Color(0xFFFFFFFF),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 0),
                                  spreadRadius: 0,
                                  blurRadius: 1,
                                  color: Color.fromARGB(63, 0, 0, 0),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF086E86),
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: Color(0xFFDE4B65),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ARH Hardware",
                                      style: GoogleFonts.inter(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                    Text(
                                      "Sri Saranakara Road",
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromARGB(127, 0, 0, 0),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        margin: EdgeInsets.only(left: 20.w, right: 20.w),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50.h),
                            backgroundColor: Color(0xFF006970),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => SelectTriPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Next",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
