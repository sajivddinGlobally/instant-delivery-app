// import 'dart:developer';
// import 'dart:io';
// import 'package:delivery_mvp_app/config/network/api.state.dart';
// import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
// import 'package:delivery_mvp_app/data/Model/updateUserProfileBodyModel.dart';
// import 'package:delivery_mvp_app/data/controller/getProfileController.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';

// class UpdateUserProfilePage extends ConsumerStatefulWidget {
//   const UpdateUserProfilePage({super.key});

//   @override
//   ConsumerState<UpdateUserProfilePage> createState() =>
//       _UpdateUserProfilePageState();
// }

// class _UpdateUserProfilePageState extends ConsumerState<UpdateUserProfilePage> {
//   final firstNameController = TextEditingController();
//   final lastNameController = TextEditingController();
//   bool isLoading = false;

//   File? _image;
//   final picker = ImagePicker();

//   Future pickImageFromGallery() async {
//     var status = await Permission.camera.request();
//     if (status.isGranted) {
//       final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         setState(() {
//           _image = File(pickedFile.path);
//         });
//       }
//     } else {
//       Fluttertoast.showToast(msg: "Gallery permission denied");
//     }
//   }

//   Future pickImageFromCamera() async {
//     var status = await Permission.camera.request();
//     if (status.isGranted) {
//       final pickedFile = await picker.pickImage(source: ImageSource.camera);
//       if (pickedFile != null) {
//         setState(() {
//           _image = File(pickedFile.path);
//         });
//       }
//     } else {
//       Fluttertoast.showToast(msg: "Camera permission denied");
//     }
//   }

//   Future showImage() async {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (context) {
//         return CupertinoActionSheet(
//           actions: [
//             CupertinoActionSheetAction(
//               onPressed: () {
//                 Navigator.pop(context);
//                 pickImageFromGallery();
//               },
//               child: const Text("Gallery"),
//             ),
//             CupertinoActionSheetAction(
//               onPressed: () {
//                 Navigator.pop(context);
//                 pickImageFromCamera();
//               },
//               child: const Text("Camera"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFFFFFFF),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.only(left: 24.w, right: 24.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 66.h),
//               Center(
//                 child: Image.asset(
//                   "assets/scooter.png",
//                   width: 84.w,
//                   height: 72.h,
//                 ),
//               ),
//               SizedBox(height: 28.h),
//               Text(
//                 "Edit Your Profile",
//                 style: GoogleFonts.inter(
//                   fontSize: 20.sp,
//                   fontWeight: FontWeight.w400,
//                   color: Color(0xFF111111),
//                   letterSpacing: -1,
//                 ),
//               ),
//               SizedBox(height: 35.h),
//               TextFormField(
//                 keyboardType: TextInputType.name,
//                 controller: firstNameController,
//                 style: GoogleFonts.inter(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w500,
//                   color: Color(0xFF293540),
//                 ),
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Color(0xFFF0F5F5),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15.r),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15.r),
//                     borderSide: BorderSide(
//                       color: Color(0xFF006970),
//                       width: 1.w,
//                     ),
//                   ),
//                   errorBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15.r),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedErrorBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15.r),
//                     borderSide: BorderSide(color: Colors.red, width: 1.w),
//                   ),
//                   hintText: "First Name",
//                   hintStyle: GoogleFonts.inter(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: Color(0xFF787B7B),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "First Name is required";
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20.h),
//               TextFormField(
//                 keyboardType: TextInputType.name,
//                 controller: lastNameController,
//                 style: GoogleFonts.inter(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w500,
//                   color: Color(0xFF293540),
//                 ),
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Color(0xFFF0F5F5),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15.r),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15.r),
//                     borderSide: BorderSide(
//                       color: Color(0xFF1D3557),
//                       width: 1.w,
//                     ),
//                   ),
//                   errorBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15.r),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedErrorBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15.r),
//                     borderSide: BorderSide(color: Colors.red, width: 1.w),
//                   ),
//                   hintText: "Last Name",
//                   hintStyle: GoogleFonts.inter(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: Color(0xFF787B7B),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Last Name is required";
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20.h),
//               InkWell(
//                 onTap: () {
//                   showImage();
//                 },
//                 child: Center(
//                   child: Container(
//                     width: 300.w,
//                     height: 200.h,
//                     decoration: BoxDecoration(
//                       color: Color(0xFFF0F5F5),
//                       borderRadius: BorderRadius.circular(20.r),
//                     ),
//                     child: _image == null
//                         ? Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.upload_sharp,
//                                 color: Color(0xFF008080),
//                                 size: 30.sp,
//                               ),
//                               SizedBox(height: 8.h),
//                               Text(
//                                 "Upload Image",
//                                 style: GoogleFonts.inter(
//                                   fontSize: 15.sp,
//                                   fontWeight: FontWeight.w400,
//                                   color: Color(0xFF4D4D4D),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : ClipRRect(
//                             borderRadius: BorderRadius.circular(20.r),
//                             child: Image.file(
//                               _image!,
//                               fit: BoxFit.cover,
//                               width: 400.w,
//                               height: 220.h,
//                             ),
//                           ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.h),
//               Center(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: Size(300.w, 50.h),
//                     backgroundColor: const Color(0xFF006970),
//                     padding: EdgeInsets.symmetric(vertical: 16.h),
//                   ),
//                   onPressed: isLoading
//                       ? null
//                       : () async {
//                           setState(() {
//                             isLoading = true;
//                           });

