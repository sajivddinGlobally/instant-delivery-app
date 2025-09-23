import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectPaymentScreen extends StatefulWidget {
  const SelectPaymentScreen({super.key});

  @override
  State<SelectPaymentScreen> createState() => _SelectPaymentScreenState();
}

class _SelectPaymentScreenState extends State<SelectPaymentScreen> {
  String? selectedMethod;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Row(
            children: [
              SizedBox(width: 20.w),
              FloatingActionButton(
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
              SizedBox(width: 20.w),
              Text(
                "Payment",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
          SizedBox(height: 23.h),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 65.h,
            decoration: BoxDecoration(color: Color(0xFFEDEDED)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 25.w),
                Text(
                  "Business",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Text(
              "You haven't added any business profiles to show here",
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: Color(0xFF000000),
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: MediaQuery.of(context).size.width,
            height: 42.h,
            decoration: BoxDecoration(color: Color(0xFFEDEDED)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 25.w),
                Text(
                  "Add business account",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF086E86),
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.add, color: Color(0xFF086E86)),
                ),
                SizedBox(width: 10.w),
              ],
            ),
          ),
          Column(
            children: [
              paymentCard("cash", "assets/SvgImage/cas.svg", "Cash"),
              Divider(color: Color(0xFF78778D)),
              paymentCard("**** 3919", "assets/SvgImage/se.svg", "**** 3919"),
              Divider(color: Color(0xFF78778D)),
              paymentCard("**** 8980", "assets/SvgImage/v.svg", "**** 8980"),
              Divider(color: Color(0xFF78778D)),
              paymentCard("Point", "assets/SvgImage/yello.svg", "Point"),
              Divider(color: Color(0xFF78778D)),
              paymentCard(
                "Pay With LankaQR/UPI/Alipay",
                "assets/SvgImage/lanka.svg",
                "Pay With LankaQR/UPI/Alipay",
              ),
            ],
          ),

          Divider(color: Color(0xFF78778D)),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 25.w),
              Text(
                "Add Payment Method",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF086E86),
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.add, color: Color(0xFF086E86)),
              ),
              SizedBox(width: 10.w),
            ],
          ),
        ],
      ),
    );
  }

  Widget paymentCard(String methodValue, String iconPath, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 25.w, right: 20.w),
      child: Row(
        children: [
          Radio<String>(
            value: methodValue,
            groupValue: selectedMethod,
            onChanged: (value) {
              setState(() {
                selectedMethod = value;
              });
            },
            activeColor: Color(0xFF086E86), // 🔹 fill color
          ),
          // SizedBox(width: 10.w),
          SvgPicture.asset(iconPath),
          SizedBox(width: 10.w),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF000000),
              letterSpacing: -1,
            ),
          ),
          Spacer(),
          Icon(Icons.arrow_forward_ios, color: Color(0xFF000000), weight: 1.w),
        ],
      ),
    );
  }
}
