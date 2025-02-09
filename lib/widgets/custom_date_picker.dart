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
  String? selectedQuickAction;

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

  List<Widget> _buildQuickActions() {
    final quickActions = [
      {"label": "Today", "date": DateTime.now()},
      {
        "label": "Next Monday",
        "date": DateTime.now()
            .add(Duration(days: (8 - DateTime.now().weekday) % 7)),
      },
      {
        "label": "Next Tuesday",
        "date": DateTime.now()
            .add(Duration(days: (9 - DateTime.now().weekday) % 7)),
      },
      {
        "label": "After 1 week",
        "date": DateTime.now().add(const Duration(days: 7)),
      },
    ];

    return quickActions.map((action) {
      final isSelected = selectedQuickAction == action["label"];
      return GestureDetector(
        onTap: () => _onQuickAction(
            action["label"] as String, action["date"] as DateTime),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF1DA1F2) : const Color(0xFFEDF8FF),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            action["label"] as String,
            style: TextStyle(
              fontSize: 14.sp,
              color: isSelected ? Colors.white : const Color(0xFF1DA1F2),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400.w), // Increased width
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick Actions
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: _buildQuickActions(),
              ),
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
                      const Icon(Icons.calendar_today,
                          color: Color(0xff1DA1F2)),
                      SizedBox(width: 8.w),
                      Text(
                        DateFormat('d MMM yyyy').format(selectedDate),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel",
                            style: TextStyle(color: const Color(0xff949C9E))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.onDateSelected(selectedDate);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1DA1F2),
                        ),
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
