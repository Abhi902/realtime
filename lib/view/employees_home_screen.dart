import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtime/bloc/bloc/employee_bloc.dart';
import 'package:realtime/bloc/bloc/employee_event.dart';
import 'package:realtime/bloc/bloc/employee_state.dart';
import 'package:realtime/view/add_employee.dart';

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
          title: const Text(
            "Employee List",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          child: const Icon(Icons.add),
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
          const SizedBox(height: 20),
          const Text(
            "No employee records found",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList(
      List<Map<String, dynamic>> employees, BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Current employees",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...employees.map((employee) {
          return Dismissible(
            key: Key(employee["id"]),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              BlocProvider.of<EmployeeBloc>(context)
                  .add(DeleteEmployee(employee["id"]));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${employee["name"]} deleted")),
              );
            },
            child: Card(
              child: ListTile(
                title: Text(employee["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "${employee["position"]}\nFrom ${employee["startDate"]}",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                isThreeLine: true,
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 20),
        const Text(
          "Swipe left to delete",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
