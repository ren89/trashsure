import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final Set<Marker> markers;
  final List<Marker> markerPoly;
  const MapScreen({super.key, required this.markers, required this.markerPoly});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
      target: LatLng(14.40623697884286, 120.97523666918278), zoom: 11.5);
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  late GoogleMapController _mapController;
  getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;
      widget.markerPoly.insert(
        0,
        Marker(
            markerId: MarkerId("markerId"),
            position: LatLng(latitude, longitude),
            infoWindow: const InfoWindow(title: "My Location")),
      );

      widget.markerPoly.insert(
        0,
        Marker(
          markerId: MarkerId("markerId"),
          position: LatLng(latitude, longitude),
        ),
      );
      getDirections(widget.markerPoly);
    } catch (e) {
      print('Error: $e');
    }
  }

  getDirections(List<Marker> markers) async {
    List<LatLng> polylineCoordinates = [];
    List<PolylineWayPoint> polylineWayPoints = [];
    for (var i = 0; i < markers.length; i++) {
      polylineWayPoints.add(PolylineWayPoint(
          location:
              "${markers[i].position.latitude.toString()},${markers[i].position.longitude.toString()}",
          stopOver: true));
    }

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        "AIzaSyAP-IkIEmtq7bvYGusX6kaICdpcytjFgOU",
        PointLatLng(
            markers.first.position.latitude, markers.first.position.longitude),
        PointLatLng(
            markers.last.position.latitude, markers.last.position.longitude),
        travelMode: TravelMode.driving,
        wayPoints: polylineWayPoints);

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    addPolyLine(polylineCoordinates, () {
      setState(() {});
    });
  }

  addPolyLine(List<LatLng> polylineCoordinates, void Function() setStateFunc) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;

    setStateFunc();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      height: 300,
      child: GoogleMap(
        myLocationButtonEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) {
          //method called when map is created
          setState(() {
            _mapController = controller;
          });
        },
        markers: widget.markerPoly.toSet(),
        polylines: Set<Polyline>.of(polylines.values),
      ),
    );
  }
}
