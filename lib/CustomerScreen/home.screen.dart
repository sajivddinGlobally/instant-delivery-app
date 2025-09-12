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
      "image": "assets/SvgImage/sco.svg",
      "name": "Bike",
      //"title": "Choose from Our Fleet",
    },
    {
      "image": "assets/SvgImage/tempo.svg",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: 440.w,
              height: 848.h,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.50, -0.00),
                  end: Alignment(0.50, 1.00),
                  colors: [const Color(0xFF82ECF3), Colors.white],
                ),
              ),
            ),
            SvgPicture.asset("assets/SvgImage/bg.svg"),
            Positioned(
              top: 40.h,
              left: 24.w,
              right: 24.w,
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
                ],
              ),
            ),
          ],
        ),
      ),

      // body: SingleChildScrollView(
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Stack(
      //         clipBehavior: Clip.none,
      //         children: [
      //           Container(
      //             width: 393.w,
      //             height: 260.h,
      //             decoration: BoxDecoration(color: Color(0xFF006970)),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 SizedBox(height: 50.h),
      //                 Row(
      //                   children: [
      //                     SizedBox(width: 24.w),
      //                     Container(
      //                       width: 40.w,
      //                       height: 40.h,
      //                       decoration: BoxDecoration(
      //                         shape: BoxShape.circle,
      //                         color: Colors.grey,
      //                       ),
      //                       child: Image.asset(
      //                         "assets/profile.png",
      //                         fit: BoxFit.contain,
      //                       ),
      //                     ),
      //                     Spacer(),
      //                     Column(
      //                       crossAxisAlignment: CrossAxisAlignment.center,
      //                       children: [
      //                         Row(
      //                           children: [
      //                             Text(
      //                               "Noida Sector 75",
      //                               style: GoogleFonts.inter(
      //                                 fontSize: 13.sp,
      //                                 fontWeight: FontWeight.w500,
      //                                 color: Color(0xFFFFFFFF),
      //                               ),
      //                             ),
      //                             Icon(
      //                               Icons.keyboard_arrow_down_outlined,
      //                               color: Colors.white,
      //                               size: 22.sp,
      //                             ),
      //                           ],
      //                         ),
      //                         Text(
      //                           "Golf city, Plot 8, Sector 75",
      //                           style: GoogleFonts.inter(
      //                             fontSize: 13.sp,
      //                             fontWeight: FontWeight.w500,
      //                             color: Color(0xFF99C3C6),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                     Spacer(),
      //                     Container(
      //                       width: 40.w,
      //                       height: 40.h,
      //                       decoration: BoxDecoration(
      //                         shape: BoxShape.circle,
      //                         border: Border.all(color: Color(0xFF33878D)),
      //                       ),
      //                       child: Icon(
      //                         Icons.notifications_none,
      //                         color: Colors.white,
      //                       ),
      //                     ),
      //                     SizedBox(width: 24.w),
      //                   ],
      //                 ),
      //                 SizedBox(height: 25.h),
      //                 Padding(
      //                   padding: EdgeInsets.only(left: 24.w),
      //                   child: Text(
      //                     "Let’s Track your package",
      //                     style: GoogleFonts.inter(
      //                       fontSize: 18.sp,
      //                       fontWeight: FontWeight.w400,
      //                       color: Color(0xFFFFFFFF),
      //                       letterSpacing: -1,
      //                     ),
      //                   ),
      //                 ),
      //                 SizedBox(height: 15.h),
      //                 Container(
      //                   margin: EdgeInsets.only(left: 24.w, right: 24.w),
      //                   child: TextField(
      //                     decoration: InputDecoration(
      //                       contentPadding: EdgeInsets.only(
      //                         left: 15.w,
      //                         right: 15.w,
      //                         top: 10.h,
      //                         bottom: 10.h,
      //                       ),
      //                       filled: true,
      //                       fillColor: Color(0xFFFFFFFF),
      //                       enabledBorder: OutlineInputBorder(
      //                         borderRadius: BorderRadius.circular(8.r),
      //                         borderSide: BorderSide.none,
      //                       ),
      //                       focusedBorder: OutlineInputBorder(
      //                         borderRadius: BorderRadius.circular(8.r),
      //                         borderSide: BorderSide.none,
      //                       ),
      //                       hintText: "Enter your tracking number",
      //                       hintStyle: GoogleFonts.inter(
      //                         fontSize: 14.sp,
      //                         fontWeight: FontWeight.w400,
      //                         color: Color(0xFFCCCCCC),
      //                       ),
      //                       prefixIcon: Icon(
      //                         Icons.search,
      //                         color: Color(0xFF2490A9),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           Positioned(
      //             bottom: -28.h,
      //             left: 24.w,
      //             right: 24.w,
      //             child: Container(
      //               width: 345.w,
      //               height: 90,
      //               decoration: BoxDecoration(
      //                 color: Color(0xFFFFFFFF),
      //                 borderRadius: BorderRadius.circular(8.r),
      //                 border: Border.all(
      //                   color: Color.fromARGB(51, 237, 237, 237),
      //                   width: 1.w,
      //                 ),
      //                 boxShadow: [
      //                   BoxShadow(
      //                     blurRadius: 15,
      //                     spreadRadius: 0,
      //                     offset: Offset(0, 0),
      //                     color: Color.fromARGB(15, 118, 118, 118),
      //                   ),
      //                 ],
      //               ),
      //               child: Padding(
      //                 padding: EdgeInsets.only(left: 24.w, right: 24.w),
      //                 child: Row(
      //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                   children: [
      //                     cardbuild("assets/SvgImage/check.svg", "Check Rate"),
      //                     cardbuild("assets/SvgImage/pickup.svg", "Pick Up"),
      //                     cardbuild("assets/SvgImage/drop.svg", "Drop Off"),
      //                     cardbuild("assets/SvgImage/history.svg", "History"),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //       SizedBox(height: 50.h),
      //       Container(
      //         margin: EdgeInsets.only(left: 24.w, right: 24.w),
      //         child: GridView.builder(
      //           itemCount: myList.length,
      //           padding: EdgeInsets.zero,
      //           shrinkWrap: true,
      //           physics: NeverScrollableScrollPhysics(),
      //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //             crossAxisCount: 2,
      //             crossAxisSpacing: 20.w,
      //             mainAxisSpacing: 20.w,
      //             childAspectRatio: 0.80,
      //           ),
      //           itemBuilder: (context, index) {
      //             return Container(
      //               width: 158.w,
      //               height: 181.h,
      //               decoration: BoxDecoration(
      //                 borderRadius: BorderRadius.circular(8.r),
      //                 border: Border.all(color: Color(0xFFE8E8E8)),
      //               ),
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   SizedBox(height: 30.h),
      //                   Center(
      //                     child: SvgPicture.asset(
      //                       //"assets/SvgImage/truc.svg",
      //                       myList[index]['image'],
      //                     ),
      //                   ),
      //                   Padding(
      //                     padding: EdgeInsets.only(left: 9.w, top: 4.h),
      //                     child: Text(
      //                       // "Trucks",
      //                       myList[index]['name'],
      //                       style: GoogleFonts.inter(
      //                         fontSize: 18.sp,
      //                         fontWeight: FontWeight.w700,
      //                         color: Color(0xFF000000),
      //                         letterSpacing: -1,
      //                       ),
      //                     ),
      //                   ),
      //                   if (index == 0 || index == 1)
      //                     Padding(
      //                       padding: EdgeInsets.only(left: 9.w),
      //                       child: Text(
      //                         //  "Choose from Our Fleet",
      //                         myList[index]['title'],
      //                         style: GoogleFonts.inter(
      //                           fontSize: 14.sp,
      //                           fontWeight: FontWeight.w400,
      //                           color: Color(0xFF000000),
      //                           letterSpacing: -1,
      //                         ),
      //                       ),
      //                     ),
      //                 ],
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //       SizedBox(height: 30.h),
      //       Row(
      //         children: [
      //           SizedBox(width: 24.w),
      //           Text(
      //             "Current Shipment",
      //             style: GoogleFonts.inter(
      //               fontSize: 14.sp,
      //               fontWeight: FontWeight.w500,
      //               color: Color(0xFF353535),
      //             ),
      //           ),
      //           Spacer(),
      //           Text(
      //             "View All",
      //             style: GoogleFonts.inter(
      //               fontSize: 13.sp,
      //               fontWeight: FontWeight.w500,
      //               color: Color(0xFF2490A9),
      //             ),
      //           ),
      //           SizedBox(width: 24.w),
      //         ],
      //       ),
      //       SizedBox(height: 16.h),
      //       Padding(
      //         padding: EdgeInsets.only(left: 24.w, right: 24.w),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Container(
      //               padding: EdgeInsets.only(
      //                 left: 16.w,
      //                 right: 16.w,
      //                 top: 14.h,
      //                 bottom: 14.h,
      //               ),
      //               decoration: BoxDecoration(
      //                 color: Color(0xFFFFFFFF),
      //                 borderRadius: BorderRadius.circular(8),
      //                 border: Border.all(
      //                   color: Color.fromARGB(153, 237, 237, 237),
      //                 ),
      //               ),
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Row(
      //                     children: [
      //                       Container(
      //                         width: 40.w,
      //                         height: 40.h,
      //                         decoration: BoxDecoration(
      //                           shape: BoxShape.circle,
      //                           color: Color(0xFFFFFFFF),
      //                           border: Border.all(
      //                             color: Color.fromARGB(102, 237, 237, 237),
      //                           ),
      //                         ),
      //                         child: SvgPicture.asset(
      //                           "assets/SvgImage/id.svg",
      //                           width: 20.w,
      //                           height: 20.h,
      //                         ),
      //                       ),
      //                       SizedBox(width: 12.w),
      //                       Column(
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         children: [
      //                           Text(
      //                             "#HWDSF776567DS",
      //                             style: GoogleFonts.inter(
      //                               fontSize: 13.sp,
      //                               fontWeight: FontWeight.w600,
      //                               color: Color(0xFF353535),
      //                             ),
      //                           ),
      //                           Text(
      //                             "#On the way . 24 June",
      //                             style: GoogleFonts.inter(
      //                               fontSize: 12.sp,
      //                               fontWeight: FontWeight.w400,
      //                               color: Color(0xFFABABAB),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                       Spacer(),
      //                       IconButton(
      //                         style: IconButton.styleFrom(
      //                           minimumSize: Size(15.w, 30.h),
      //                           padding: EdgeInsets.only(right: 0),
      //                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //                         ),
      //                         onPressed: () {},
      //                         icon: Icon(
      //                           Icons.arrow_forward_ios_outlined,
      //                           color: Color(0xFF353535),
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                   SizedBox(height: 15.h),
      //                   Row(
      //                     children: [
      //                       /// Line with circles
      //                       Expanded(
      //                         child: Row(
      //                           children: [
      //                             Expanded(
      //                               child: Container(
      //                                 height: 2,
      //                                 color: Colors.teal,
      //                               ),
      //                             ),
      //                             const Icon(
      //                               Icons.check_circle,
      //                               color: Colors.teal,
      //                             ),
      //                             Expanded(
      //                               child: Container(
      //                                 height: 2,
      //                                 color: Colors.teal,
      //                               ),
      //                             ),
      //                             const Icon(
      //                               Icons.radio_button_checked,
      //                               color: Colors.teal,
      //                             ),
      //                             Expanded(
      //                               child: Container(
      //                                 height: 2,
      //                                 decoration: const BoxDecoration(
      //                                   border: Border(
      //                                     top: BorderSide(
      //                                       color: Colors.teal,
      //                                       width: 2,
      //                                       style: BorderStyle.solid,
      //                                     ),
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                             const Icon(
      //                               Icons.radio_button_unchecked,
      //                               color: Colors.grey,
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                       const SizedBox(width: 8),

      //                       // Column(
      //                       //   crossAxisAlignment: CrossAxisAlignment.end,
      //                       //   children: const [
      //                       //     Icon(
      //                       //       Icons.radio_button_unchecked,
      //                       //       color: Colors.grey,
      //                       //     ),
      //                       //     SizedBox(height: 4),
      //                       //     Text(
      //                       //       "To",
      //                       //       style: TextStyle(
      //                       //         fontSize: 12,
      //                       //         color: Colors.grey,
      //                       //       ),
      //                       //     ),
      //                       //     Text(
      //                       //       "California, US",
      //                       //       style: TextStyle(
      //                       //         fontWeight: FontWeight.w500,
      //                       //         fontSize: 13,
      //                       //       ),
      //                       //     ),
      //                       //   ],
      //                       // ),
      //                     ],
      //                   ),
      //                 ],
      //               ),
      //             ),

      //             // /// Progress line
      //             // Row(
      //             //   children: [
      //             //     /// From
      //             //     Column(
      //             //       crossAxisAlignment: CrossAxisAlignment.start,
      //             //       children: const [
      //             //         Icon(Icons.check_circle, color: Colors.teal),
      //             //         SizedBox(height: 4),
      //             //         Text(
      //             //           "From",
      //             //           style: TextStyle(fontSize: 12, color: Colors.grey),
      //             //         ),
      //             //         Text(
      //             //           "Delhi, India",
      //             //           style: TextStyle(
      //             //             fontWeight: FontWeight.w500,
      //             //             fontSize: 13,
      //             //           ),
      //             //         ),
      //             //       ],
      //             //     ),

      //             //     const SizedBox(width: 8),

      //             //     /// Line with circles
      //             //     Expanded(
      //             //       child: Row(
      //             //         children: [
      //             //           Expanded(
      //             //             child: Container(height: 2, color: Colors.teal),
      //             //           ),
      //             //           const Icon(Icons.check_circle, color: Colors.teal),
      //             //           Expanded(
      //             //             child: Container(height: 2, color: Colors.teal),
      //             //           ),
      //             //           const Icon(
      //             //             Icons.radio_button_checked,
      //             //             color: Colors.teal,
      //             //           ),
      //             //           Expanded(
      //             //             child: Container(
      //             //               height: 2,
      //             //               decoration: const BoxDecoration(
      //             //                 border: Border(
      //             //                   top: BorderSide(
      //             //                     color: Colors.teal,
      //             //                     width: 2,
      //             //                     style: BorderStyle.solid,
      //             //                   ),
      //             //                 ),
      //             //               ),
      //             //             ),
      //             //           ),
      //             //           const Icon(
      //             //             Icons.radio_button_unchecked,
      //             //             color: Colors.grey,
      //             //           ),
      //             //         ],
      //             //       ),
      //             //     ),

      //             //     const SizedBox(width: 8),

      //             //     /// To
      //             //     // Column(
      //             //     //   crossAxisAlignment: CrossAxisAlignment.end,
      //             //     //   children: const [
      //             //     //     Icon(
      //             //     //       Icons.radio_button_unchecked,
      //             //     //       color: Colors.grey,
      //             //     //     ),
      //             //     //     SizedBox(height: 4),
      //             //     //     Text(
      //             //     //       "To",
      //             //     //       style: TextStyle(fontSize: 12, color: Colors.grey),
      //             //     //     ),
      //             //     //     Text(
      //             //     //       "California, US",
      //             //     //       style: TextStyle(
      //             //     //         fontWeight: FontWeight.w500,
      //             //     //         fontSize: 13,
      //             //     //       ),
      //             //     //     ),
      //             //     //   ],
      //             //     // ),
      //             //   ],
      //             // ),
      //           ],
      //         ),
      //       ),
      //       SizedBox(height: 30.h),
      //     ],
      //   ),
      // ),
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
