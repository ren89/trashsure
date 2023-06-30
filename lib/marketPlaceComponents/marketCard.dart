import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MarketCard extends StatefulWidget {
  final String item;
  final int weight;
  final String description;
  final String address;
  final String phone;
  final double price;
  final String? id;
  final String sellerName;
  final String quantityType;
  final String image;
  const MarketCard({
    super.key,
    required this.item,
    required this.weight,
    required this.description,
    required this.address,
    required this.phone,
    required this.price,
    required this.sellerName,
    required this.quantityType,
    required this.image,
    this.id,
  });

  @override
  State<MarketCard> createState() => _MarketCardState();
}

class _MarketCardState extends State<MarketCard> {
  Color buttonColor = const Color(0xff45b5a8);
  String name = '';

  Future<dynamic> getUserById(String userId) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    DocumentSnapshot userDoc = await usersCollection.doc(userId).get();
    return userDoc.data();
  }

  getName() async {
    dynamic user = await getUserById(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      name = user!['name'];
    });
    return user!['name'];
  }

  writeNotification() async {
    var doc = await FirebaseFirestore.instance
        .collection('marketplace')
        .doc(widget.id)
        .get();
    var sellerId = (doc.data() as Map)['seller_id'];

    FirebaseFirestore.instance.collection("notification").add({
      "user_id": sellerId,
      "content":
          "${await getName()} wants to inquire about the item you're selling. Thank you for using Trashure",
      "isRead": false
    });
  }

  @override
  void initState() {
    getName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Column(
              children: [
                Image.network(
                  widget.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                widget.id == null || widget.sellerName == name
                    ? const SizedBox()
                    : ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(buttonColor),
                        ),
                        onPressed: () async {
                          await writeNotification();
                          setState(() {
                            buttonColor = Colors.grey;
                          });
                        },
                        child: Text("Inquire Now!"))
              ],
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text('Description: ${widget.description}'),
                    const SizedBox(height: 3),
                    Text(
                        'Weight: ${widget.weight.toString()} ${widget.quantityType}'),
                    const SizedBox(height: 3),
                    Text('Seller Name: ${widget.sellerName}'),
                    const SizedBox(height: 3),
                    Text('Contact #: ${widget.phone}'),
                    const SizedBox(height: 3),
                    Text('Address: ${widget.address}'),
                    const SizedBox(height: 3),
                    Text('Price: \u20B1${widget.price}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
