import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:realtime/bloc/bloc/employee_bloc.dart';
import 'package:realtime/bloc/bloc/employee_event.dart';
import 'package:realtime/widgets/custom_date_picker.dart';

class UpdateEmployeeScreen extends StatefulWidget {
  final String employeeId; // ID of the employee to be updated
  final Map<String, dynamic> employeeData; // Current data of the employee

  const UpdateEmployeeScreen({
    required this.employeeId,
    required this.employeeData,
    Key? key,
  }) : super(key: key);

  @override
  _UpdateEmployeeScreenState createState() => _UpdateEmployeeScreenState();
}

class _UpdateEmployeeScreenState extends State<UpdateEmployeeScreen> {
  TextEditingController? nameController;
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  String? selectedRole;
  DateTime? startDate;
  DateTime? endDate;

  final List<String> roles = [
    "Product Designer",
    "Flutter Developer",
    "QA Tester",
    "Product Owner",
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current employee data
    nameController = TextEditingController(text: widget.employeeData["name"]);
    selectedRole = widget.employeeData["role"];
    startDate = widget.employeeData["startDate"] != null
        ? DateTime.parse(widget.employeeData["startDate"])
        : null;
    endDate = widget.employeeData["endDate"] != null
        ? DateTime.parse(widget.employeeData["endDate"])
        : null;

    log(startDate.toString());
    log(endDate.toString());

    startDateController?.text =
        startDate != null ? DateFormat('d MMM yyyy').format(startDate!) : "";
    endDateController?.text = DateFormat('d MMM yyyy').format(endDate!);

    log("controller ${startDateController?.text}");
    log("controller ${endDateController?.text}");
  }

  void showRoleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xffffffff),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Role",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              ListView.builder(
                shrinkWrap: true,
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      roles[index],
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    onTap: () {
                      setState(() {
                        selectedRole = roles[index];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void openCustomDatePicker(BuildContext context, bool isStartDate) {
    showDialog(
      context: context,
      builder: (context) => CustomDatePicker(
        initialDate: isStartDate
            ? (startDate ?? DateTime.now())
            : (endDate ?? DateTime.now()),
        onDateSelected: (selectedDate) {
          setState(() {
            if (isStartDate) {
              startDate = selectedDate;
              startDateController?.text =
                  DateFormat('d MMM yyyy').format(selectedDate);
            } else {
              endDate = selectedDate;
              endDateController?.text =
                  DateFormat('d MMM yyyy').format(selectedDate);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        automaticallyImplyLeading: true, // Ensure the back button appears
        title: Text(
          "Update Employee Details",
          style: TextStyle(
            color: const Color(0xFFFFFFFF),
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF1DA1F2),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Name Input
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Employee name",
                prefixIcon: const Icon(
                  Icons.person_2_outlined,
                  color: Color(0xff1DA1F2),
                ),
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  color: const Color(0xff949C9E),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Role Selector
            GestureDetector(
              onTap: showRoleSelector,
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Select role",
                    prefixIcon: const Icon(
                      Icons.work_outline,
                      color: Color(0xff1DA1F2),
                    ),
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      color: const Color(0xff949C9E),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    suffixIcon: Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 40.r,
                      color: const Color(0xff1DA1F2),
                    ),
                  ),
                  controller: TextEditingController(
                    text: selectedRole ?? "Select role",
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Start and End Dates
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => openCustomDatePicker(context, true),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Start Date",
                          hintStyle: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 16.sp),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Image.asset(
                              "assets/images/calendar.png",
                              width: 15.w,
                              height: 15.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        controller: startDateController,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                const Icon(Icons.arrow_forward),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => openCustomDatePicker(context, false),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "End Date",
                          hintStyle: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 16.sp),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Image.asset(
                              "assets/images/calendar.png",
                              width: 20.w,
                              height: 20.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        controller: endDateController,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),

            // Bottom Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController!.text.isEmpty || selectedRole == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please fill all details")),
                      );
                      return;
                    }

                    // Dispatch UpdateEmployee Event
                    BlocProvider.of<EmployeeBloc>(context).add(
                      UpdateEmployee(
                        widget.employeeId, // First positional argument
                        {
                          "name": nameController?.text,
                          "role": selectedRole,
                          "startDate": startDate?.toIso8601String(),
                          "endDate": endDate?.toIso8601String(),
                        }, // Second positional argument
                      ),
                    );

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DA1F2),
                  ),
                  child: Text("Update", style: TextStyle(fontSize: 14.sp)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
