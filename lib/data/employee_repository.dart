import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeRepository {
  final CollectionReference _employeeCollection =
      FirebaseFirestore.instance.collection('employees');

  Future<void> addEmployee(Map<String, dynamic> employeeData) async {
    await _employeeCollection.add(employeeData);
  }

  Future<void> updateEmployee(
      String id, Map<String, dynamic> employeeData) async {
    await _employeeCollection.doc(id).update(employeeData);
  }

  Future<void> deleteEmployee(String id) async {
    await _employeeCollection.doc(id).delete();
  }

  Stream<QuerySnapshot> fetchEmployees() {
    return _employeeCollection
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}
