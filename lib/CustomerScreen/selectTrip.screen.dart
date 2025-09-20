import 'package:delivery_mvp_app/CustomerScreen/pickup.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectTripScreen extends StatefulWidget {
  const SelectTripScreen({super.key});

  @override
  State<SelectTripScreen> createState() => _SelectTripScreenState();
}

class _SelectTripScreenState extends State<SelectTripScreen> {
  List<Map<String, dynamic>> selectTrip = [
    {
      "image": "assets/b.png",
      "name": "Delivery Go",
      "ammount": "₹170.71",
      "discount": "₹188.71",
    },
    {
      "image": "assets/t.png",
      "name": "Delivery Go",
      "ammount": "₹170.71",
      "discount": "₹188.71",
    },
    {
      "image": "assets/car.png",
      "name": "Delivery Premier",
      "ammount": "₹223.63",
      "discount": "₹188.71",
    },
  ];

  bool isCheck = false;

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
            child: DraggableScrollableSheet(
              initialChildSize: 0.40, // bottom sheet height (35% of screen)
              // minChildSize: 0.15,
              // maxChildSize: 0.9,
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
                    padding: EdgeInsets.zero,
                    controller: scrollController,
                    children: [
                      SizedBox(height: 14.h),
                      Center(
                        child: Container(
                          width: 50.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
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
                      SizedBox(height: 14.h),
                      Container(
                        width: double.infinity,
                        height: 160.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Color(0xFF000000),
                            width: 3,
                          ),
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
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 18.w),
                                  child: Text(
                                    "Delivery Go",
                                    style: GoogleFonts.inter(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xfF000000),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 18.w),
                                  child: Text(
                                    "₹170.71",
                                    style: GoogleFonts.inter(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xfF000000),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
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
                                    radius: 4.r,
                                    backgroundColor: Color(0xFFD9D9D9),
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
                            SizedBox(height: 6.h),
                            Container(
                              margin: EdgeInsets.only(left: 18.w),
                              width: 82.w,
                              height: 22.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                color: Color(0xFF3B6CE9),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bolt,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
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
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: selectTrip.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  // "assets/b.png",
                                  selectTrip[index]["image"].toString(),
                                  width: 50.w,
                                  height: 50.h,
                                  fit: BoxFit.contain,
                                ),
                                //  SizedBox(width: 20.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      //"Delivery Go",
                                      selectTrip[index]['name'],
                                      style: GoogleFonts.inter(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff000000),
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    Row(
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
                                          radius: 4.r,
                                          backgroundColor: Color(0xFFD9D9D9),
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
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      // "₹170.71",
                                      selectTrip[index]['ammount'],
                                      style: GoogleFonts.inter(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xfF000000),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    if (index == 0 || index == 1)
                                      Text(
                                        //"₹188.71",
                                        selectTrip[index]['discount'],
                                        style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF6B6B6B),
                                          letterSpacing: 0,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor: Color(0xFF6B6B6B),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.only(
                          left: 15.w,
                          right: 15.w,
                          top: 6.h,
                          bottom: 6.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: Color.fromARGB(127, 0, 0, 0),
                            width: 1.w,
                          ),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset("assets/SvgImage/v.svg"),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "....8980",
                                  style: GoogleFonts.inter(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    letterSpacing: -1,
                                  ),
                                ),
                                Text(
                                  "Shaikh niyo",
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(127, 0, 0, 0),
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Container(
                              width: 1.w,
                              height: 40.h,
                              color: Color.fromARGB(127, 0, 0, 0),
                            ),
                            Spacer(),
                            SvgPicture.asset("assets/SvgImage/ed.svg"),
                            SizedBox(width: 8.w),
                            Text(
                              "Note",
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF000000),
                                letterSpacing: -1,
                              ),
                            ),
                            Spacer(),
                            Container(
                              width: 1.w,
                              height: 40.h,
                              color: Color.fromARGB(127, 0, 0, 0),
                            ),
                            Spacer(),
                            SvgPicture.asset("assets/SvgImage/addpromo.svg"),
                            SizedBox(width: 8.w),
                            Text(
                              "Add Promo",
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0690AF),
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.only(
                          left: 8.w,
                          right: 10.w,
                          top: 6.h,
                          bottom: 6.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: Color(0xFF000000),
                            width: 1.w,
                          ),
                        ),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: 1,
                              child: Container(
                                //color: Colors.amber,
                                height: 25.h,
                                width: 30.w,
                                child: Checkbox(
                                  shape: CircleBorder(),
                                  activeColor: Color(0xFF222222),
                                  value: isCheck,
                                  onChanged: (value) {
                                    setState(() {
                                      isCheck = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10.w),
                              //color: Colors.amber,
                              width: 275.w,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "I confirm that I have read, consent and agree to the",
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " Terms and Conditions",
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF086E86),
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
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
                              builder: (context) => PickupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Book Now",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