//                           try {
//                             final service = APIStateNetwork(callPrettyDio());

//                             final uploadResponse = await service.uploadImage(
//                               File(_image!.path),
//                             );

//                             log("UPLOAD RESPONSE: ${uploadResponse.data}");

//                             if (uploadResponse.error == false) {
//                               final data = uploadResponse.data;

//                               final uploadedImagePath = data.imageUrl;

//                               if (uploadedImagePath.isEmpty) {
//                                 throw Exception(
//                                   "Image upload failed — no path returned",
//                                 );
//                               }

//                               final body = UpdateUserProfileBodyModel(
//                                 firstName: firstNameController.text,
//                                 lastName: lastNameController.text,
//                                 image: uploadedImagePath,
//                               );

//                               final updateResponse = await service
//                                   .updateCutomerProfile(body);

//                               if (updateResponse.code == 0) {
//                                 Fluttertoast.showToast(
//                                   msg: updateResponse.message,
//                                 );
//                                 Navigator.pop(context);
//                                 ref.invalidate(getProfileController);
//                               } else {
//                                 Fluttertoast.showToast(
//                                   msg: updateResponse.message,
//                                 );
//                               }
//                             } else {
//                               Fluttertoast.showToast(
//                                 msg: "Image upload failed",
//                               );
//                             }
//                           } catch (e, st) {
//                             log("Error: $e\n$st");
//                             Fluttertoast.showToast(msg: "API Error: $e");
//                           } finally {
//                             setState(() {
//                               isLoading = false;
//                             });
//                           }
//                         },
//                   child: isLoading
//                       ? Center(
//                           child: SizedBox(
//                             width: 30.w,
//                             height: 30.h,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2.w,
//                             ),
//                           ),
//                         )
//                       : Text(
//                           "Update",
//                           style: GoogleFonts.inter(
//                             fontSize: 15.sp,
//                             fontWeight: FontWeight.w500,
//                             color: const Color(0xFFFFFFFF),
//                           ),
//                         ),
//                 ),
//               ),

//               SizedBox(height: 14.h),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'dart:io';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/updateUserProfileBodyModel.dart';
import 'package:delivery_mvp_app/data/controller/getProfileController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateUserProfilePage extends ConsumerStatefulWidget {
  const UpdateUserProfilePage({super.key});

  @override
  ConsumerState<UpdateUserProfilePage> createState() =>
      _UpdateUserProfilePageState();
}

