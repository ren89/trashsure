import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashsure/Auth_Page.dart';
import 'package:trashsure/LoginScreen.dart';
import 'package:trashsure/User.dart';
import 'package:trashsure/buy_request.dart';
import 'package:trashsure/history_page.dart';
import 'package:trashsure/market_place.dart';
import 'package:trashsure/my_item_page.dart';
import 'package:trashsure/pickup_page.dart';
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
  bool role = false;

  @override
  void initState() {
    getRole(FirebaseAuth.instance.currentUser!.uid);
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

  Future<dynamic> getUserById(String userId) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    DocumentSnapshot userDoc = await usersCollection.doc(userId).get();
    return userDoc.data();
  }

  Future<bool> getRole(String userId) async {
    dynamic user = await getUserById(userId);
    setState(() {
      role = user!['junkshop_owner'] ?? false;
    });
    return user!['junkshop_owner'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        Container(
          color: Color(0xff45b5a8),
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
                  userData.user!.displayName ?? "",
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
          title: const Row(
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
        role
            ? const SizedBox()
            : ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.apps_rounded),
                    SizedBox(
                      width: 24,
                    ),
                    Text(
                      'My Items',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  ],
                ),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyItemPage()),
                  );
                },
              ),
        ListTile(
          title: Row(
            children: const [
              Icon(Icons.storefront),
              SizedBox(
                width: 24,
              ),
              Text(
                'Market Place',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MarketPlacePage()),
            );
          },
        ),
        !role
            ? const SizedBox()
            : ListTile(
                title: Row(
                  children: const [
                    Icon(Icons.delivery_dining_rounded),
                    SizedBox(
                      width: 24,
                    ),
                    Text(
                      'Pickups',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PickUpPage()),
                  );
                },
              ),
        !role
            ? ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(
                      width: 24,
                    ),
                    Text(
                      'History',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryPage()),
                  );
                },
              )
            : const SizedBox(),
        !role
            ? SizedBox()
            : ListTile(
                title: Row(
                  children: const [
                    Icon(Icons.attach_money_outlined),
                    SizedBox(
                      width: 24,
                    ),
                    Text(
                      'My Shops',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            children: const [
              Icon(Icons.logout),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AuthPage()),
            );
          },
        ),
      ],
    ));
  }
}
