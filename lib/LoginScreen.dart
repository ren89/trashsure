import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trashsure/forgot_pw_page.dart';
import 'package:trashsure/main_page.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginScreen({Key? key, required this.showRegisterPage})
      : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future signIn() async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim())
        .then((value) {
      if (value.user != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return MainPage();
        }));
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool isRememberMe = false;

  Widget buildEmail() {
    return Form(
      key: _formKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Email',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ]),
              height: 60,
              child: TextFormField(
                validator: (value) {
                  final emailRegex =
                      RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                  if (value == "") {
                    return 'Please enter your email';
                  } else if (!emailRegex.hasMatch(value!)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14),
                    prefixIcon: Icon(Icons.email, color: Color(0xff45b5a8)),
                    hintText: 'Email Address',
                    hintStyle: TextStyle(color: Colors.black38)),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Password',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ]),
              height: 60,
              child: TextFormField(
                validator: (value) {
                  if (value == "") {
                    return 'Please type a password';
                  }
                  return null;
                },
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                    errorMaxLines: 8,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14),
                    prefixIcon: Icon(Icons.lock, color: Color(0xff45b5a8)),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.black38)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ForgotPasswordPage();
                          },
                        ),
                      );
                    },
                    // padding: EdgeInsets.only(right:0),
                    child: Text(
                      'Forgot Passsword?',
                      style: TextStyle(
                          color: Color(0xff45b5a8),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 25),
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      signIn();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xff45b5a8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )),
          ]),
    );
  }

  Widget buildSignUpBtn() {
    return GestureDetector(
        onTap: widget.showRegisterPage,
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                  text: 'Don\'t have an account yet? ',
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w500)),
              TextSpan(
                  text: 'Register now',
                  style: TextStyle(
                      color: Color(0xff45b5a8), fontWeight: FontWeight.bold)),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Color(0x66efd7d7),
                    Color(0x99efd7d7),
                    Color(0xccefd7d7),
                    Color(0xffefd7d7),
                  ])),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.recycling_outlined,
                      size: 60,
                      color: Colors.lightGreen,
                    ),
                    const Text(
                      'TrashSure',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Center(
                      child: Text(
                        'A mobile-based C2B application that implements an online recyclable waste marketplace utilizing a recommender algorithm',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    buildEmail(),
                    SizedBox(height: 20),
                    buildSignUpBtn(),
                  ],
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
