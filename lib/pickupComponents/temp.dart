// adding packages
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Marker> markers = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  late GoogleMapController googleMapController;
  final Completer<GoogleMapController> completer = Completer();

// onMapCreated is a function that takes a mapController and
// optional parameter called options. The option is used to change // the UI of the map such as rotation gestures, zoom gestures, map // type, etc.The function of mapController is mostly similar to.   // TextEditingController as it is being used to manage the camera  // functions, zoom and animations, etc.
// 2: As mentioned above mapController takes parameters to change  // the functions of the map such as changing position, zoom, etc.
  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    if (!completer.isCompleted) {
      completer.complete(controller);
    }
  }

// Function for adding markers to google map
// MarkerId should be unique beacuse of define markerId as string of // LatLng(lattitude,longitude), if string of LatLng equals any
// element of markers List it will be remove
  addMarker(latLng, newSetState) {
    markers.add(Marker(
        consumeTapEvents: true,
        markerId: MarkerId(latLng.toString()),
        position: latLng,
// We adding onTap paramater for when click marker, remove from map
        onTap: () {
          markers.removeWhere(
              (element) => element.markerId == MarkerId(latLng.toString()));
// markers length must be greater than 1 because polyline needs two // points
          if (markers.length > 1) {
            getDirections(markers, newSetState);
          }
// When we added markers then removed all, this time polylines seems //in map because of we should clear polylines
          else {
            polylines.clear();
          }
// newState parameter of function, we are openin map in alertDialog, // contexts are different in page and alert dialog because of we use // different setState
          newSetState(() {});
        }));
    if (markers.length > 1) {
      getDirections(markers, newSetState);
    }

    newSetState(() {});
  }
// This functions gets real road polyline routes

  getDirections(List<Marker> markers, newSetState) async {
    List<LatLng> polylineCoordinates = [];
    List<PolylineWayPoint> polylineWayPoints = [];
    for (var i = 0; i < markers.length; i++) {
      polylineWayPoints.add(PolylineWayPoint(
          location:
              "${markers[i].position.latitude.toString()},${markers[i].position.longitude.toString()}",
          stopOver: true));
    }
// result gets little bit late as soon as in video, because package // send http request for getting real road routes
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "MapConstants.apiKey", //GoogleMap ApiKey
      PointLatLng(markers.first.position.latitude,
          markers.first.position.longitude), //first added marker
      PointLatLng(markers.last.position.latitude,
          markers.last.position.longitude), //last added marker
// define travel mode driving for real roads
      travelMode: TravelMode.driving,
// waypoints is markers that between first and last markers        wayPoints: polylineWayPoints
    );
// Sometimes There is no result for example you can put maker to the // ocean, if results not empty adding to polylineCoordinates
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    newSetState(() {});

    addPolyLine(polylineCoordinates, newSetState);
  }

  addPolyLine(List<LatLng> polylineCoordinates, newSetState) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;

    newSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          child: Container(
            height: 40,
            width: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
              border: Border.all(
                color: Colors.grey,
                width: 2,
              ),
            ),
            child: Text("Create Route", textAlign: TextAlign.center),
          ),
          onTap: () async {
            await showDialog(
                context: context,
                builder: (context) =>
                    StatefulBuilder(builder: (context, newSetState) {
                      return AlertDialog(
                        insetPadding: EdgeInsets.all(10),
                        contentPadding: EdgeInsets.all(5),
                        content: Stack(
                          children: [
                            SizedBox(
                              width: 400,
                              height: 500,
                              child: GoogleMap(
                                mapToolbarEnabled: false,
                                onMapCreated: onMapCreated,
                                polylines: Set<Polyline>.of(polylines.values),
                                initialCameraPosition: const CameraPosition(
                                    target: LatLng(38.437532, 27.149606),
                                    zoom: 10),
                                markers: markers.toSet(),
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                onTap: (newLatLng) async {
                                  await addMarker(newLatLng, newSetState);
                                  newSetState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                setState(() {});
                              },
                              child: Text('Approve Route'),
                            ),
                          ),
                        ],
                      );
                    }));
          },
        ),
      ),
    );
  }
}
