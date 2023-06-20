import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:intl/intl.dart';

class RequestList extends StatefulWidget {
  final String status;
  const RequestList({super.key, required this.status});

  @override
  State<RequestList> createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  DateTime? pickedDate;
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
        if (element['status'] == widget.status) {
          requests.add(element);
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
  Widget build(BuildContext context) {
    return ListView(
      children: [
        FutureBuilder<List<DocumentSnapshot>>(
          future: getRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return const Text('No requests found for any junkshop');
            } else {
              return SizedBox(
                child: Column(
                    children: snapshot.data!.map((e) {
                  return GestureDetector(
                    onTap: (e.data() as Map)['status'] == "PENDING"
                        ? () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return SizedBox(
                                      child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            "Accept this Sell Request?",
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Column(
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    pickedDate = await showDatePicker(
                                                        context: context,
                                                        initialDate: (e.data()
                                                                        as Map)[
                                                                    'pickup_date']
                                                                [0]
                                                            .toDate(),
                                                        firstDate: (e.data()
                                                                        as Map)[
                                                                    'pickup_date']
                                                                [0]
                                                            .toDate(),
                                                        lastDate: (e.data() as Map)[
                                                                'pickup_date'][1]
                                                            .toDate());
                                                    if (pickedDate != null) {
                                                      e.reference.update({
                                                        "status": "ACCEPTED",
                                                        "picked_date":
                                                            pickedDate,
                                                      }).then((value) {
                                                        Navigator.pop(context);

                                                        setState(() {
                                                          getRequests();
                                                        });
                                                      });
                                                    }
                                                  },
                                                  child: const Text("Yes")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("No")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    e.reference.update({
                                                      "status": "CANCELLED"
                                                    }).then((value) {
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        getRequests();
                                                      });
                                                    });
                                                  },
                                                  child: const Text("Cancel"))
                                            ],
                                          )
                                        ]),
                                  ));
                                });
                          }
                        : null,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
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
                                (e.data() as Map)['status'] == "ACCEPTED"
                                    ? const Text(
                                        textAlign: TextAlign.start,
                                        "Picked date:")
                                    : const Text(
                                        textAlign: TextAlign.start,
                                        "Pickup date range:"),
                                (e.data() as Map)['status'] == "ACCEPTED"
                                    ? Text(
                                        textAlign: TextAlign.start,
                                        DateFormat('MMM d ').format(
                                            (e.data() as Map)['picked_date']
                                                .toDate()))
                                    : Text(
                                        textAlign: TextAlign.start,
                                        "${DateFormat('MMM d ').format((e.data() as Map)['pickup_date'][0].toDate())} - ${DateFormat('MMM d ').format((e.data() as Map)['pickup_date'][1].toDate())}"),
                                Text(
                                    "${(e.data() as Map)['phone'] ?? ''}"),
                              ],
                            ),
                            const Expanded(child: SizedBox.shrink()),
                            Text(
                              "P${(totalPrice(e) + (e.data() as Map)['fare']).toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
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
    );
  }
}
