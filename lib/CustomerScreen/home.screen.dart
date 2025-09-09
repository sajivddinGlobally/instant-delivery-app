import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> myList = [
    {
      "image": "assets/SvgImage/truc.svg",
      "name": "Trucks",
      "title": "Choose from Our Fleet",
    },
    {
      "image": "assets/SvgImage/truck.svg",
      "name": "small truck",
      "title": "For Smaller Good",
    },
    {
      "image": "assets/SvgImage/bikes.svg",
      "name": "Bike",
      "title": "Choose from Our Fleet",
    },
    {
      "image": "assets/SvgImage/auto.svg",
      "name": "Auto Tempo",
      "title": "Choose from Our Fleet",
    },
    {
      "image": "assets/SvgImage/packer.svg",
      "name": "Packer &  Mover",
      "title": "Choose from Our Fleet",
    },
    {
      "image": "assets/SvgImage/india.svg",
      "name": "All India Parcel",
      "title": "Choose from Our Fleet",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 393.w,
                  height: 260.h,
                  decoration: BoxDecoration(color: Color(0xFF006970)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50.h),
                      Row(
                        children: [
                          SizedBox(width: 24.w),
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: Image.asset(
                              "assets/profile.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Noida Sector 75",
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                    color: Colors.white,
                                    size: 22.sp,
                                  ),
                                ],
                              ),
                              Text(
                                "Golf city, Plot 8, Sector 75",
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF99C3C6),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Color(0xFF33878D)),
                            ),
                            child: Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 24.w),
                        ],
                      ),
                      SizedBox(height: 25.h),
                      Padding(
                        padding: EdgeInsets.only(left: 24.w),
                        child: Text(
                          "Let’s Track your package",
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFFFFF),
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Container(
                        margin: EdgeInsets.only(left: 24.w, right: 24.w),
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                              left: 15.w,
                              right: 15.w,
                              top: 10.h,
                              bottom: 10.h,
                            ),
                            filled: true,
                            fillColor: Color(0xFFFFFFFF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Enter your tracking number",
                            hintStyle: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFCCCCCC),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF2490A9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -28.h,
                  left: 24.w,
                  right: 24.w,
                  child: Container(
                    width: 345.w,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Color.fromARGB(51, 237, 237, 237),
                        width: 1.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: Offset(0, 0),
                          color: Color.fromARGB(15, 118, 118, 118),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 24.w, right: 24.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          cardbuild("assets/SvgImage/check.svg", "Check Rate"),
                          cardbuild("assets/SvgImage/pickup.svg", "Pick Up"),
                          cardbuild("assets/SvgImage/drop.svg", "Drop Off"),
                          cardbuild("assets/SvgImage/history.svg", "History"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50.h),
            Container(
              margin: EdgeInsets.only(left: 24.w, right: 24.w),
              child: GridView.builder(
                itemCount: myList.length,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20.w,
                  mainAxisSpacing: 20.w,
                  childAspectRatio: 0.80,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    width: 158.w,
                    height: 181.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Color(0xFFE8E8E8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30.h),
                        Center(
                          child: SvgPicture.asset(
                            //"assets/SvgImage/truc.svg",
                            myList[index]['image'],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 9.w, top: 4.h),
                          child: Text(
                            // "Trucks",
                            myList[index]['name'],
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF000000),
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 9.w),
                          child: Text(
                            //  "Choose from Our Fleet",
                            myList[index]['title'],
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF000000),
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget cardbuild(String image, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(image),
        SizedBox(height: 8.h),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xFF353535),
          ),
        ),
      ],
    );
  }
}
