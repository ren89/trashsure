import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trashsure/Auth_Page.dart';
import 'package:trashsure/User.dart';
import 'package:trashsure/email_verify.dart';
import 'package:trashsure/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trashsure/new_home.dart';
import 'package:trashsure/new_junkshop_home.dart';

import 'junkshop_home_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  Future<DocumentSnapshot> getUserById(String userId) async {
    CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

    return await usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
  }

  Future<Position> getCurrentPosition() async {
    await Geolocator.checkPermission();
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data?.emailVerified == true) {
            UserSingleton userSingleton = UserSingleton.instance;
            userSingleton.email = snapshot.data!.email!;
            return FutureBuilder(
                future: getUserById(snapshot.data!.uid),
                builder: (context, innerSnapshot) {
                  if (innerSnapshot.hasData) {
                    log(innerSnapshot.data!.data().toString());
                    Map data = innerSnapshot.data!.data() as Map;
                    userSingleton.name = data['name'];

                    if (data['junkshop_owner'] == true) {
                      userSingleton.userType = 'junkshop_owner';
                      return JunkshopHome();
                    } else {
                      return Home();
                      /*return FutureBuilder(
                        future: getCurrentPosition(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return HomePage(
                              userData: innerSnapshot.data!,
                              position: LatLng(snapshot.data!.latitude,
                                  snapshot.data!.longitude),
                            );
                          } else if (snapshot.data == null) {
                            return Text(
                                "There was an error trying to get your current location");
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      );*/
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                });
          } else if (snapshot.hasData) {
            return EmailVerificationPage();
          } else {
            return AuthPage();
          }
        },
      ),
    );
  }
}
