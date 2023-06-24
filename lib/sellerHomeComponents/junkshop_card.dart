import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trashsure/new_home.dart';

class JunkShopCard extends StatefulWidget {
  final String name;
  final String openingTime;
  final String closingTime;
  final String contact;
  final double distance;
  final String id;
  final LatLng location;
  const JunkShopCard({
    super.key,
    required this.name,
    required this.contact,
    required this.openingTime,
    required this.closingTime,
    required this.distance,
    required this.id,
    required this.location,
  });

  @override
  State<JunkShopCard> createState() => _JunkShopCardState();
}

class _JunkShopCardState extends State<JunkShopCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
              isScrollControlled: true,
              useSafeArea: true,
              context: context,
              builder: (context) {
                return JunkshopWidget(
                  id: widget.id,
                  user_location: widget.location,
                );
              });
        },
        child: Card(
          child: ListTile(
            title: Text(widget.name),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Available Time: ${widget.openingTime}-${widget.closingTime}'),
                      Text(
                          'Distance: ${widget.distance.toStringAsFixed(2)} km'),
                      Text('Phone Number: ${widget.contact}'),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.store,
                  size: 45,
                  color: Color(0xff45b5a8),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
