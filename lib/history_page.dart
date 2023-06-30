import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashsure/marketPlaceComponents/marketCard.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool isLoading = true;
  bool role = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> history = [];

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
  }

  getHistory() async {
    await getRole();

    final marketCollection = !role
        ? FirebaseFirestore.instance
            .collection('marketplace')
            .where('bought', isEqualTo: true)
            .where(
              'seller_id',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
            )
        : FirebaseFirestore.instance
            .collection('marketplace')
            .where('bought', isEqualTo: true)
            .where(
              'buyer_id',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
            );

    final marketItems = await marketCollection.get();

    setState(() {
      history = marketItems.docs;
      isLoading = false;
    });
  }

  @override
  void initState() {
    getHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: Color(0xff45b5a8),
      ),
      body: ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            return MarketCard(
              item: history[index]['items'],
              address: history[index]['address'],
              description: history[index]['description'],
              price: history[index]['price'],
              weight: history[index]['weight'],
              phone: history[index]['phone'],
              sellerName: history[index]['seller_name'],
              quantityType: history[index]['quantity_type'],
              image: history[index]['image'],
            );
          }),
    );
  }
}
