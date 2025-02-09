import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realtime/bloc/bloc/employee_bloc.dart';
import 'package:realtime/bloc/bloc/employee_event.dart';
import 'package:realtime/bloc/bloc/employee_state.dart';
import 'package:realtime/view/add_employee.dart';
import 'package:intl/intl.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmployeeBloc(firestore: FirebaseFirestore.instance)
        ..add(FetchEmployees()), // Trigger fetch employees event
      child: Scaffold(
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
        body: BlocBuilder<EmployeeBloc, EmployeeState>(
          builder: (context, state) {
            if (state is EmployeeLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1DA1F2),
                ),
              );
            } else if (state is EmployeeLoaded) {
              if (state.employees.isEmpty) {
                return _buildEmptyState();
              } else {
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
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => AddEmployeeScreen()));
          },
        ),
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
          Text(
            "Current employees",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.h),
          ...currentEmployees
              .map((employee) => _buildEmployeeCard(employee, isCurrent: true))
              .toList(),
        ],

        // Spacer
        if (currentEmployees.isNotEmpty && previousEmployees.isNotEmpty)
          SizedBox(height: 20.h),

        // Previous Employees Section
        if (previousEmployees.isNotEmpty) ...[
          Text(
            "Previous employees",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.h),
          ...previousEmployees
              .map((employee) => _buildEmployeeCard(employee, isCurrent: false))
              .toList(),
        ],
      ],
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> employee,
      {required bool isCurrent}) {
    final startDate = DateFormat("dd MMM, yyyy")
        .format(DateTime.parse(employee["startDate"]));
    final endDate = employee["endDate"] != null
        ? DateFormat("dd MMM, yyyy").format(DateTime.parse(employee["endDate"]))
        : null;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
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
    );
  }
}
