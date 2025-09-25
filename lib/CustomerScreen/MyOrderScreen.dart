import 'package:another_stepper/widgets/another_stepper.dart';
import 'package:delivery_mvp_app/CustomerScreen/productFillDetaisl.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  String? selectedMethod;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: FloatingActionButton(
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50.h),
          Center(
            child: Text(
              "Checkout",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
          ),
          SizedBox(height: 50.h),
          Container(
            margin: EdgeInsets.only(left: 20.w),
            child: Text(
              "Your Order",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TimelineTile(
                  alignment: TimelineAlign.start,
                  lineXY: 2.0,
                  isFirst: true,
                  indicatorStyle: IndicatorStyle(
                    width: 20.w,
                    height: 20.h,
                    color: Color(0xFF086E86),
                  ),
                  beforeLineStyle: LineStyle(
                    color: Color.fromARGB(104, 120, 119, 141),
                    thickness: 2.w,
                  ),
                  endChild: Padding(
                    padding: EdgeInsets.only(top: 15.h, left: 10.w),
                    child: _buildAddressCard(
                      name: "Shaikh niyo",
                      address:
                          "4517 Washington Ave. Manchester, Kentucky 39495",
                      phone: "(209) 555-0121",
                    ),
                  ),
                ),
                TimelineTile(
                  alignment: TimelineAlign.start,
                  lineXY: 2.0,
                  isLast: true,
                  indicatorStyle: IndicatorStyle(
                    width: 20.w,
                    height: 20.h,
                    color: Color(0xFF086E86),
                  ),
                  beforeLineStyle: LineStyle(
                    color: Color.fromARGB(104, 120, 119, 141),
                    thickness: 2.w,
                  ),
                  endChild: Padding(
                    padding: EdgeInsets.only(top: 20.h, left: 10.w),
                    child: _buildAddressCard(
                      name: "Arlene McCoy",
                      address: "8502 Preston Rd. Inglewood, Maine 98380",
                      phone: "(308) 555-0121",
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            margin: EdgeInsets.only(left: 20.w),
            child: Text(
              "Payment Method",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
          ),
          paymentCard(
            "Master Card",
            "assets/SvgImage/se.svg",
            "Master Card",
            "5689 4700 2589 9658",
          ),
          SizedBox(height: 10.h),
          Divider(color: Color.fromARGB(102, 120, 119, 141), thickness: 2),
          Container(
            margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Shipping Fee",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF000000),
                      ),
                    ),
                    Text(
                      "₹ 300",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Discount",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF000000),
                      ),
                    ),
                    Text(
                      "₹ 2",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Divider(color: Color.fromARGB(102, 120, 119, 141), thickness: 2),
          Container(
            margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                Text(
                  "₹ 298",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
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
                    builder: (context) => ProductFillDetaislScreen(),
                  ),
                );
              },
              child: Text(
                "Pay Now",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard({
    required String name,
    required String address,
    required String phone,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            color: Color.fromARGB(127, 0, 0, 0),
            letterSpacing: -0.55,
          ),
        ),
        Text(
          address,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            color: Color(0xFF000000),
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          phone,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            color: Color.fromARGB(127, 0, 0, 0),
            letterSpacing: -0.55,
          ),
        ),
      ],
    );
  }

  Widget paymentCard(
    String methodValue,
    String iconPath,
    String title,
    String subtitle,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          // Toggle logic 👇
          if (selectedMethod == methodValue) {
            selectedMethod = null; // unselect
          } else {
            selectedMethod = methodValue; // select
          }
        });
      },
      child: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
        child: Row(
          children: [
            SvgPicture.asset(iconPath),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF000000),
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(127, 0, 0, 0),
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            Spacer(),
            Radio<String>(
              value: methodValue,
              groupValue: selectedMethod,
              onChanged: (value) {
                setState(() {
                  if (selectedMethod == value) {
                    selectedMethod = null; // already selected → unselect
                  } else {
                    selectedMethod = value; // select new
                  }
                });
              },
              activeColor: Color(0xFF086E86), // 🔹 fill color
            ),
          ],
        ),
      ),
    );
  }
}
