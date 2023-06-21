import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trashsure/sellerHomeComponents/junkshop_card.dart';

class NearestJunkShop extends StatefulWidget {
  const NearestJunkShop({super.key});

  @override
  State<NearestJunkShop> createState() => _NearestJunkShopState();
}

class _NearestJunkShopState extends State<NearestJunkShop> {
  bool isLoading = true;
  List<DocumentSnapshot> docs = [];
  late Position currentLocation;
  getNearbyJunkshops() async {
    var position = await Geolocator.getCurrentPosition();
    GeoFirestore geo =
        GeoFirestore(FirebaseFirestore.instance.collection("junkshops"));
    var temp = await geo.getAtLocation(
        GeoPoint(position.latitude, position.longitude), 100);
    for (var element in temp) {
      print((element.data() as Map)['name']);
    }

    setState(() {
      docs = temp;
      currentLocation = position;
      isLoading = false;
    });
  }

  getDistance(List<dynamic> junkShop) {
    print(junkShop[0]);
    var distance =
        "${(Geolocator.distanceBetween(currentLocation.latitude, currentLocation.longitude, junkShop[0], junkShop[1]) / 1000).toStringAsFixed(2)} km away";

    return distance;
  }

  @override
  void initState() {
    getNearbyJunkshops();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator()
        : Expanded(
            child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final object = docs[index];
                return JunkShopCard(
                  name: (object.data() as Map)['name'],
                  contact: (object.data() as Map)['phone'] ?? "",
                  openingTime: (object.data() as Map)['opening'],
                  closingTime: (object.data() as Map)['closing'],
                  distance: getDistance((object.data() as Map)['l']),
                  id: docs[index].id,
                  location: LatLng(
                      currentLocation.latitude, currentLocation.longitude),
                );
                // ListTile(
                //   title: Text((object.data() as Map)['name']),
                //   subtitle: Text('Age: '),
                // );
              },
            ),
          );
  }
}
