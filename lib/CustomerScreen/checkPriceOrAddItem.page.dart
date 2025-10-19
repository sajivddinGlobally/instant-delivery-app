import 'package:delivery_mvp_app/CustomerScreen/packerMover.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckPriceOraddItemPage extends StatefulWidget {
  const CheckPriceOraddItemPage({super.key});

  @override
  State<CheckPriceOraddItemPage> createState() =>
      _CheckPriceOraddItemPageState();
}

class _CheckPriceOraddItemPageState extends State<CheckPriceOraddItemPage> {
  int selectedItem = 0;

  final List<String> rooms = ["Living Room", "Bedroom", "Kitchen", "Others"];

  @override
  Widget build(BuildContext context) {
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
                    buildStepCircle(
                      icon: Icons.shopping_bag,
                      color: Color(0xFF006970),
                    ),
                    buildLine(),
                    buildStepCircle(
                      icon: Icons.calendar_month,
                      color: Color(0xFF8B8B8B),
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
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.only(
              left: 8.w,
              right: 8.w,
              top: 10.h,
              bottom: 10.h,
            ),
            margin: EdgeInsets.only(left: 15.w, right: 15.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Color(0xFFD9D9D9),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                rooms.length,
                (index) => InkWell(
                  onTap: () {
                    setState(() {
                      selectedItem = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.r),
                      color: selectedItem == index
                          ? const Color(0xFF006970)
                          : Colors.transparent,
                    ),
                    child: Text(
                      rooms[index],
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: selectedItem == index
                            ? Colors.white
                            : Colors.black,
                        letterSpacing: -0.55,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20.h, left: 15.w, right: 16.w),
            child: TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 15.w,
                  right: 15.w,
                  top: 10.h,
                  bottom: 10.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Color(0xFF006970)),
                ),
                hint: Text(
                  "Search",
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF006970),
                  ),
                ),
                prefixIcon: Icon(Icons.search, color: Color(0xFF006970)),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 15.w, right: 15.w),
                child: Column(
                  children: [
                    ItemSelect(itemName: "Living Room"),
                    ItemSelect(itemName: "Bedroom"),
                    ItemSelect(itemName: "Kitchen"),
                    ItemSelect(itemName: "Others"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemSelect extends StatefulWidget {
  final String itemName;
  const ItemSelect({super.key, required this.itemName});

  @override
  State<ItemSelect> createState() => _ItemSelectState();
}

class _ItemSelectState extends State<ItemSelect> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 1,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(
              left: 13.w,
              right: 13.w,
              top: 14.h,
              bottom: 14.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Color(0xFFFFFFFF),
              border: Border.all(color: Color.fromARGB(76, 0, 0, 0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.itemName,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 6.h),
                Divider(),
                Itembuild(),
                Divider(),
                Itembuild(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget Itembuild() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Icon(Icons.chair),
            SizedBox(width: 10.w),
            Text(
              "Chairs",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Color(0xFF000000),
              ),
            ),
          ],
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
                Text("data"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
