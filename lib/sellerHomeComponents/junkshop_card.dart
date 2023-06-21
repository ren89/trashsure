import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trashsure/new_home.dart';

class JunkShopCard extends StatefulWidget {
  final String name;
  final String openingTime;
  final String closingTime;
  final String contact;
  final String distance;
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Available Time: ${widget.openingTime}-${widget.closingTime}'),
                Text('Distance: ${widget.distance}'),
                Text('Phone Number: ${widget.contact}'),
              ],
            ),
          ),
        ),
      ),
    );
    // Card(
    //   child: Column(children: [
    //     Text(widget.name),
    //     Text(widget.contact),
    //     Text('${widget.openingTime}-${widget.closingTime}'),
    //     Text(widget.distance),
    //   ]),
    // );
  }
}
