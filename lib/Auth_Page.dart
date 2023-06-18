import 'package:flutter/material.dart';
import 'package:trashsure/LoginScreen.dart';
import 'package:trashsure/Register_Page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  // initially show the login page

  bool showLoginScreen = true;

  void toggleScreens (){
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showLoginScreen){
      return LoginScreen(showRegisterPage: toggleScreens);
    } else {
      return RegisterPage(showLoginScreen: toggleScreens);
    }
  }
}