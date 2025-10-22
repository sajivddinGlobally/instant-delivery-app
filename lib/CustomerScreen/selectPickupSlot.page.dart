import 'package:delivery_mvp_app/CustomerScreen/packerMover.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SelectPickupSlotPage extends StatefulWidget {
  const SelectPickupSlotPage({super.key});

  @override
  State<SelectPickupSlotPage> createState() => _SelectPickupSlotPageState();
}

class _SelectPickupSlotPageState extends State<SelectPickupSlotPage> {
  List<DateTime> dates = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    // Generate 90 days for 3 months
    for (int i = 0; i < 90; i++) {
      dates.add(now.add(Duration(days: i)));
    }
  }

  @override
  Widget build(BuildContext context) {
    String monthLabel = DateFormat('MMM yyyy').format(dates[selectedIndex]);
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: 10.w),
          child: FloatingActionButton(
            mini: true,
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
        title: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text(
            "Packer & Mover",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF111111),
              letterSpacing: -1,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "FAQs",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Color(0xFF006970),
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 25.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    buildStepCircle(icon: Icons.done, color: Color(0xFF006970)),
                    buildLine(),
                    buildStepCircle(icon: Icons.done, color: Color(0xFF006970)),
                    buildLine(),
                    buildStepCircle(
                      icon: Icons.calendar_month,
                      color: Color(0xFF006970),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Moving Details",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF006970),
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  "Add Item",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF006970),
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  "Schedule",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Divider(color: Color(0xFF086E86)),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, top: 10.h),
                    child: Text(
                      "Select Shifting Date",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, top: 5.h),
                    child: Text(
                      monthLabel,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      itemBuilder: (context, index) {
                        bool isSelected = index == selectedIndex;
                        DateTime date = dates[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 10.w),
                            width: 85,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.teal[100]
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected ? Colors.teal : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('dd').format(date),
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF000000),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      index == 0
                                          ? "Today"
                                          : DateFormat('EEE').format(date),
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF000000),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  "₹1,702",
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF000000),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15.w, right: 15.w, top: 16.h),
                    child: Text(
                      "Recommended add-ons",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  packageLayerbuild("Single-layer packing", "₹199"),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 15.w,
                      right: 15.w,
                      top: 10.h,
                    ),
                    child: Text(
                      "Ind. single layer of protective material like foam or corrugated sheets for essential protection",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  coverbuild(
                    "With COVER claim up to 20,000 in case of damage/loss",
                  ),
                  SizedBox(height: 16.h),
                  packageLayerbuild("Multi-layer packing", "₹399"),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 15.w,
                      right: 15.w,
                      top: 10.h,
                    ),
                    child: Text(
                      "Incl. extra layer of bubble wrap + (foam sheets or film rolls) for superior protection",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  coverbuild(
                    "With COVER claim up to 50,000 in case of damage/loss",
                  ),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ),
          Container(
            color: Color(0xFFE5F0F1),
            padding: EdgeInsets.only(
              left: 15.w,
              right: 15.w,
              top: 20.h,
              bottom: 20.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(selectedIndex.toString()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹1,702",
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                        letterSpacing: -0.5,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        backgroundColor: Color(0xFF006970),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          side: BorderSide.none,
                        ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.r),
                            ),
                          ),
                          //builder: (context) => const PickupSlotBottomSheet(),
                          builder: (context) {
                            return FractionallySizedBox(
                              heightFactor: 0.70, // 👈 85% screen height
                              child: const PickupSlotBottomSheet(),
                            );
                          },
                        );
                      },
                      child: Text(
                        "Select Pickup Slot",
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget coverbuild(String clam) {
    return Container(
      margin: EdgeInsets.only(top: 20.h, left: 15.w, right: 15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Color.fromARGB(127, 217, 217, 217),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80.w,
                height: 30.h,
                decoration: BoxDecoration(
                  color: Color(0xFF006970),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10.r),
                    topLeft: Radius.circular(10.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.health_and_safety_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    Text(
                      "Cover",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: -0.55,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Text(
                "NCLUDED WITH SINGLE LAYER",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000),
                ),
              ),
              SizedBox(width: 10.w),
            ],
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.only(left: 10.w, bottom: 6.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    clam,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000),
                      letterSpacing: -0.55,
                    ),
                  ),
                ),
                Icon(
                  Icons.health_and_safety_rounded,
                  color: Color(0xFF006970),
                  size: 22.sp,
                ),
                SizedBox(width: 10.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget packageLayerbuild(String name, String price) {
    return Row(
      children: [
        SizedBox(width: 15.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              price,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
          ],
        ),
        Spacer(),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
            minimumSize: Size(65.w, 25.h),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
              side: BorderSide(color: Color(0xFF006970), width: 1.w),
            ),
          ),
          onPressed: () {},
          child: Text(
            "Add",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF006970),
            ),
          ),
        ),
        SizedBox(width: 15.w),
      ],
    );
  }
}

