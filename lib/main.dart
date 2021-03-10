import 'package:flutter/material.dart';
import 'package:notes_app/login-signup.dart';
import 'package:notes_app/userModel.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes - Believable',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider(
        create: (context) => UserModel(),
          child: LoginSignup(),
      ),
    );
  }
}

