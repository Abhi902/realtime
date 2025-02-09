import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtime/bloc/bloc/employee_event.dart';
import 'package:realtime/bloc/bloc/employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final FirebaseFirestore firestore;

  EmployeeBloc({required this.firestore}) : super(EmployeeInitial()) {
    on<FetchEmployees>((event, emit) async {
      emit(EmployeeLoading());
      try {
        final snapshot = await firestore.collection('employees').get();
        final employees = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "id": doc.id, // Include the document ID
            ...data, // Merge with the document data
          };
        }).toList();
        log("fetch employee triggered");
        emit(EmployeeLoaded(employees));
      } catch (e) {
        emit(EmployeeError(e.toString()));
      }
    });

    on<AddEmployee>((event, emit) async {
      try {
        await firestore.collection('employees').add(event.employeeData);
        add(FetchEmployees()); // Refresh employees after adding
      } catch (e) {
        emit(EmployeeError(e.toString()));
      }
    });

    on<UpdateEmployee>((event, emit) async {
      emit(EmployeeLoading()); // Emit loading state while updating
      try {
        // Update the employee document in Firestore
        await firestore
            .collection('employees')
            .doc(event.id)
            .update(event.employeeData);

        // Log success
        log("Employee updated successfully: ${event.id}");

        // Trigger a fetch to refresh the employee list
        add(FetchEmployees());
      } catch (e) {
        // Log the error
        log("Failed to update employee: ${e.toString()}");

        // Emit an error state with the exception message
        emit(EmployeeError("Failed to update employee: ${e.toString()}"));
      }
    });

    on<DeleteEmployee>((event, emit) async {
      try {
        await firestore.collection('employees').doc(event.id).delete();
        add(FetchEmployees()); // Refresh after deleting
      } catch (e) {
        emit(EmployeeError(e.toString()));
      }
    });
  }
}
