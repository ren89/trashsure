import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuyItemModal extends StatelessWidget {
  final String itemName;
  final String docId;

  const BuyItemModal({
    super.key,
    required this.itemName,
    required this.docId,
  });

  sendBuyRequest() {
    FirebaseFirestore.instance.collection('marketplace').doc(docId).update(
        {'bought': true, 'buyer_id': FirebaseAuth.instance.currentUser?.uid});
  }

  Future<dynamic> getUserById(String userId) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    DocumentSnapshot userDoc = await usersCollection.doc(userId).get();
    return userDoc.data();
  }

  getName() async {
    dynamic user = await getUserById(FirebaseAuth.instance.currentUser!.uid);
    return user!['name'];
  }

  writeNotification() async {
    var doc = await FirebaseFirestore.instance
        .collection('marketplace')
        .doc(docId)
        .get();
    var sellerId = (doc.data() as Map)['seller_id'];

    FirebaseFirestore.instance.collection("notification").add({
      "user_id": sellerId,
      "content":
          'Your listing has been bought by ${await getName()}. Thank you for using Trashure',
      "isRead": false
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sell Item'),
      content: Text('Mark $itemName as sold?'),
      actions: [
        TextButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          child: const Text('Yes'),
          onPressed: () {
            sendBuyRequest();
            writeNotification();
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
