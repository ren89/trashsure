import 'package:flutter/material.dart';
import 'package:trashsure/my_header_drawer.dart';

class PickUpPage extends StatefulWidget {
  const PickUpPage({super.key});

  @override
  State<PickUpPage> createState() => _PickUpPageState();
}

class _PickUpPageState extends State<PickUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick up"),
        backgroundColor: Colors.green[700],
      ),
      body: Column(children: [Text("data")]),
    );
  }
}
