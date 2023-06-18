import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trashsure/shop.dart';

class PickLocation extends StatefulWidget {
  const PickLocation({super.key});

  @override
  State<PickLocation> createState() => _PickLocationState();
}

class _PickLocationState extends State<PickLocation> {
  LatLng? _location;
  @override
  void initState() {
    super.initState();
    getCurrentLocation().then((value) {
      setState(() {
        _location = value;
      });
    });
  }

  Widget build(BuildContext context) {
    return PinLocationModal(locationOverride: _location);
  }
}
