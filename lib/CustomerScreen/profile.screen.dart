import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/deliveryHistory.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/login.screen.dart';
import 'package:delivery_mvp_app/data/Model/getProfileModel.dart';
import 'package:delivery_mvp_app/data/controller/getProfileController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var box = Hive.box("folder");
    var token = box.get("token");
    final provider = ref.watch(getProfileController);
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: provider.when(
        data: (profile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80.h),
              Center(
                child: Container(
                  width: 72.w,
                  height: 72.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFA8DADC),
                  ),
                  child: Center(
                    child: Text(
                      // "DE",
                      profile.data!.doc!.firstName![0].toUpperCase() +
                          profile.data!.doc!.lastName![0].toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4F4F4F),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              Center(
                child: Text(
                  "${profile.data!.doc!.firstName} ${profile.data!.doc!.lastName}",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Divider(
                color: Color(0xFFB0B0B0),
                thickness: 1,
                endIndent: 24,
                indent: 24,
              ),
              buildProfile(Icons.payment, "Payment", () {}),
              buildProfile(Icons.history, "Delivery History", () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => DeliveryHistoryScreen(),
                  ),
                );
              }),
              buildProfile(Icons.settings, "Setting", () {}),
              buildProfile(Icons.contact_support, "Support/FAQ", () {}),
              buildProfile(
                Icons.markunread_mailbox_rounded,
                "Invite Friends",
                () {},
              ),
              SizedBox(height: 50.h),
              InkWell(
                onTap: () {
                  box.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Sign out successfully"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(
                        left: 15.w,
                        bottom: 15.h,
                        right: 15.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        side: BorderSide.none,
                      ),
                    ),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 24.w),
                    SvgPicture.asset("assets/SvgImage/signout.svg"),
                    SizedBox(width: 10.w),
                    Text(
                      "Sign out",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(186, 29, 53, 87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          log("${error.toString()} /n ${stackTrace.toString()}");
          return Center(child: Text(error.toString()));
        },
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget buildProfile(IconData icon, String name, VoidCallback ontap) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.only(left: 24.w, top: 25.h),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFFB0B0B0)),
            SizedBox(width: 10.w),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(186, 29, 53, 87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
