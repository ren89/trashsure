import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginScreen;
  const RegisterPage({Key? key, required this.showLoginScreen})
      : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _confirmphoneNumberController = TextEditingController();
  final _confirmaddressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isRememberMe = false;

  Future signUp() async {
    bool errors = false;
    bool email_verified = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text);
    final RegExp passwordRegex =
        RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{8,}$");
    errors = passwordRegex.hasMatch(_passwordController.text);
    print("ERROR" + errors.toString());

    print("working" + passwordConfirmed().toString());

    if (email_verified == false) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("You did not supply a proper email address.")));
    } else if (passwordConfirmed() && errors == true) {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim())
          .then((value) => {
                FirebaseFirestore.instance
                    .collection("users")
                    .doc(value.user?.uid)
                    .set({
                  "address": _confirmaddressController.text,
                  "name": _firstNameController.text,
                  "phone": _confirmphoneNumberController.text
                }).then((value) => Navigator.pop(context))
              });
    } else if (errors == false && passwordConfirmed() == false) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Your password must be more than 8 characters long and have one uppercase and lowercase letter, a number, and a special character. Your password also does not match confirm password. Please try again.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Your password does not match confirm password. Please try again.")));
    }
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confirmpasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  bool validateEmail(String email) {
    // Regular expression pattern for email validation
    final RegExp emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email);
  }

  bool validatePassword(String password) {
    // Regular expression pattern for password validation
    final RegExp passwordRegex =
        RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{8,}$");

    return passwordRegex.hasMatch(password);
  }

  @override
  Widget buildfirstName() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
          ]),
      height: 60,
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your full name";
          }
        },
        controller: _firstNameController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(Icons.email, color: Color(0xff45b5a8)),
            hintText: 'Full Name',
            hintStyle: TextStyle(color: Colors.black38)),
      ),
    );
  }

  Widget buildEmail() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
          ]),
      height: 60,
      child: TextFormField(
        validator: (value) {
          if (value == null || !validateEmail(value)) {
            return 'Please supply your email address in the proper format (Eg. example@example.com)';
          }
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
    );
  }

  Widget buildPassword() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
          ]),
      height: 60,
      child: TextFormField(
        validator: (value) {
          if (value == null || !validatePassword(value)) {
            return 'Please supply an adequately secure password. It should have at least one lowercase and uppercase letter, a special character, a number, and be at least 8 characters long.';
          }
          return null;
        },
        controller: _passwordController,
        obscureText: false,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
            errorMaxLines: 4,
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(Icons.lock, color: Color(0xff45b5a8)),
            hintText: 'Password',
            hintStyle: TextStyle(color: Colors.black38)),
      ),
    );
  }

  Widget buildconfirmPassword() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
          ]),
      height: 60,
      child: TextFormField(
        validator: (value) {
          if (value == _passwordController.text) {
            return null;
          }
          return 'Does not match your password.';
        },
        controller: _confirmpasswordController,
        obscureText: false,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(Icons.lock, color: Color(0xff45b5a8)),
            hintText: 'Confirm Password',
            hintStyle: TextStyle(color: Colors.black38)),
      ),
    );
  }

  Widget buildphoneNumber() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
          ]),
      height: 60,
      child: TextFormField(
        validator: (value) {
          if (value == null || value.length != 11) {
            return 'Please enter a phone number in 11-digit format (Eg. 09123456789)';
          }
        },
        controller: _confirmphoneNumberController,
        style: TextStyle(color: Colors.black87),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(Icons.phone_android, color: Color(0xff45b5a8)),
            hintText: 'Phone Number',
            hintStyle: TextStyle(color: Colors.black38)),
      ),
    );
  }

  Widget buildaddress() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
          ]),
      height: 60,
      child: TextFormField(
        controller: _confirmaddressController,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(Icons.home, color: Color(0xff45b5a8)),
            hintText: 'Address',
            hintStyle: TextStyle(color: Colors.black38)),
      ),
    );
  }

  Widget buildSignUpBtn() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 25),
        width: double.infinity,
        child: GestureDetector(
          onTap: () {
            if (_formKey.currentState!.validate()) {
              signUp();
            }
          },
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                'Sign Up',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ));
  }

  Widget buildLogin() {
    return GestureDetector(
        onTap: widget.showLoginScreen,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: 'I am a member! ',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w500)),
              TextSpan(
                  text: 'Login Now',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
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
                  children: <Widget>[
                    Text(
                      'Dont trash it! Cash It',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Register now to start!',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          buildfirstName(),
                          SizedBox(height: 10),
                          buildEmail(),
                          SizedBox(height: 10),
                          buildPassword(),
                          SizedBox(height: 10),
                          buildconfirmPassword(),
                          SizedBox(height: 10),
                          buildphoneNumber(),
                          SizedBox(height: 10),
                          buildaddress(),
                          SizedBox(height: 2),
                          buildSignUpBtn(),
                          SizedBox(height: 2),
                          buildLogin(),
                        ],
                      ),
                    )
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
