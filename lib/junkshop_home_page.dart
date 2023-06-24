import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trashsure/my_header_drawer.dart';
import 'package:image_picker/image_picker.dart';

class JunkshopHomePage extends StatefulWidget {
  final DocumentSnapshot userData;
  const JunkshopHomePage({Key? key, required this.userData}) : super(key: key);

  @override
  State<JunkshopHomePage> createState() => _JunkshopHomePageState();
}

class _JunkshopHomePageState extends State<JunkshopHomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  Future<List<DocumentSnapshot>> querySellRequests(String junkshopId) async {
    log('Querying sell requests for junkshop_id: <$junkshopId>');
    final sellRequestsRef = FirebaseFirestore.instance
        .collection('requests')
        .where('junkshop_id', isEqualTo: junkshopId)
        .where("complete", isEqualTo: false);

    final sellRequestsSnapshot = await sellRequestsRef.get();

    return sellRequestsSnapshot.docs;
  }

  Future<List<DocumentSnapshot>> queryJunkshops() async {
    final junkshopsRef = FirebaseFirestore.instance
        .collection('junkshops')
        .where('owner_id', isEqualTo: user.uid);

    final junkshopsSnapshot = await junkshopsRef.get();

    final List<Future<List<DocumentSnapshot>>> futures = [];

    for (var doc in junkshopsSnapshot.docs) {
      final junkshopId = doc.id;
      final future = querySellRequests(junkshopId);
      futures.add(future);
    }

    final List<List<DocumentSnapshot>> results = await Future.wait(futures);
    final List<DocumentSnapshot> combinedResults =
        results.expand((list) => list).toList();

    return combinedResults;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff45b5a8),
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: Color(0xff45b5a8)),
        title: Text("Trashsure"),
        centerTitle: true,
      ),
      drawer: MyHeaderDrawer(),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Sell Requests",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          FutureBuilder(
              future: queryJunkshops(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  log('${snapshot.data}');
                  List<DocumentSnapshot<Object?>>? data = snapshot.data;
                  return Column(
                      children: data!.map((doc) {
                    dynamic reqData = doc.data();
                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          reqData['items'].map<Widget>((item) {
                                        SellItem sell_item = SellItem(
                                            item.values.toList()[0],
                                            item.keys.toList()[0]);
                                        if (item.values.toList()[0] != "")
                                          return Text(
                                              '${sell_item.quantity}kg ${sell_item.name}');
                                        else {
                                          return SizedBox.shrink();
                                        }
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    List<SellItem> sellItems = [];

                                    reqData['items'].forEach((item) {
                                      if (item.values.toList()[0] != "") {
                                        SellItem sell_item = SellItem(
                                            item.values.toList()[0],
                                            item.keys.toList()[0]);
                                        sellItems.add(sell_item);
                                      }
                                    });
                                    SellRequestData sellRequestData =
                                        SellRequestData(
                                            doc.id,
                                            sellItems,
                                            reqData['date'],
                                            reqData['owner_id'],
                                            reqData['junkshop_id']);
                                    return SellRequestPopUp(
                                        sellRequestData: sellRequestData);
                                  });
                            },
                          ),
                        )
                      ],
                    );
                  }).toList());
                } else if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data == null) {
                  return Text("No Sell Requests found on any Shop");
                } else {
                  return CircularProgressIndicator();
                }
              }),
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              "Marketplace",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: MyMarketplace(),
          ),
        ],
      ),
    );
  }
}

class ColumnBuilder extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final VerticalDirection verticalDirection;
  final int itemCount;

  const ColumnBuilder({
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    this.mainAxisAlignment: MainAxisAlignment.start,
    this.mainAxisSize: MainAxisSize.max,
    this.crossAxisAlignment: CrossAxisAlignment.center,
    this.verticalDirection: VerticalDirection.down,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: this.crossAxisAlignment,
      mainAxisSize: this.mainAxisSize,
      mainAxisAlignment: this.mainAxisAlignment,
      verticalDirection: this.verticalDirection,
      children: new List.generate(
          this.itemCount, (index) => this.itemBuilder(context, index)).toList(),
    );
  }
}

class MyMarketplace extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getMarketplace() {
    return _firestore
        .collection('marketplace')
        .where('bought', isEqualTo: false)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: getMarketplace(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No listings available'),
          );
        }

        return ColumnBuilder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            final document = snapshot.data!.docs[index];
            return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return MarketplaceListingWidget(
                          listingSnapshot: document);
                    });
              },
              child: Card(
                child: ListTile(
                  title: Text(document['items']),
                  subtitle: Text(document['description']),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MarketplaceListingWidget extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> listingSnapshot;

  MarketplaceListingWidget({required this.listingSnapshot});

  @override
  Widget build(BuildContext context) {
    final Timestamp timestamp = listingSnapshot['date'];
    final DateTime date = timestamp.toDate();

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date: ${date.toString()}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text('Items: ${listingSnapshot['items']}'),
          SizedBox(height: 8.0),
          Text('Description: ${listingSnapshot['description']}'),
          SizedBox(height: 8.0),
          Text('Weight: ${listingSnapshot['weight'].toString()}'),
          SizedBox(height: 16.0),
          if (listingSnapshot['buyer_id'] != null &&
              listingSnapshot['buyer_id'] ==
                  FirebaseAuth.instance.currentUser?.uid)
            Text("You have already placed a buy request for this listing.")
          else
            ElevatedButton(
              onPressed: () {
                sendBuyRequest(listingSnapshot.id);
                Navigator.of(context).pop();
              },
              child: Text('Send a Buy Request'),
            ),
        ],
      ),
    );
  }

  void sendBuyRequest(String documentId) {
    // Update Firestore document with 'bought' field set to true
    FirebaseFirestore.instance.collection('marketplace').doc(documentId).update(
        {'bought': true, 'buyer_id': FirebaseAuth.instance.currentUser?.uid});
  }
}

class SellItem {
  String quantity;
  String name;

  SellItem(this.quantity, this.name);

  String getQuantityAndNameString() {
    return "${quantity}kg ${name}";
  }
}

class SellRequestData {
  String id;
  List<SellItem> items;
  Timestamp date;
  String requester_id;
  String junkshop_id;

  SellRequestData(
      this.id, this.items, this.date, this.requester_id, this.junkshop_id);

  String getPickUpDateInString() {
    DateTime dateTime =
        DateTime.fromMicrosecondsSinceEpoch(date.microsecondsSinceEpoch);
    return "${dateTime.month}/${dateTime.day}/${dateTime.year}";
  }
}

class SellRequestPopUp extends StatefulWidget {
  final SellRequestData sellRequestData;

  SellRequestPopUp({Key? key, required this.sellRequestData}) : super(key: key);

  @override
  _SellRequestPopUpState createState() => _SellRequestPopUpState();
}

class _SellRequestPopUpState extends State<SellRequestPopUp> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Sell Request",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(children: [
              ...widget.sellRequestData.items.map<Widget>((item) {
                return Row(
                  children: [Text(item.getQuantityAndNameString())],
                );
              }).toList(),
              SizedBox(
                height: 32,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Pickup date: " +
                    widget.sellRequestData.getPickUpDateInString()),
              ),
              SizedBox(
                height: 32,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  child: Text("Confirm"),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection("requests")
                        .doc(widget.sellRequestData.id)
                        .update({
                      "complete": true,
                    }).then((value) => Navigator.pop(context));
                  },
                ),
              ),
            ]),
          ),
        )
      ]),
    );
  }
}
