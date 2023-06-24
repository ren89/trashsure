import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:trashsure/new_home.dart';
import 'package:trashsure/new_junkshop_home.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isLoading = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> notifications = [];
  bool role = false;

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

  getNotification() async {
    var notif = FirebaseFirestore.instance
        .collection('notification')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('isRead', descending: false);

    final notificationList = await notif.get();
    for (var element in notificationList.docs) {
      print(element['content']);
    }
    setState(() {
      notifications = notificationList.docs;
      isLoading = false;
    });
  }

  updateNotification(String id) async {
    FirebaseFirestore.instance.collection("notification").doc(id).update({
      "isRead": true,
    });
  }

  @override
  void initState() {
    getRole(FirebaseAuth.instance.currentUser!.uid);
    getNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifcation"),
        backgroundColor: Color(0xff45b5a8),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => {
            !role
                ? Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Home()),
                  )
                : Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => JunkshopHome()),
                  )
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: InkWell(
                  onTap: () async {
                    await updateNotification(notifications[index].id);
                    await getNotification();
                    setState(() {
                      notifications = notifications;
                    });
                  },
                  child: Card(
                      color: !notifications[index]['isRead']
                          ? Colors.white
                          : Colors.grey[300],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          notifications[index]['content'],
                          style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: notifications[index]['isRead']
                                  ? FontWeight.normal
                                  : FontWeight.bold),
                        ),
                      )),
                ),
              );
            }),
      ),
    );
  }
}
