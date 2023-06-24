import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BuyRequest extends StatefulWidget {
  @override
  _BuyRequestState createState() => _BuyRequestState();
}

class _BuyRequestState extends State<BuyRequest> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      var doc = value.data();

      if (doc!['junkshop_owner'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "You are not allowed to access this page. Please contact an administrator to change your account status to Junkshop Owner.")));
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff45b5a8),
        title: Text('Buy Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('marketplace')
            .where('buyer_id',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot document = snapshot.data!.docs[index];
              final DateTime date = (document['date'] as Timestamp).toDate();
              final String items = document['items'];
              final String description = document['description'];

              return Card(
                child: ListTile(
                  title: Text('Date: ${date.toString()}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Items: $items'),
                      Text('Description: $description'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
