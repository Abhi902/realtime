import 'package:equatable/equatable.dart';

sealed class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object> get props => [];
}

class FetchEmployees extends EmployeeEvent {}

class AddEmployee extends EmployeeEvent {
  final Map<String, dynamic> employeeData;

  const AddEmployee(this.employeeData);

  @override
  List<Object> get props => [employeeData];
}

class UpdateEmployee extends EmployeeEvent {
  final String id;
  final Map<String, dynamic> employeeData;
  const UpdateEmployee(this.id, this.employeeData);

  @override
  List<Object> get props => [id, employeeData];
}

class DeleteEmployee extends EmployeeEvent {
  final String id;
  const DeleteEmployee(this.id);

  @override
  List<Object> get props => [id];
}
