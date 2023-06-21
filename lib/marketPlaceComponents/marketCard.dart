import 'package:flutter/material.dart';

class MarketCard extends StatefulWidget {
  final String item;
  final int weight;
  final String description;
  final String address;
  final String phone;
  final double price;
  const MarketCard({
    super.key,
    required this.item,
    required this.weight,
    required this.description,
    required this.address,
    required this.phone,
    required this.price,
  });

  @override
  State<MarketCard> createState() => _MarketCardState();
}

class _MarketCardState extends State<MarketCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text('Description: ${widget.description}'),
            const SizedBox(height: 5),
            Text('Weight: ${widget.weight.toString()} kg'),
            const SizedBox(height: 5),
            Text('Contact #: ${widget.phone}'),
            const SizedBox(height: 5),
            Text('Address: ${widget.address}'),
            const SizedBox(height: 5),
            Text('Price: \u20B1${widget.price}'),
          ],
        ),
      ),
    );
  }
}
