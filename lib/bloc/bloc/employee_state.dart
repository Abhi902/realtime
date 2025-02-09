import 'package:equatable/equatable.dart';

sealed class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object> get props => [];
}

final class EmployeeInitial extends EmployeeState {}

final class EmployeeLoading extends EmployeeState {}

final class EmployeeLoaded extends EmployeeState {
  final List<Map<String, dynamic>> employees;
  const EmployeeLoaded(this.employees);

  @override
  List<Object> get props => [employees];
}

final class EmployeeError extends EmployeeState {
  final String message;
  const EmployeeError(this.message);

  @override
  List<Object> get props => [message];
}
