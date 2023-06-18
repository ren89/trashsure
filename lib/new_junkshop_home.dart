import 'package:flutter/material.dart';
import 'package:trashsure/junkShopComponents/requestList.dart';
import 'package:trashsure/my_header_drawer.dart';

class JunkshopHome extends StatefulWidget {
  const JunkshopHome({super.key});

  @override
  State<JunkshopHome> createState() => _JunkshopHomeState();
}

class _JunkshopHomeState extends State<JunkshopHome> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Requests"),
          backgroundColor: Colors.green[700],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        drawer: const MyHeaderDrawer(),
        body: const TabBarView(
          children: [
            // Pending Tab
            RequestList(status: "PENDING"),

            // Accepted Tab
            RequestList(status: "ACCEPTED"),

            // Cancelled Tab
            RequestList(status: "CANCELLED"),
          ],
        ),

        //TODO create new page
        // app bar TopItemsAppBar()
        // Text(
        //   "Marketplace",
        //   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        // ),
        // MyMarketplace()
      ),
    );
  }
}
