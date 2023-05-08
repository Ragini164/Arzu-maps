import 'package:final_fyp/index.dart';
import 'package:flutter/material.dart';
// import 'package:your_app_name/app_functionality.dart'; // Import the file with functionality

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String title = 'Arzu';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      home: AppFunctionality(), // Use the widget from the functionality file as the home
    );
  }
}
