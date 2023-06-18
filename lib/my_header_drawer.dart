import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashsure/User.dart';
import 'package:trashsure/buy_request.dart';
import 'package:trashsure/profile.dart';
import 'package:trashsure/sell_request.dart';
import 'package:trashsure/settings.dart';
import 'package:trashsure/shop.dart';

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({Key? key}) : super(key: key);

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  final user = FirebaseAuth.instance.currentUser!;
  dynamic? userDoc;
  final userData = UserSingleton.instance;

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      setState(() {
        userDoc = value.data();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        Container(
          color: Colors.green[700],
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars-thumbnail.png'),
                    ),
                  ),
                ),
                Text(
                  userData.user!.displayName!,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "Signed In as: " + user.email!,
                  style: TextStyle(color: Colors.grey[200], fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          title: Row(
            children: [
              Icon(Icons.history),
              SizedBox(
                width: 24,
              ),
              Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )
            ],
          ),
          onTap: () {
            // Update the state of the app.
            // ...
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
        ListTile(
          title: Row(
            children: [
              Icon(Icons.account_box_outlined),
              SizedBox(
                width: 24,
              ),
              Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )
            ],
          ),
          onTap: () {
            // Update the state of the app.
            // ...
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
        if (userData.userType == "junkshop_owner")
          ListTile(
            title: Row(
              children: [
                Icon(Icons.attach_money_outlined),
                SizedBox(
                  width: 24,
                ),
                Text(
                  'Buy Request and History',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )
              ],
            ),
            onTap: () {
              // Update the state of the app.
              // ...
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BuyRequest()),
              );
            },
          ),
        ListTile(
          title: Row(
            children: [
              Icon(Icons.attach_money_outlined),
              SizedBox(
                width: 24,
              ),
              Text(
                'Sell Request and History',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )
            ],
          ),
          onTap: () {
            // Update the state of the app.
            // ...
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SellRequest()),
            );
          },
        ),
        if (userData.userType == "junkshop_owner")
          ListTile(
            title: Row(
              children: [
                Icon(Icons.attach_money_outlined),
                SizedBox(
                  width: 24,
                ),
                Text(
                  'My Shops',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )
              ],
            ),
            onTap: () {
              // Update the state of the app.
              // ...
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyStore()),
              );
            },
          ),
        ListTile(
          title: Row(
            children: [
              Icon(Icons.close),
              SizedBox(
                width: 24,
              ),
              Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )
            ],
          ),
          onTap: () {
            FirebaseAuth.instance.signOut();
          },
        ),
      ],
    ));
  }
}
