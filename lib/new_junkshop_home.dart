import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashsure/junkShopComponents/requestList.dart';
import 'package:trashsure/my_header_drawer.dart';
import 'package:trashsure/notification_page.dart';

class JunkshopHome extends StatefulWidget {
  const JunkshopHome({super.key});

  @override
  State<JunkshopHome> createState() => _JunkshopHomeState();
}

class _JunkshopHomeState extends State<JunkshopHome> {
  int notificationCount = 0;
  getNotifCount() async {
    var query = FirebaseFirestore.instance
        .collection('notification')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('isRead', isEqualTo: false);

    await query.get().then((QuerySnapshot snapshot) {
      int count = snapshot.size;

      setState(() {
        notificationCount = count;
      });
    }).catchError((error) {
      print('Error retrieving data: $error');
    });
  }

  @override
  void initState() {
    getNotifCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Requests"),
          backgroundColor: Color(0xff45b5a8),
          actions: [
            IconButton(
              icon: Badge(
                label: Text(notificationCount.toString()),
                child: const Icon(Icons.notifications),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                );
                // _showTopItemsDialog();
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        drawer: const MyHeaderDrawer(),
        body: const TabBarView(
          children: [
            // Pending Tab
            RequestList(status: "PENDING"),

            // Accepted Tab
            RequestList(status: "ACCEPTED"),

            // Cancelled Tab
            RequestList(status: "CANCELLED"),
          ],
        ),

        //TODO create new page
        // app bar TopItemsAppBar()
        // Text(
        //   "Marketplace",
        //   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        // ),
        // MyMarketplace()
      ),
    );
  }
}
