import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realtime/bloc/bloc/employee_bloc.dart';
import 'package:realtime/bloc/bloc/employee_event.dart';
import 'package:realtime/bloc/bloc/employee_state.dart';
import 'package:realtime/view/add_employee.dart';
import 'package:intl/intl.dart';
import 'package:realtime/view/update_employee.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // Scaffold background color
      appBar: AppBar(
        title: Text(
          "Employee List",
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF1DA1F2), // AppBar background color
        elevation: 0,
      ),
      body: BlocConsumer<EmployeeBloc, EmployeeState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1DA1F2),
              ),
            );
          } else if (state is EmployeeLoaded) {
            log("here is the new list ${state.employees.toString()}");
            if (state.employees.isEmpty) {
              return _buildEmptyState();
            } else {
              log(state.employees.toString());
              return _buildEmployeeList(state.employees, context);
            }
          } else if (state is EmployeeError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("Unexpected State"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1DA1F2),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddEmployeeScreen()));
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/no_employee.png", width: 200, height: 200),
        ],
      ),
    );
  }

  Widget _buildEmployeeList(
      List<Map<String, dynamic>> employees, BuildContext context) {
    // Separate employees into current and previous based on endDate
    final currentDate = DateTime.now();
    final currentEmployees = employees
        .where((employee) =>
            employee["endDate"] == null ||
            DateTime.parse(employee["endDate"]).isAfter(currentDate))
        .toList();

    final previousEmployees = employees
        .where((employee) =>
            employee["endDate"] != null &&
            DateTime.parse(employee["endDate"]).isBefore(currentDate))
        .toList();

    return ListView(
      // padding: const EdgeInsets.all(16),
      children: [
        // Current Employees Section
        if (currentEmployees.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Current employees",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xff1DA1F2),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          ...currentEmployees
              .map((employee) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => UpdateEmployeeScreen(
                                  employeeId: employee["id"],
                                  employeeData: employee,
                                )));
                  },
                  child:
                      _buildEmployeeCard(employee, isCurrent: true, context)))
              .toList(),
        ],

        // Spacer
        if (currentEmployees.isNotEmpty && previousEmployees.isNotEmpty)
          SizedBox(height: 20.h),

        // Previous Employees Section
        if (previousEmployees.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Previous employees",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xff1DA1F2),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          ...previousEmployees
              .map((employee) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => UpdateEmployeeScreen(
                                  employeeId: employee["id"],
                                  employeeData: employee,
                                )));
                  },
                  child:
                      _buildEmployeeCard(employee, context, isCurrent: false)))
              .toList(),
        ],
      ],
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> employee, BuildContext context,
      {required bool isCurrent}) {
    final startDate = DateFormat("dd MMM, yyyy")
        .format(DateTime.parse(employee["startDate"]));
    final endDate = employee["endDate"] != null
        ? DateFormat("dd MMM, yyyy").format(DateTime.parse(employee["endDate"]))
        : null;

    return Dismissible(
      key: Key(employee["id"]), // Unique key for each employee
      direction: DismissDirection.endToStart, // Swipe left to delete
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        // Trigger the DeleteEmployee event in the bloc
        BlocProvider.of<EmployeeBloc>(context)
            .add(DeleteEmployee(employee["id"]));

        // Show a snackbar confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${employee["name"]} deleted")),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(12.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Name
            Text(
              employee["name"],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4.h),

            // Employee Position
            Text(
              employee["role"],
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF949C9E),
              ),
            ),
            SizedBox(height: 8.h),

            // Employee Dates
            Text(
              isCurrent
                  ? "From $startDate"
                  : "$startDate - $endDate", // Format date based on current/previous
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF949C9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