class _UpdateUserProfilePageState extends ConsumerState<UpdateUserProfilePage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  bool isLoading = false;
  File? _image;
  final picker = ImagePicker();

  Future pickImageFromGallery() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else {
      Fluttertoast.showToast(msg: "Gallery permission denied");
    }
  }

  Future pickImageFromCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else {
      Fluttertoast.showToast(msg: "Camera permission denied");
    }
  }

  Future showImage() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImageFromGallery();
              },
              child: const Text("Gallery"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImageFromCamera();
              },
              child: const Text("Camera"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(getProfileController);

    return Scaffold(
      backgroundColor: Colors.white,
      body: profile.when(
        data: (profileData) {
          // ✅ Prefill data only once when loaded
          if (firstNameController.text.isEmpty &&
              profileData.data?.doc?.firstName != null) {
            firstNameController.text = profileData.data!.doc!.firstName!;
          }
          if (lastNameController.text.isEmpty &&
              profileData.data?.doc?.lastName != null) {
            lastNameController.text = profileData.data!.doc!.lastName!;
          }

          final existingImage = profileData.data?.doc?.image ?? '';

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50.h),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006970),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      "assets/scooter.png",
                      width: 84.w,
                      height: 72.h,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Edit Your Profile",
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF111111),
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: 35.h),
                  TextFormField(
                    controller: firstNameController,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF293540),
                    ),
                    decoration: InputDecoration(
                      labelText: "First Name",
                      labelStyle: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF006970),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF0F5F5),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide(
                          color: const Color(0xFF006970).withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: const BorderSide(
                          color: Color(0xFF006970),
                          width: 1.5,
                        ),
                      ),
                      hintText: "Enter First Name",
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF787B7B),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: lastNameController,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF293540),
                    ),
                    decoration: InputDecoration(
                      labelText: "Last Name",
                      labelStyle: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF006970),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF0F5F5),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide(
                          color: const Color(0xFF006970).withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: const BorderSide(
                          color: Color(0xFF006970),
                          width: 1.5,
                        ),
                      ),
                      hintText: "Enter Last Name",
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF787B7B),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // InkWell(
                  //   onTap: () {
                  //     showImage();
                  //   },
                  //   child: Center(
                  //     child: Container(
                  //       width: 300.w,
                  //       height: 200.h,
                  //       decoration: BoxDecoration(
                  //         color: Color(0xFFF0F5F5),
                  //         borderRadius: BorderRadius.circular(20.r),
                  //         border: Border.all(
                  //           color: Color(0xFF006970).withOpacity(0.3),
                  //           width: 1.w,
                  //         ),
                  //       ),
                  //       child: _image != null
                  //           ? ClipRRect(
                  //               borderRadius: BorderRadius.circular(20.r),
                  //               child: Image.file(
                  //                 _image!,
                  //                 fit: BoxFit.cover,
                  //                 width: 400.w,
                  //                 height: 220.h,
                  //               ),
                  //             )
                  //           : (existingImage.isNotEmpty
                  //                 ? ClipRRect(
                  //                     borderRadius: BorderRadius.circular(20.r),
                  //                     child: Image.network(
                  //                       existingImage.startsWith("http")
                  //                           ? existingImage
                  //                           : "https://weloads.com$existingImage",
                  //                       fit: BoxFit.cover,
                  //                       width: 400.w,
                  //                       height: 220.h,
                  //                       errorBuilder:
                  //                           (context, error, stackTrace) =>
                  //                               Icon(
                  //                                 Icons.person,
                  //                                 size: 40.sp,
                  //                                 color: Colors.grey,
                  //                               ),
                  //                     ),
                  //                   )
                  //                 : Column(
                  //                     mainAxisAlignment:
                  //                         MainAxisAlignment.center,
                  //                     children: [
                  //                       Icon(
                  //                         Icons.upload_sharp,
                  //                         color: Color(0xFF008080),
                  //                         size: 30.sp,
                  //                       ),
                  //                       SizedBox(height: 8.h),
                  //                       Text(
                  //                         "Upload Image",
                  //                         style: GoogleFonts.inter(
                  //                           fontSize: 15.sp,
                  //                           fontWeight: FontWeight.w400,
                  //                           color: Color(0xFF4D4D4D),
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   )),
                  //     ),
                  //   ),
                  // ),
                  InkWell(
                    onTap: showImage,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 300.w,
                            height: 200.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F5F5),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: const Color(0xFF006970).withOpacity(0.3),
                                width: 1.w,
                              ),
                            ),
                            child: _image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20.r),
                                    child: Image.file(
                                      _image!,
                                      fit: BoxFit.cover,
                                      width: 400.w,
                                      height: 220.h,
                                    ),
                                  )
                                : (existingImage.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                          child: Image.network(
                                            existingImage.startsWith("http")
                                                ? existingImage
                                                : "https://weloads.com$existingImage",
                                            fit: BoxFit.cover,
                                            width: 400.w,
                                            height: 220.h,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: Colors.grey,
                                                    ),
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.upload_rounded,
                                              color: const Color(0xFF008080),
                                              size: 40.sp,
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              "Upload Image",
                                              style: GoogleFonts.inter(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF4D4D4D),
                                              ),
                                            ),
                                          ],
                                        )),
                          ),

                          // ✏️ Small edit icon overlay
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006970),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // “Tap to change” text overlay (only when image exists)
                          if (_image != null || existingImage.isNotEmpty)
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Text(
                                "Tap to change",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9),
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(300.w, 50.h),
                        backgroundColor: const Color(0xFF006970),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() {
                                isLoading = true;
                              });

                              try {
                                final service = APIStateNetwork(
                                  callPrettyDio(),
                                );

                                String uploadedImagePath = existingImage;

                                // ✅ Upload image only if user selected a new one
                                if (_image != null) {
                                  final uploadResponse = await service
                                      .uploadImage(File(_image!.path));
                                  log(
                                    "UPLOAD RESPONSE: ${uploadResponse.data}",
                                  );

                                  if (uploadResponse.error == false) {
                                    uploadedImagePath =
                                        uploadResponse.data.imageUrl;
                                  } else {
                                    throw Exception("Image upload failed");
                                  }
                                }

                                final body = UpdateUserProfileBodyModel(
                                  firstName: firstNameController.text,
                                  lastName: lastNameController.text,
                                  image: uploadedImagePath,
                                );

                                final updateResponse = await service
                                    .updateCutomerProfile(body);

                                if (updateResponse.code == 0) {
                                  Fluttertoast.showToast(
                                    msg: updateResponse.message,
                                  );
                                  ref.invalidate(getProfileController);
                                  Navigator.pop(context);
                                } else {
                                  Fluttertoast.showToast(
                                    msg: updateResponse.message,
                                  );
                                }
                              } catch (e, st) {
                                log("Error: $e\n$st");
                                Fluttertoast.showToast(msg: "API Error: $e");
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                      child: isLoading
                          ? Center(
                              child: SizedBox(
                                width: 30.w,
                                height: 30.h,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.w,
                                ),
                              ),
                            )
                          : Text(
                              "Update",
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                ],
              ),
            ),
          );
        },
        error: (err, st) => Center(child: Text("Error: $err")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
