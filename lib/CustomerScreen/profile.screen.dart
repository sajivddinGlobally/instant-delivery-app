import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/deliveryHistory.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/login.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/support.page.dart';

import 'package:delivery_mvp_app/CustomerScreen/updateUserProfile.page.dart';
import 'package:delivery_mvp_app/data/Model/getProfileModel.dart';

import 'package:delivery_mvp_app/data/controller/getProfileController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProfileScreen extends ConsumerStatefulWidget {
  final IO.Socket socket;
  const ProfileScreen(this.socket, {super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> showLogoutDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                log("Clear data....");
                Navigator.pop(context);

                final box = await Hive.box("folder");

                await box.clear();

                Fluttertoast.showToast(msg: "Sign out successfully");

                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
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
                    color: const Color(0xFFA8DADC),
                  ),
                  child: Center(
                    child:
                        (profile.data?.empty?.activePaths?.paths?.image !=
                                null &&
                            profile
                                .data!
                                .empty!
                                .activePaths!
                                .paths!
                                .image!
                                .isNotEmpty)
                        ? ClipOval(
                            child: Image.network(
                              profile.data!.doc!.image ??
                                  "https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png",
                              fit: BoxFit.cover,
                              width: 72.w,
                              height: 72.h,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.person,
                                    size: 40.sp,
                                    color: Colors.grey,
                                  ),
                            ),
                          )
                        : Text(
                            "${profile.data?.doc?.firstName?[0].toUpperCase() ?? ''}${profile.data?.doc?.lastName?[0].toUpperCase() ?? ''}",
                            style: GoogleFonts.inter(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4F4F4F),
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
              buildProfile(Icons.edit, "Edit Profile", () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => UpdateUserProfilePage(),
                  ),
                );
              }),
              buildProfile(Icons.payment, "Payment", () {}),
              buildProfile(Icons.history, "Delivery History", () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => DeliveryHistoryScreen(widget.socket),
                  ),
                );
              }),

              buildProfile(Icons.contact_support, "Support/FAQ", () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => SupportPage(widget.socket),
                  ),
                );
              }),
              //buildProfile(Icons.settings, "Setting", () {}),
              // buildProfile(
              //   Icons.markunread_mailbox_rounded,
              //   "Invite Friends",
              //   () {
              //   },
              // ),
              SizedBox(height: 50.h),
              InkWell(
                onTap: () {
                  showLogoutDialog();
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
