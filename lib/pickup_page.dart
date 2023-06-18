import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:trashsure/pickupComponents/navigation_page.dart';

class PickUpPage extends StatefulWidget {
  const PickUpPage({super.key});

  @override
  State<PickUpPage> createState() => _PickUpPageState();
}

class _PickUpPageState extends State<PickUpPage> {
  List<String> pickupDates = [];

  Future<List<DocumentSnapshot>> getRequests() async {
    List<String> tempPickupDates = [];
    var junkshops = await FirebaseFirestore.instance
        .collection("junkshops")
        .where("owner", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    List<DocumentSnapshot> requests = [];
    for (var element in junkshops.docs) {
      var items = await FirebaseFirestore.instance
          .collection("requests")
          .where("junkshop_id", isEqualTo: element.id)
          .get();
      for (var element in items.docs) {
        if (element['status'] == 'ACCEPTED') {
          requests.add(element);
          tempPickupDates.add(
              DateFormat('MMM d yyyy').format(element['picked_date'].toDate()));
        }
      }
    }
    setState(() {
      pickupDates = tempPickupDates.toSet().toList();
    });
    return requests;
  }

  @override
  void initState() {
    getRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick up"),
        backgroundColor: Colors.green[700],
      ),
      body: ListView.builder(
        itemCount: pickupDates.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return NavigationPage(
                    date: pickupDates[index],
                  );
                }));
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pickupDates[index],
                        style: const TextStyle(fontSize: 20),
                      ),
                      const Icon(
                        Icons.assistant_navigation,
                        size: 40,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
