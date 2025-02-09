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
      backgroundColor: const Color(0xffFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.separated(
                shrinkWrap: true,
                itemCount: roles.length,
                separatorBuilder: (context, index) => const SizedBox(
                  width: double.infinity, // Ensures full width
                  child: Divider(
                    color: Color(0xffF2F2F2), // Grey line color
                    thickness: 1, // Line thickness
                    height: 1, // Minimized gap between line and text
                  ),
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRole = roles[index];
                      });
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Center(
                        child: Text(
                          roles[index],
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff323238),
                          ),
                        ),
                      ),
                    ),
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
      body: Column(
        children: [
          Padding(
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
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 1.h,
            color: Colors.grey,
          ),

          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
                      color: const Color(0xff1DA1F2),
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.w,
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
                    elevation: 0,
                    backgroundColor: const Color(0xff1DA1F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          6.r), // Set only 6.r border radius
                    ),
                  ),
                  child: Text(
                    "Update",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
