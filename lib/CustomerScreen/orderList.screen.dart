import 'dart:developer';
import 'package:delivery_mvp_app/data/controller/getDeliveryHistoryController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  @override
  Widget build(BuildContext context) {
    final historyProvier = ref.watch(getDeliveryHistoryController);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 50.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order",
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Divider(),
            SizedBox(height: 15.h),
            historyProvier.when(
              data: (order) {
                final completedDeliveries = order.data.deliveries
                    .where(
                      (delivery) =>
                          delivery.status?.toLowerCase() == "completed",
                    )
                    .toList();

                if (completedDeliveries.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        "No completed orders found",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  );
                }
                DateTime date = DateTime.fromMillisecondsSinceEpoch(
                  1761395019837,
                );
                String formattedDate = DateFormat(
                  "dd MMMM yyyy, h:mma",
                ).format(date);

                return Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: order.data.deliveries.length,
                    itemBuilder: (context, index) {
                      final item = completedDeliveries[index];
                      return Card(
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(14.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.network(
                                    //  "assets/car.png",
                                    item.image ??
                                        "https://www.shutterstock.com/image-vector/no-image-vector-symbol-missing-260nw-1310632172.jpg",
                                    width: 60.w,
                                    height: 40.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                        "https://www.shutterstock.com/image-vector/no-image-vector-symbol-missing-260nw-1310632172.jpg",
                                        width: 60.w,
                                        height: 40.h,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          // "TATA Car",
                                          item.name ?? "N/A",
                                          style: GoogleFonts.inter(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          //  "16 Sep 2025, 10:32 AM",
                                          DateFormat("dd MMMM yyyy, h:mma")
                                              .format(
                                                DateTime.fromMillisecondsSinceEpoch(
                                                  item.createdAt,
                                                ),
                                              )
                                              .toLowerCase(),
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    // "₹570.00",
                                    "₹${item.userPayAmount.toString()}",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16.sp,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                              SizedBox(height: 18.h),
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: const Color(0xFFF0F0F0),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: const Color(0xFF086E86),
                                          size: 13.sp,
                                        ),
                                        for (int i = 0; i < 7; i++) ...[
                                          SizedBox(height: 5.h),
                                          CircleAvatar(
                                            backgroundColor: const Color(
                                              0xFF28B877,
                                            ),
                                            radius: 2.r,
                                          ),
                                        ],
                                        SizedBox(height: 6.h),
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: const Color(0xFFDE4B65),
                                          size: 18.sp,
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 14.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "${item.name} - ",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFF77869E,
                                                    ),
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "${item.mobNo}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(
                                                      0xFF77869E,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            //  "Aara Machine St. Kundan Nagar, Jaipur, Rajasthan 302018",
                                            item.pickup.name.toString(),
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black54,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          // SizedBox(height: 18.h),
                                          // Text.rich(
                                          //   TextSpan(
                                          //     children: [
                                          //       TextSpan(
                                          //         text: "Rizwan Shaikh - ",
                                          //         style: GoogleFonts.inter(
                                          //           fontSize: 14.sp,
                                          //           fontWeight: FontWeight.w600,
                                          //           color: const Color(
                                          //             0xFF77869E,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //       TextSpan(
                                          //         text: "9876543210",
                                          //         style: GoogleFonts.inter(
                                          //           fontSize: 13.sp,
                                          //           fontWeight: FontWeight.w500,
                                          //           color: const Color(
                                          //             0xFF77869E,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                          SizedBox(height: 18.h),
                                          Text(
                                            // "Gopalpura Bypass Rd, Tonk Phatak, Jaipur, Rajasthan 302015",
                                            item.dropoff.name.toString(),
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black54,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF086634),
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    "Completed Order",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF086634),
                                    ),
                                  ),
                                  // Spacer(),
                                  // ElevatedButton(
                                  //   style: ElevatedButton.styleFrom(
                                  //     backgroundColor: Color(0xFF006970),
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(10.r),
                                  //       side: BorderSide.none,
                                  //     ),
                                  //   ),
                                  //   onPressed: () {},
                                  //   child: Text(
                                  //     "Booking Again",
                                  //     style: GoogleFonts.inter(
                                  //       fontSize: 13.sp,
                                  //       fontWeight: FontWeight.w500,
                                  //       color: Colors.white,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              error: (error, stackTrace) {
                log("${error.toString()} /n ${stackTrace.toString()}");
                return Center(child: Text(error.toString()));
              },
              loading: () => Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
