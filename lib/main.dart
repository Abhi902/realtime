import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realtime/bloc/bloc/employee_bloc.dart';
import 'package:realtime/firebase_options.dart';
import 'package:realtime/view/employees_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize Firestore instance
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, child) {
        return BlocProvider(
          create: (context) => EmployeeBloc(firestore: firestore),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: EmployeesScreen(),
          ),
        );
      },
    );
  }
}
