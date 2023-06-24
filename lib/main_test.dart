import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashsure/notification_page.dart';

class TopItemsAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _TopItemsAppBarState createState() => _TopItemsAppBarState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class _TopItemsAppBarState extends State<TopItemsAppBar> {
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
    return AppBar(
      backgroundColor: Color(0xff45b5a8),
      title: Text('TrashSure'),
      actions: [
        IconButton(
          icon: notificationCount == 0
              ? const Icon(Icons.notifications)
              : Badge(
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
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trashsure',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: TopItemsAppBar(),
        body: Center(
          child: Text('Your App Content'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
