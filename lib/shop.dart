import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:flutter/services.dart';
import 'package:idkit_inputformatters/idkit_inputformatters.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MyStore extends StatefulWidget {
  @override
  _MyStoreState createState() => _MyStoreState();
}

class _MyStoreState extends State<MyStore> {
  String? _currentUserId;
  List<DocumentSnapshot> _documents = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    bool userValid = await _validateAccountType();
    if (user != null && userValid) {
      setState(() {
        _currentUserId = user.uid;
      });
      _queryFirestore();
    } else if (userValid == false) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Your account is not allowed to create and list new Shops. Contact administrators to change your account type.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "There was an error retrieving the currently logged on user.")));
    }
  }

  Future<void> _queryFirestore() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('junkshops')
        .where('owner_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    setState(() {
      _documents = snapshot.docs;
    });
  }

  Future<void> _showNewModalSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return NewShopPopup(
          onFinishCallback: () async {
            await _queryFirestore();
          },
        );
      },
    );
  }

  Future<bool> _validateAccountType() async {
    var ref = FirebaseFirestore.instance
        .collection("users")
        .where("__name__", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .limit(1);
    var data = await ref.get();
    dynamic userData = data.docs[0].data();

    if (userData['junkshop_owner'] == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Shops'),
          backgroundColor: Colors.green[700],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            Row(children: [
              Expanded(
                  child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "List a new Shop",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  onPressed: () async {
                    await _showNewModalSheet(context);
                  },
                ),
              ))
            ]),
            SizedBox(
              height: 16,
            ),
            if (_documents.isEmpty) ...[
              Text("You have no shops registered."),
            ],
            Expanded(
                child: ListView.builder(
                    itemCount: _documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot document = _documents[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: GestureDetector(
                          child: Card(
                            child: ListTile(
                              title: Text(document['name']),
                              subtitle: Text(document['address']),
                              // Add more fields or customize the card as needed
                            ),
                          ),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return MyShopBottomSheet();
                              },
                            );
                          },
                        ),
                      );
                    })),
          ],
        ));
  }
}

class MyShopBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'My Shop',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            title: Text('Shop Reviews'),
            onTap: () {
              // Handle shop reviews button tap
            },
          ),
          ListTile(
            title: Text('Close Shop'),
            onTap: () {
              // Handle close shop button tap
            },
          ),
        ],
      ),
    );
  }
}

Future<LatLng?> getCurrentLocation() async {
  LocationPermission permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.denied) {
    // Handle case when user denies the location permission
    return LatLng(14.4130, 120.9737);
  }

  if (permission == LocationPermission.deniedForever) {
    // Handle case when user denies the location permission permanently
    return LatLng(14.4130, 120.9737);
  }

  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  double latitude = position.latitude;
  double longitude = position.longitude;

  return LatLng(latitude, longitude);
}

Future<String?> getAddressFromCoordinates(
    double latitude, double longitude) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      String address =
          "${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
      return address;
    }
  } catch (e) {
    print(e.toString());
  }
  return null;
}

class JunkshopData {
  String name;
  String description;
  String openTime;
  String closeTime;
  String owner_id;
  LatLng location;
  String? address;
  final geo = GeoFlutterFire();

  JunkshopData(this.name, this.description, this.openTime, this.closeTime,
      this.owner_id, this.location, this.address);

  Future<void> uploadToFirestore() async {
    final _firestore = FirebaseFirestore.instance;
    await getAddressFromCoordinates(location.latitude, location.longitude)
        .then((value) {
      GeoFirePoint loc =
          geo.point(latitude: location.latitude, longitude: location.longitude);
      _firestore.collection("junkshops").add({
        "name": name,
        "address": value,
        "description": description,
        "time": "$openTime to $closeTime",
        "ratings": "0.0",
        "owner_id": owner_id,
        "location": loc.data
      });
    });
  }
}

class NewShopPopup extends StatefulWidget {
  final Function onFinishCallback;
  const NewShopPopup({Key? key, required this.onFinishCallback})
      : super(key: key);
  @override
  _NewShopPopupState createState() => _NewShopPopupState();
}

