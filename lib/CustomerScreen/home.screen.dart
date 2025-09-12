import 'package:another_stepper/dto/stepper_data.dart';
import 'package:another_stepper/widgets/another_stepper.dart';
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
      "image": "assets/b.png",
      "name": "Bike",
      //"title": "Choose from Our Fleet",
    },
    {
      "image": "assets/t.png",
      "name": "Auto Tempo",
      //"title": "Choose from Our Fleet",
    },
    {
      "image": "assets/SvgImage/packer.svg",
      "name": "Packer &  Mover",
      //"title": "Choose from Our Fleet",
    },
    {
      "image": "assets/SvgImage/india.svg",
      "name": "All India Parcel",
      // "title": "Choose from Our Fleet",
    },
  ];

  int activeStep = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.50, -0.00),
                    end: Alignment(0.50, 1.00),
                    colors: [const Color(0xFF82ECF3), Colors.white],
                  ),
                ),
              ),
            ),
            SvgPicture.asset("assets/SvgImage/bg.svg"),
            Padding(
              padding: EdgeInsets.only(left: 21.w, right: 21.w, top: 35.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Color(0xFF006970),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Noida Sector 75",
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          Text(
                            "Golf city, Plot 8, Sector 75",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF086E86),
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
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.notifications_none,
                          color: Color(0xFF242126),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  TextField(
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
                        borderRadius: BorderRadius.circular(40.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.r),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Enter your tracking number",
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFCCCCCC),
                      ),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF2490A9)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(20.r),
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
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 24.w,
                        top: 16.h,
                        bottom: 16.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          cardbuild("assets/SvgImage/chec.svg", "Check Rate"),
                          cardbuild("assets/SvgImage/picku.svg", "Pick Up"),
                          cardbuild("assets/SvgImage/dro.svg", "Drop Off"),
                          cardbuild("assets/SvgImage/his.svg", "History"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  GridView.builder(
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
                              child:
                                  myList[index]['image'].toString().endsWith(
                                    ".svg",
                                  )
                                  ? SvgPicture.asset(myList[index]['image'])
                                  : Image.asset(myList[index]['image']),
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
                            if (index == 0 || index == 1)
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
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text(
                        "Current Shipment",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF353535),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "View All",
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2490A9),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    padding: EdgeInsets.only(
                      // left: 16.w,
                      // right: 16.w,
                      top: 14.h,
                      bottom: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Color.fromARGB(153, 237, 237, 237),
                      ),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 0,
                          blurRadius: 17.39,
                          offset: Offset(0, 0),
                          color: Color.fromARGB(15, 118, 118, 118),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16.w, right: 16.w),
                          child: Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFFFFF),
                                  border: Border.all(
                                    color: Color.fromARGB(102, 237, 237, 237),
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/SvgImage/id.svg",
                                  width: 20.w,
                                  height: 20.h,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "#HWDSF776567DS",
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF353535),
                                    ),
                                  ),
                                  Text(
                                    "#On the way . 24 June",
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFFABABAB),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              IconButton(
                                style: IconButton.styleFrom(
                                  minimumSize: Size(15.w, 30.h),
                                  padding: EdgeInsets.only(right: 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {},
                                icon: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Color(0xFF353535),
                                  size: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15.h),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnotherStepper(
                                stepperList: [
                                  StepperData(
                                    iconWidget: const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF2490A9),
                                    ),
                                  ),
                                  StepperData(
                                    iconWidget: const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF2490A9),
                                    ),
                                  ),
                                  StepperData(
                                    iconWidget: const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF2490A9),
                                    ),
                                  ),
                                  StepperData(),
                                  StepperData(),
                                ],
                                stepperDirection: Axis.horizontal,
                                activeBarColor: Color(0xFF2490A9),
                                inActiveBarColor: Color(0xFFEDEDED),
                                activeIndex: 2,
                                barThickness: 2,
                              ),
                              SizedBox(height: 10.h),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 16.w,
                                  right: 16.w,
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "From",
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF2490A9),
                                          ),
                                        ),
                                        SizedBox(height: 1),
                                        Text(
                                          "Delhi, India",
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF353535),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "To",
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF2490A9),
                                          ),
                                        ),
                                        SizedBox(height: 1),
                                        Text(
                                          "California, US",
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF353535),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text(
                        "Recent Shipment",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF353535),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "View All",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2490A9),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Shipment(),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
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

class Shipment extends StatefulWidget {
  const Shipment({super.key});

  @override
  State<Shipment> createState() => _ShipmentState();
}

class _ShipmentState extends State<Shipment> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(top: 14.h),
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 14.h,
            bottom: 14.h,
          ),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Color.fromARGB(153, 237, 237, 237)),
            boxShadow: [
              BoxShadow(
                spreadRadius: 0,
                blurRadius: 17.39,
                offset: Offset(0, 0),
                color: Color.fromARGB(15, 118, 118, 118),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFFFFF),
                  border: Border.all(color: Color.fromARGB(102, 237, 237, 237)),
                ),
                child: SvgPicture.asset(
                  "assets/SvgImage/id.svg",
                  width: 20.w,
                  height: 20.h,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#HWDSF776567DS",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF353535),
                    ),
                  ),
                  Text(
                    "#On the way . 24 June",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFABABAB),
                    ),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                style: IconButton.styleFrom(
                  minimumSize: Size(15.w, 30.h),
                  padding: EdgeInsets.only(right: 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Color(0xFF353535),
                  size: 16.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
