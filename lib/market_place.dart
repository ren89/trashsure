import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashsure/marketPlaceComponents/buy_confirmation.dart';
import 'package:trashsure/marketPlaceComponents/marketCard.dart';

class MarketPlacePage extends StatefulWidget {
  const MarketPlacePage({super.key});

  @override
  State<MarketPlacePage> createState() => _MarketPlacePageState();
}

class _MarketPlacePageState extends State<MarketPlacePage> {
  bool isLoading = true;
  bool role = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> items = [];

  Future<dynamic> getUserById(String userId) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    DocumentSnapshot userDoc = await usersCollection.doc(userId).get();
    return userDoc.data();
  }

  getRole() async {
    dynamic user = await getUserById(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      role = user!['junkshop_owner'] ?? false;
    });
    print(user!['junkshop_owner']);
  }

  getMarketPlace() async {
    await getRole();
    final marketCollection = FirebaseFirestore.instance
        .collection('marketplace')
        .where('bought', isEqualTo: false);
    final marketItems = await marketCollection.get();

    setState(() {
      items = marketItems.docs;
      isLoading = false;
    });
  }

  @override
  void initState() {
    getMarketPlace();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Market Place")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: !role
                      ? () {
                          print("Test");
                        }
                      : () async {
                          final result = await showDialog(
                            context: context,
                            builder: (context) => BuyItemModal(
                              itemName: items[index]['items'],
                              docId: items[index].id,
                            ),
                          );
                          if (result == true) {
                            getMarketPlace();
                          }
                        },
                  child: MarketCard(
                    item: items[index]['items'],
                    address: items[index]['address'],
                    description: items[index]['description'],
                    price: items[index]['price'],
                    weight: items[index]['weight'],
                    phone: items[index]['phone'],
                  ),
                );
              }),
    );
  }
}