class _NewShopPopupState extends State<NewShopPopup> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  String? _name;
  String? _desc;
  LatLng? _location;
  String? _openTime;
  String? _closeTime;
  String? _address;

  @override
  void initState() {
    getCurrentLocation().then((value) {
      setState(() {
        _location = value;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<JunkshopMetadata> _showPinLocationModal(BuildContext context) async {
    final LatLng? selectedLocation = await showModalBottomSheet<LatLng>(
      enableDrag: false,
      context: context,
      builder: (BuildContext context) {
        return PinLocationModal(locationOverride: _location);
      },
    );

    final String? address = await getAddressFromCoordinates(
        selectedLocation!.latitude, selectedLocation.longitude);

    return JunkshopMetadata(selectedLocation, address);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'List a new Shop',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: _nameController,
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: _descController,
                onChanged: (value) {
                  setState(() {
                    _desc = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            if (_openTime != null && _closeTime != null) ...[
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        _openTime!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 32),
                      ),
                      Text(
                        " to ",
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        _closeTime!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 32),
                      )
                    ],
                  ))
            ],
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    child: Text("Select opening and closing hours"),
                    onPressed: () async {
                      TimeRange result =
                          await showTimeRangePicker(context: context);
                      setState(() {
                        _openTime = result.startTime.format(context).toString();
                        _closeTime = result.endTime.format(context).toString();
                      });
                    },
                  ))
                ],
              ),
            ),
            SizedBox(height: 16.0),
            if (_location == null)
              ElevatedButton(
                onPressed: () async {
                  await _showPinLocationModal(context).then((value) {
                    setState(() {
                      _location = value.location;
                      _address = value.address;
                    });
                  });
                },
                child: Text('Pin Location'),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Latitude: ${_location?.latitude.toStringAsFixed(6)}'),
                  SizedBox(width: 16.0),
                  Text('Longitude: ${_location?.longitude.toStringAsFixed(6)}'),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      await _showPinLocationModal(context).then((value) {
                        setState(() {
                          _location = value.location;
                          _address = value.address;
                        });
                      });
                    },
                    child: Text('Edit Pin'),
                  ),
                ],
              ),
            SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    child: Text("Create new Shop"),
                    onPressed: () async {
                      if (_name != null &&
                          _desc != null &&
                          _location != null &&
                          _openTime != null &&
                          _closeTime != null) {
                        JunkshopData data = JunkshopData(
                            _name!,
                            _desc!,
                            _openTime!,
                            _closeTime!,
                            FirebaseAuth.instance.currentUser!.uid,
                            _location!,
                            _address);
                        data.uploadToFirestore().then((value) {
                          widget.onFinishCallback();
                          Navigator.pop(context);
                        });
                      }
                    },
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class JunkshopMetadata {
  LatLng location;
  String? address;

  JunkshopMetadata(this.location, this.address);
}

class PinLocationModal extends StatefulWidget {
  final LatLng? locationOverride;
  const PinLocationModal({Key? key, this.locationOverride}) : super(key: key);
  @override
  _PinLocationModalState createState() => _PinLocationModalState();
}

class _PinLocationModalState extends State<PinLocationModal> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    if (widget.locationOverride != null) {
      setState(() {
        _selectedLocation = widget.locationOverride;
      });
    } else {
      setState(() {
        _selectedLocation = LatLng(14.4130, 120.9737);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Pin Location',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GoogleMap(
                  onMapCreated: (controller) {
                    setState(() {
                      _mapController = controller;
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!,
                    zoom: 15.0,
                  ),
                  onCameraMove: (CameraPosition position) {
                    setState(() {
                      _selectedLocation = position.target;
                    });
                  },
                  markers: Set<Marker>.from([
                    Marker(
                      markerId: MarkerId('pin'),
                      position: _selectedLocation!,
                      draggable: true,
                      onDragEnd: (LatLng position) {
                        setState(() {
                          _selectedLocation = position;
                        });
                      },
                    ),
                  ])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedLocation);
              },
              child: Text('Pin Location'),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
