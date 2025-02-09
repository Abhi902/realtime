import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomDatePicker({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime selectedDate;
  late DateTime displayedMonth;
  String? selectedQuickAction = "Today";

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    displayedMonth = widget.initialDate;
  }

  void _onQuickAction(String label, DateTime date) {
    setState(() {
      selectedQuickAction = label;
      selectedDate = date;
      displayedMonth = DateTime(
          date.year, date.month, 1); // Ensure calendar reflects the month
    });
  }

  Widget _buildQuickActionsGrid() {
    final quickActions = [
      {"label": "Today", "date": DateTime.now()},
      {
        "label": "Next Monday",
        "date": DateTime.now().add(Duration(
            days: DateTime.now().weekday == 1
                ? 7
                : (8 - DateTime.now().weekday))),
      },
      {
        "label": "Next Tuesday",
        "date": DateTime.now().add(Duration(
            days: DateTime.now().weekday == 2
                ? 7
                : ((9 - DateTime.now().weekday) % 7))),
      },
      {
        "label": "After 1 week",
        "date": DateTime.now().add(const Duration(days: 7)),
      },
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildQuickActionButton(quickActions[0])),
            SizedBox(width: 10.w), // Spacing between buttons
            Expanded(child: _buildQuickActionButton(quickActions[1])),
          ],
        ),
        SizedBox(height: 10.h), // Spacing between rows
        Row(
          children: [
            Expanded(child: _buildQuickActionButton(quickActions[2])),
            SizedBox(width: 10.w),
            Expanded(child: _buildQuickActionButton(quickActions[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(Map<String, dynamic> action) {
    final isSelected = selectedQuickAction == action["label"];

    log("is selected date");
    log(selectedQuickAction.toString());
    log("Action lable ");
    log(action["label"]);
    return GestureDetector(
      onTap: () =>
          _onQuickAction(action["label"] as String, action["date"] as DateTime),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1DA1F2) : const Color(0xFFEDF8FF),
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          action["label"] as String,
          style: TextStyle(
            fontSize: 14.sp,
            color: isSelected ? Colors.white : const Color(0xFF1DA1F2),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      selectedQuickAction = null; // Clear quick action selection
    });
  }

  Widget _buildCalendar() {
    final firstDayOfMonth =
        DateTime(displayedMonth.year, displayedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = firstWeekday + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalDays,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4.h,
        crossAxisSpacing: 4.w,
      ),
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return const SizedBox.shrink();
        }
        final day = index - firstWeekday + 1;
        final date = DateTime(displayedMonth.year, displayedMonth.month, day);

        // Highlight the selected date
        final isSelected = date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;

        return GestureDetector(
          onTap: () => _onDateSelected(date),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xff1DA1F2) : null,
              borderRadius: BorderRadius.circular(8.r),
              border: date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day
                  ? Border.all(color: const Color(0xff1DA1F2), width: 1.5)
                  : null,
            ),
            child: Text(
              "$day",
              style: TextStyle(
                fontSize: 14.sp,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFFFF),
      insetPadding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick Actions

            _buildQuickActionsGrid(),

            SizedBox(height: 16.h),

            // Calendar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      displayedMonth = DateTime(
                          displayedMonth.year, displayedMonth.month - 1);
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(displayedMonth),
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      displayedMonth = DateTime(
                          displayedMonth.year, displayedMonth.month + 1);
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            _buildCalendar(),

            SizedBox(height: 16.h),

            // Footer with Selected Date, Cancel, and Save Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/calendar.png",
                      width: 25.w,
                      height: 25.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      selectedDate == widget.initialDate
                          ? "No Date"
                          : DateFormat('d MMM yyyy').format(selectedDate),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffEDF8FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              6.r), // Set only 6.r border radius
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xff1DA1F2),
                          fontWeight: FontWeight.w500,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.onDateSelected(selectedDate);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xff1DA1F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              6.r), // Set only 6.r border radius
                        ),
                      ),
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
