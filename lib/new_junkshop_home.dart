import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashsure/my_header_drawer.dart';
import 'package:trashsure/my_marketplace.dart';

import 'main_test.dart';

class JunkshopHome extends StatefulWidget {
  State<JunkshopHome> createState() => _JunkshopHomeState();
}

class _JunkshopHomeState extends State<JunkshopHome> {
  Future<List<DocumentSnapshot>> getRequests() async {
    var junkshops = await FirebaseFirestore.instance
        .collection("junkshops")
        .where("owner", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    log(junkshops.docs.toString());
    List<DocumentSnapshot> requests = [];
    for (var element in junkshops.docs) {
      var items = await FirebaseFirestore.instance
          .collection("requests")
          .where("junkshop_id", isEqualTo: element.id)
          .get();
      for (var element in items.docs) {
        requests.add(element);
      }
    }
    return requests;
  }

  double totalPrice(DocumentSnapshot<Object?> data) {
    double total = 0.0;
    for (var item in (data.data() as Map)['items']) {
      total += item['subtotal'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopItemsAppBar(),
      drawer: MyHeaderDrawer(),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            "Sell Requests",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          FutureBuilder<List<DocumentSnapshot>>(
            future: getRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Text('No requests found for any junkshop');
              } else {
                return Container(
                  child: Column(
                      children: snapshot.data!.map((e) {
                    return GestureDetector(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...(e.data() as Map)['items']
                                        .map<Widget>((item) {
                                      return Text(
                                          '${item['quantity']}kg ${item['name']} @ P${item['price']}/kg');
                                    }).toList(),
                                    Text(
                                        textAlign: TextAlign.start,
                                        "Pickup date: ${DateTime.fromMicrosecondsSinceEpoch(((e.data() as Map)['pickup_date'] as Timestamp).microsecondsSinceEpoch).toString().split(" ")[0]}")
                                  ]),
                              Expanded(child: SizedBox.shrink()),
                              Text(
                                "P" +
                                    (totalPrice(e) + (e.data() as Map)['fare'])
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                  child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Accept this Sell Request?",
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    e.reference.update({
                                                      "confirmed": true
                                                    }).then((value) {
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  child: Text("Yes"))),
                                          Expanded(child: SizedBox.shrink()),
                                          Expanded(
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("No"))),
                                          Expanded(child: SizedBox.shrink()),
                                          Expanded(
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    e.reference.update({
                                                      "cancelled": true
                                                    }).then((value) {
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  child: Text("Cancel")))
                                        ],
                                      )
                                    ]),
                              ));
                            });
                      },
                    );
                  }).toList()),
                ); // Replace this with your desired widget
              }
            },
          ),
          Text(
            "Marketplace",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          MyMarketplace()
        ],
      ),
    );
  }
}
