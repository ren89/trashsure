import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashsure/marketPlaceComponents/buy_confirmation.dart';
import 'package:trashsure/marketPlaceComponents/marketCard.dart';

class JunkshopItem {
  final String name;
  final List<Junkshop> junkshops;

  JunkshopItem({required this.name, required this.junkshops});
}

class Junkshop {
  final String name;
  final double price;

  Junkshop({required this.name, required this.price});
}

class MarketPlacePage extends StatefulWidget {
  const MarketPlacePage({super.key});

  @override
  State<MarketPlacePage> createState() => _MarketPlacePageState();
}

class _MarketPlacePageState extends State<MarketPlacePage> {
  bool isLoading = true;
  bool role = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> items = [];

  List<JunkshopItem> topItems = [
    JunkshopItem(
      name: 'Lata',
      junkshops: [
        Junkshop(name: 'MTYJ Junkshop', price: 10.0),
        Junkshop(name: 'Mandias Junkshop', price: 9.0),
        Junkshop(name: 'Car and Ton Junkshop', price: 8.0),
      ],
    ),
    JunkshopItem(
      name: 'Karton',
      junkshops: [
        Junkshop(name: 'Cesar Junkshop', price: 4.0),
        Junkshop(name: 'Penados Junkshop', price: 2.0),
        Junkshop(name: 'Maricar Junkshop', price: 2.50),
      ],
    ),
    JunkshopItem(
      name: 'Bakal',
      junkshops: [
        Junkshop(name: 'P.N.J Junkshop', price: 13.0),
        Junkshop(name: 'Dodoy Junkshop', price: 12.0),
        Junkshop(name: 'MTYJ Junkshop', price: 10.0),
      ],
    ),
    JunkshopItem(
      name: 'Tanso',
      junkshops: [
        Junkshop(name: 'Cesar Junkshop', price: 360.0),
        Junkshop(name: 'Car and Ton Junkshop', price: 330.0),
        Junkshop(name: 'P.N.J Junkshop', price: 320.0),
      ],
    ),
    JunkshopItem(
      name: 'Aluminium',
      junkshops: [
        Junkshop(name: 'P.N.J Junkshop', price: 60.0),
        Junkshop(name: 'Mandias Junkshop', price: 50.0),
        Junkshop(name: 'JD Mande Junkshop', price: 40.0),
      ],
    ),
  ];

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
      appBar: AppBar(
        title: const Text("Market Place"),
        backgroundColor: Color(0xff45b5a8),
        actions: [
          IconButton(
            icon: const Icon(Icons.trending_up),
            onPressed: () {
              _showTopItemsDialog();
            },
          ),
        ],
      ),
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

  void _showTopItemsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Market Trends',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                for (int i = 0; i < topItems.length; i++)
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          title: Text(
                            topItems[i].name,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              _showJunkshopsDialog(topItems[i]);
                            },
                            child: Icon(
                              Icons.store_mall_directory_outlined,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showJunkshopsDialog(JunkshopItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Top Junkshops for ${item.name}',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                for (int i = 0; i < item.junkshops.length; i++)
                  ListTile(
                    title: Text(item.junkshops[i].name),
                    subtitle: Text(
                      'Price: ₱${item.junkshops[i].price.toStringAsFixed(2)}/kg',
                    ),
                  ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
