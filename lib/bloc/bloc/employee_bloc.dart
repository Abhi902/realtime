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
        final employees = snapshot.docs.map((doc) => doc.data()).toList();
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
      try {
        await firestore
            .collection('employees')
            .doc(event.id)
            .update(event.employeeData);
        add(FetchEmployees()); // Refresh after updating
      } catch (e) {
        emit(EmployeeError(e.toString()));
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
