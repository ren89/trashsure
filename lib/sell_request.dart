import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellRequest extends StatefulWidget {
  @override
  _SellRequestState createState() => _SellRequestState();
}

class _SellRequestState extends State<SellRequest> {
  bool ready = false;
  Future<List<DocumentSnapshot>> getRequestsForCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      String uid = user.uid;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('owner', isEqualTo: uid)
          .get();

      List<DocumentSnapshot> documents = querySnapshot.docs;

      return documents;
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text('Sell Requests'),
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder(
        future: getRequestsForCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: [
                ...snapshot.data!.map((e) {
                  return SellRequestCard(data: e);
                }).toList()
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class SellRequestCard extends StatefulWidget {
  final DocumentSnapshot data;
  SellRequestCard({required this.data});
  @override
  _SellRequestCardState createState() => _SellRequestCardState();
}

class _SellRequestCardState extends State<SellRequestCard> {
  bool ready = false;
  String? url;
  Future<List<DocumentSnapshot>> getRequestsForCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      String uid = user.uid;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('owner', isEqualTo: uid)
          .get();

      List<DocumentSnapshot> documents = querySnapshot.docs;

      return documents;
    }

    return [];
  }

  @override
  void initState() {
    super.initState();
    FirebaseStorage.instance.ref(widget.data.id).getDownloadURL().then((value) {
      print(value);
      if (mounted) {
        setState(() {
          url = value;
          ready = true;
        });
      }
    });
  }

  String getStatus(Map data) {
    String status = "Pending";
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: 240,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ready
                  ? [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getStatus((widget.data.data() as Map))),
                          SizedBox(
                            height: 16,
                          ),
                          Image.network(
                            url ?? "",
                            height: 160,
                            width: 120,
                            fit: BoxFit.cover,
                          )
                        ],
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...(widget.data.data() as Map)['items'].map((item) {
                            return Text(
                                "${item['quantity']}kg ${item['name']} @ P${item['price']}");
                          }).toList(),
                          Expanded(child: SizedBox.shrink()),
                          Text("Total: P " +
                              (widget.data.data() as Map)['total']
                                  .toStringAsFixed(2)),
                        ],
                      ),
                    ]
                  : [
                      Expanded(
                          child: Center(
                        child: CircularProgressIndicator(),
                      ))
                    ]),
        ),
      ),
    );
  }
}
