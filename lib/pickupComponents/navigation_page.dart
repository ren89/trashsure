import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:trashsure/pickupComponents/map.dart';
import 'package:trashsure/pickup_page.dart';

class NavigationPage extends StatefulWidget {
  final String date;
  const NavigationPage({super.key, required this.date});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  Set<Marker> markers = Set();
  List<Marker> markerPoly = [];
  bool isLoading = true;
  Future<List<DocumentSnapshot>> getRequests() async {
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
        if (element['status'] == 'ACCEPTED' ||
            element['status'] == 'COMPLETED') {
          if (DateFormat('MMM d yyyy')
                  .format(element['picked_date'].toDate()) ==
              widget.date) {
            LatLng temp = LatLng(
                element['pickup_location'][0], element['pickup_location'][1]);
            MarkerId markerId = MarkerId(element.id);

            Marker marker = Marker(
                position: temp,
                markerId: markerId,
                infoWindow: const InfoWindow(title: "Seller"));
            markers.add(marker);
            markerPoly.add(marker);
            requests.add(element);
          }
        }
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
  void initState() {
    getRequests().then((value) => setState(() {
          isLoading = false;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigation"),
        backgroundColor: Color(0xff45b5a8),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                MapScreen(
                  markers: markers,
                  markerPoly: markerPoly,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      FutureBuilder<List<DocumentSnapshot>>(
                        future: getRequests(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData &&
                              snapshot.data!.isEmpty) {
                            return const Text(
                                'No requests found for any junkshop');
                          } else {
                            return SizedBox(
                              child: Column(
                                  children: snapshot.data!.map((e) {
                                return InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20, bottom: 30),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  "Complete order?",
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          e.reference.update({
                                                            "status":
                                                                "COMPLETED",
                                                          }).then((value) {
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {
                                                              getRequests();
                                                            });
                                                          });
                                                        },
                                                        child: const Text(
                                                            "Complete")),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            "Cancel")),
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  child: Card(
                                    color: (e.data() as Map)['status'] ==
                                            "COMPLETED"
                                        ? Colors.green
                                        : Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ...(e.data() as Map)['items']
                                                  .map<Widget>((item) {
                                                return Text(
                                                    '${item['quantity']}kg ${item['name']} @ P${item['price']}/kg');
                                              }).toList(),
                                              const Text(
                                                  textAlign: TextAlign.start,
                                                  "Picked date:"),
                                              Text(
                                                  textAlign: TextAlign.start,
                                                  DateFormat('MMM d ').format((e
                                                              .data()
                                                          as Map)['picked_date']
                                                      .toDate())),
                                              Text(
                                                  "${(e.data() as Map)['phone'] ?? ''}"),
                                              Text(
                                                  "by ${(e.data() as Map)['seller_name'] ?? ''}"),
                                            ],
                                          ),
                                          const Expanded(
                                              child: SizedBox.shrink()),
                                          Text(
                                            "P${(e.data() as Map)['total'].toStringAsFixed(2)}",
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList()),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