class PickupSlotBottomSheet extends StatefulWidget {
  const PickupSlotBottomSheet({super.key});

  @override
  State<PickupSlotBottomSheet> createState() => _PickupSlotBottomSheetState();
}

class _PickupSlotBottomSheetState extends State<PickupSlotBottomSheet> {
  int selectSlot = 0;
  int? selectedTimeIndex; // 👈 Ye store karega konsa time selected hai

  final Map<int, List<String>> slotTimes = {
    0: [
      "8:00 AM - 9:00 AM",
      "9:00 AM - 10:00 AM",
      "10:00 AM - 11:00 AM",
      "11:00 AM - 12:00 PM",
    ],
    1: [
      "12:00 PM - 1:00 PM",
      "1:00 PM - 2:00 PM",
      "2:00 PM - 3:00 PM",
      "3:00 PM - 4:00 PM",
    ],
    2: [
      "4:00 PM - 5:00 PM",
      "5:00 PM - 6:00 PM",
      "6:00 PM - 7:00 PM",
      "7:00 PM - 8:00 PM",
    ],
  };
  @override
  Widget build(BuildContext context) {
    final currentTimes = slotTimes[selectSlot] ?? [];
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Center(
            child: Text(
              "Select Pickup Slot",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Center(
            child: Text(
              "6 Oct 2025",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              pickupSlot(0, Icons.wb_sunny_outlined, "Morning", "8AM - 12PM"),
              pickupSlot(
                1,
                Icons.wb_cloudy_outlined,
                "Afternoon",
                "12PM - 4PM",
              ),
              pickupSlot(2, Icons.nights_stay_outlined, 'Evening', "4PM - 8PM"),
            ],
          ),
          SizedBox(height: 15.h),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: currentTimes.length,
              itemBuilder: (context, index) {
                final time = currentTimes[index];
                final isSelected = selectedTimeIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedTimeIndex = index; // 👈 select new slot
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 15.h),
                    width: 330.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal[50] : Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF006970)
                            : const Color(0xFF000000),
                        width: isSelected ? 1.5.w : 0.5.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 15.w),
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                        Spacer(),
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined, // 👈 icon change
                          color: isSelected
                              ? const Color(0xFF006970)
                              : Colors.black54,
                        ),
                        SizedBox(width: 10.w),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 15.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50.h),
              backgroundColor: Color(0xFF006970),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
                side: BorderSide.none,
              ),
            ),
            onPressed: () {
              if (selectedTimeIndex != null) {
                final selectedTime = currentTimes[selectedTimeIndex!];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected Slot: $selectedTime')),
                );
              }
              Navigator.pop(context);
            },
            child: Text(
              "Confirm Slot",
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget pickupSlot(index, IconData icon, String label, String time) {
    final isSelected = selectSlot == index;
    return InkWell(
      onTap: () {
        setState(() {
          selectSlot = index;
          selectedTimeIndex = null; // 👈 reset time selection on new period
        });
      },
      child: Container(
        width: 100.w,
        height: 80.h,
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal[100] : Colors.white,
          border: Border.all(color: isSelected ? Colors.teal : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF006970), size: 20.sp),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
            Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Color(0xFF000000),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
