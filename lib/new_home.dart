import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trashsure/my_header_drawer.dart';
import 'package:trashsure/sellRequestComponents/locationPicker.dart';
import 'package:intl/intl.dart';
import 'package:trashsure/sellerHomeComponents/nearestJunkShops.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'main_test.dart';

class Home extends StatefulWidget {
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  LatLng? position;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopItemsAppBar(),
      drawer: const MyHeaderDrawer(),
      body: Column(
        children: [
          Row(
            children: [Expanded(child: MapComponent())],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                    child: MaterialButton(
                  color: Color(0xff45b5a8),
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (Builder) {
                          return const BottomPopUpModal();
                        });
                  },
                  child: const Text(
                    "Sell on Marketplace",
                    style: TextStyle(color: Colors.white),
                  ),
                ))
              ],
            ),
          ),
          const NearestJunkShop()
        ],
      ),
    );
  }
}

class BottomPopUpModal extends StatefulWidget {
  const BottomPopUpModal({Key? key}) : super(key: key);

  @override
  State<BottomPopUpModal> createState() => _BottomPopUpModalState();
}

class _BottomPopUpModalState extends State<BottomPopUpModal> {
  List<XFile>? pickedImages;
  int? weight;
  double? price;
  String? items, description;
  DateTime selectedDate = DateTime.now();
  TextEditingController _date = TextEditingController();

  Future<void> _uploadImages(String id) async {
    for (int i = 0; i < pickedImages!.length; i++) {
      File file = File(pickedImages![i].path);

      Reference storageReference = FirebaseStorage.instance.ref().child(
          '${id}/${pickedImages![i].name}'); // Replace 'your_folder_name' with your desired folder in Firebase Storage

      await storageReference.putFile(file);
    }
  }

  Future<dynamic> getUserById(String userId) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    DocumentSnapshot userDoc = await usersCollection.doc(userId).get();
    return userDoc.data();
  }

  Future<String> getNumber(String userId) async {
    dynamic user = await getUserById(userId);
    return user!['phone'];
  }

  Future<String> getAddress(String userId) async {
    dynamic user = await getUserById(userId);
    return user!['address'];
  }

  Widget build(BuildContext context) {
    double mWidth = MediaQuery.of(context).size.width;
    double mHeight = MediaQuery.of(context).size.height;
    return Container(
      width: mWidth,
      height: mHeight * 0.8,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          Row(
            children: const [
              Text(
                "Sell in Marketplace",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // SizedBox(
          //   height: 12,
          // ),
          // Row(
          //   children: [
          //     Expanded(
          //         child: MaterialButton(
          //       color: Colors.deepPurple[200],
          //       onPressed: () async {
          //         ImagePicker picker = ImagePicker();
          //         List<XFile>? pickedFiles = await picker.pickMultiImage();
          //         setState(() {
          //           pickedImages = pickedFiles;
          //         });
          //       },
          //       padding: EdgeInsets.symmetric(vertical: 12),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(
          //             Icons.add_a_photo,
          //             color: Colors.white,
          //           ),
          //           SizedBox(
          //             width: 8,
          //           ),
          //           Text(
          //             "Add Photos",
          //             style: TextStyle(color: Colors.white),
          //           )
          //         ],
          //       ),
          //     ))
          //   ],
          // ),
          // SizedBox(
          //   height: 12,
          // ),
          if (pickedImages != null) ...[
            Expanded(
              child: GridView.builder(
                itemCount: pickedImages!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Image.file(
                    File(pickedImages![index].path),
                    fit: BoxFit.cover,
                  );
                },
              ),
            )
          ],
          SizedBox(
            height: 18,
          ),
          Card(
            elevation: 4,
            child: TextField(
                onChanged: (value) {
                  setState(() {
                    items = value;
                  });
                },
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.only(top: 16), // add padding to adjust text
                  isDense: true,
                  hintText: "Items to Sell",
                  prefixIcon: Padding(
                    padding:
                        EdgeInsets.only(top: 4), // add padding to adjust icon
                    child: Icon(Icons.sell),
                  ),
                )),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 4,
            child: TextField(
                onChanged: (value) {
                  setState(() {
                    weight = int.parse(value);
                  });
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.only(top: 16), // add padding to adjust text
                  isDense: true,
                  hintText: "Weight of Items in KG",
                  prefixIcon: Padding(
                    padding:
                        EdgeInsets.only(top: 4), // add padding to adjust icon
                    child: Icon(Icons.monitor_weight),
                  ),
                )),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 4,
            child: TextField(
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.only(top: 16), // add padding to adjust text
                  isDense: true,
                  hintText: "Description",
                  prefixIcon: Padding(
                    padding:
                        EdgeInsets.only(top: 4), // add padding to adjust icon
                    child: Icon(Icons.description),
                  ),
                )),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 4,
            child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    price = double.parse(value);
                  });
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(top: 16),
                  isDense: true,
                  hintText: "Price",
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.sell_rounded),
                  ),
                )),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MaterialButton(
                onPressed: () {
                  setState(() {
                    items = null;
                    weight = null;
                    description = null;
                    pickedImages = null;
                  });
                  Navigator.pop(context);
                },
                color: Color(0xff45b5a8),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  if (items != null && weight != null && pickedImages != null) {
                    FirebaseFirestore.instance.collection("marketplace").add({
                      "items": items,
                      "weight": weight,
                      "description": description,
                      "owner_id": FirebaseAuth.instance.currentUser?.uid,
                      "buyer_id": null,
                      "bought": false,
                      "phone": await getNumber(
                          FirebaseAuth.instance.currentUser!.uid),
                      "address": await getAddress(
                          FirebaseAuth.instance.currentUser!.uid),
                      "price": price,
                      "seller_id": FirebaseAuth.instance.currentUser!.uid,
                    }).then((value) {
                      if (pickedImages != null && pickedImages!.isNotEmpty) {
                        _uploadImages(value.id)
                            .then((value) => {Navigator.pop(context)});
                      }
                    });
                  } else {
                    // set up the button
                    Widget okButton = TextButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    );

                    // set up the AlertDialog
                    AlertDialog alert = AlertDialog(
                      title: const Text("Missing Fields"),
                      content: const Text(
                          "You are missing some information in your listing. Please try again."),
                      actions: [
                        okButton,
                      ],
                    );

                    // show the dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
                  }
                },
                color: const Color(0xff45b5a8),
                child: const Text(
                  "Confirm",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          )
        ]),
      ),
    );
  }
}

class MapComponent extends StatefulWidget {
  State<MapComponent> createState() => _MapComponent();
}

class _MapComponent extends State<MapComponent> {
  GoogleMapController? _mapController;
  LatLng? location;
  Set<Marker> markers = Set();

  @override
  void initState() {
    super.initState();
  }

  Future<bool?> requestLocationPermission() async {
    var permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      var position = await Geolocator.getCurrentPosition();
      var docs = await getNearbyJunkshops(position);
      var newMarkers = await nearbyJunkshopsAsMarkers(docs);
      setState(() {
        location = LatLng(position.latitude, position.longitude);
        markers = newMarkers;
      });
      return true;
    } else {
      return false;
    }
  }

  Future<List<DocumentSnapshot>> getNearbyJunkshops(Position position) async {
    GeoFirestore geo =
        GeoFirestore(FirebaseFirestore.instance.collection("junkshops"));
    return await geo.getAtLocation(
        GeoPoint(position.latitude, position.longitude), 100);
  }

  Future<Set<Marker>> nearbyJunkshopsAsMarkers(
      List<DocumentSnapshot> docs) async {
    Set<Marker> markers = Set();
    docs.forEach((doc) {
      Map data = doc.data() as Map;
      Marker marker = Marker(
          onTap: () {
            showModalBottomSheet(
                isScrollControlled: true,
                useSafeArea: true,
                context: context,
                builder: (context) {
                  return JunkshopWidget(
                    id: doc.id,
                    user_location: location!,
                  );
                });
          },
          markerId: MarkerId(doc.id),
          position: LatLng(data['l'][0], data['l'][1]));
      markers.add(marker);
    });

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    if (location != null) {
      return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          height: 300,
          child: GoogleMap(
            markers: markers,
            onMapCreated: (controller) {
              //method called when map is created
              setState(() {
                _mapController = controller;
              });
            },
            initialCameraPosition: CameraPosition(target: location!, zoom: 12),
          ));
    } else {
      return Container(
        height: 300,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: FutureBuilder(
              future: requestLocationPermission(),
              builder: (context, AsyncSnapshot<bool?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 8,
                      ),
                      Text('Retrieving your location'),
                    ],
                  );
                } else if (snapshot.connectionState == ConnectionState.done &&
                    !snapshot.data!) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Location access was denied. You must enable location access for Trashsure to work properly. You can do this by changing the permissions for Trashsure in your settings and allowing location access while using the app.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),
        ),
      );
    }
  }
}

class JunkshopWidget extends StatefulWidget {
  final String id;
  final LatLng user_location;
  JunkshopWidget({required this.id, required this.user_location});
  State<JunkshopWidget> createState() => _JunkshopWidgetState();
}

class _JunkshopWidgetState extends State<JunkshopWidget> {
  Map? data;
  bool isOpen = false;
  List<Item> cart = [];
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("junkshops")
        .doc(widget.id)
        .get()
        .then((value) {
      setState(() {
        data = value.data();
      });
      print(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    var openingHour = int.parse((data!['opening'] as String).split(':')[0]);
    var closingHour = int.parse((data!['closing'] as String).split(':')[0]);
    var openingMin = int.parse((data!['opening'] as String).split(':')[1]);
    var closingMin = int.parse((data!['closing'] as String).split(':')[1]);
    DateTime currentTime = DateTime.now();
    TimeOfDay startTime = TimeOfDay(hour: openingHour, minute: openingMin);
    TimeOfDay endTime = TimeOfDay(hour: closingHour, minute: closingMin);

    DateTime currentDateTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      currentTime.hour,
      currentTime.minute,
    );

    DateTime startDateTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      startTime.hour,
      startTime.minute,
    );

    DateTime endDateTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      endTime.hour,
      endTime.minute,
    );

    if (currentDateTime.isAfter(startDateTime) &&
        currentDateTime.isBefore(endDateTime)) {
      setState(() {
        isOpen = true;
      });
    } else {
      setState(() {
        isOpen = false;
      });
    }
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Expanded(
              child: ListView(
            children: [
              if (data != null) ...[
                //Change image size
                CachedNetworkImage(
                  height: 250,
                  width: 250,
                  imageUrl:
                      "https://firebasestorage.googleapis.com/v0/b/trashsureee-4106e.appspot.com/o/junkshops%2F${data!['owner']}.jpg?alt=media&token=4136e890-f05c-4437-a635-a9816390406b",
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Text(
                    data!['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('${data!['phone'] ?? ""}',
                      style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Text(
                        "${openingHour}:${(data!['opening'] as String).split(':')[1]} to ${closingHour}:${(data!['closing'] as String).split(':')[1]}",
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Text(
                        isOpen ? "Open now" : "Closed",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isOpen ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    (Geolocator.distanceBetween(
                                    data!['l'][0],
                                    data!['l'][1],
                                    widget.user_location.latitude,
                                    widget.user_location.longitude) /
                                1000)
                            .toStringAsFixed(2) +
                        " km away",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Items we buy",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    )),
                SizedBox(
                  height: 16,
                ),
                ...(data!['items'] as List).map((item) {
                  return Padding(
                      padding: EdgeInsets.only(left: 12, right: 12, bottom: 16),
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            Item itemToAdd = await showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return ItemQuantitySelector(
                                      name: item!['name'],
                                      price: double.parse(
                                          item!['price'].toString()));
                                });
                            var newCart = cart;
                            newCart.add(itemToAdd);
                            setState(() {
                              cart = newCart;
                            });
                          } catch (e) {
                            log(e.toString());
                          }
                        },
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                    Text(
                                      "₱" + item['price'].toString() + "/kg",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(child: SizedBox.shrink()),
                                Icon(Icons.add),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                        ),
                      ));
                }).toList(),
              ]
            ],
          )),
          if (cart.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xff45b5a8)),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                useSafeArea: true,
                                context: context,
                                builder: (context) {
                                  return SellRequests(
                                      items: cart,
                                      junkshop_id: widget.id,
                                      fare: Geolocator.distanceBetween(
                                              data!['l'][0],
                                              data!['l'][1],
                                              widget.user_location.latitude,
                                              widget.user_location.longitude) /
                                          1000);
                                });
                          },
                          child: Text("View items in request")))
                ],
              ),
            )
        ],
      ),
    );
  }
}

class Item {
  final String name;
  final double subtotal;
  final double price;
  final num quantity;

  Item(this.name, this.subtotal, this.price, this.quantity);
}

class ItemQuantitySelector extends StatefulWidget {
  final String name;
  final double price;

  ItemQuantitySelector({required this.name, required this.price});

  @override
  _ItemQuantitySelectorState createState() => _ItemQuantitySelectorState();
}

class _ItemQuantitySelectorState extends State<ItemQuantitySelector> {
  num quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      "₱${widget.price.toString()} per kilo",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Expanded(child: SizedBox.shrink()),
                Column(
                  children: [
                    Text("Subtotal"),
                    Text(
                      "₱" + (quantity * widget.price).toStringAsFixed(2),
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    )
                  ],
                )
              ],
            ),
            Expanded(child: SizedBox.shrink()),
            Row(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xff45b5a8)),
                  ),
                  onPressed: () {
                    if (quantity > 0) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                  child: Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    quantity.toString(),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xff45b5a8)),
                  ),
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                  child: Icon(Icons.add),
                ),
                SizedBox(
                  width: 32,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xff45b5a8)),
                    ),
                    onPressed: () {
                      Navigator.pop(
                          context,
                          Item(widget.name, quantity * widget.price,
                              widget.price, quantity));
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SellRequests extends StatefulWidget {
  List<Item> items;
  String junkshop_id;
  double fare;
  SellRequests(
      {required this.items, required this.junkshop_id, required this.fare});
  State<SellRequests> createState() => _SellRequestsState();
}

class _SellRequestsState extends State<SellRequests> {
  XFile? pickedFile;
  DateTime? startDate;
  DateTime? endDate;
  LatLng? pin;
  String? startDateString;
  String? endDateString;
  double calculateFare(double distance) {
    const double initialRate = 30.0; // Fare for the first 5 kilometers
    const double additionalRate =
        2.0; // Fare per kilometer after the first 5 kilometers

    double fare = 0.0;

    if (distance <= 5) {
      fare = initialRate;
    } else {
      fare = initialRate + (additionalRate * (distance - 5));
    }

    return fare;
  }

  double calculateTotal(double fare) {
    double total = 0.0;
    for (var item in widget.items) {
      total += item.price * item.quantity;
    }
    return total - fare;
  }

  Future<dynamic> getUserById(String userId) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    DocumentSnapshot userDoc = await usersCollection.doc(userId).get();
    return userDoc.data();
  }

  Future<String> getNumber(String userId) async {
    dynamic user = await getUserById(userId);
    return user!['phone'];
  }

  getBuyer() async {
    var doc = await FirebaseFirestore.instance
        .collection('junkshops')
        .doc(widget.junkshop_id)
        .get();
    var sellerId = (doc.data() as Map)['owner'];
    return sellerId;
  }

  writeNotification() async {
    FirebaseFirestore.instance.collection("notification").add({
      "user_id": await getBuyer(),
      "content":
          'You have a sell request you can pick up from ${DateFormat('MMM d yyyy').format(startDate!)} - ${DateFormat('MMM d yyyy').format(endDate!)}',
      "isRead": false
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: pickedFile != null
          ? MediaQuery.of(context).size.height * 0.9
          : MediaQuery.of(context).size.height * 0.6,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children: [
          Text(
            "Sell Request",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 16,
          ),
          if (pickedFile != null)
            Image.file(
              File(pickedFile!.path),
              height: MediaQuery.of(context).size.height * 0.25,
            ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Text("Item Name"),
              Expanded(child: SizedBox.shrink()),
              Text("Subtotal")
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                ...widget.items.map((item) {
                  return Row(children: [
                    Text(item.quantity.toString() +
                        "kg " +
                        item.name +
                        " @ P" +
                        item.price.toStringAsFixed(2)),
                    Expanded(child: SizedBox.shrink()),
                    Text("P" + item.subtotal.toStringAsFixed(2))
                  ]);
                }).toList(),
                Row(children: [
                  Text("Pick up fare"),
                  Expanded(child: SizedBox.shrink()),
                  Text(
                    "- P" + (calculateFare(widget.fare)).toStringAsFixed(2),
                    style: TextStyle(color: Colors.red),
                  )
                ])
              ],
            ),
          ),
          Row(children: [
            Text("You will receive (Negative denotes debit): "),
            Expanded(child: SizedBox.shrink()),
            Text(
              "P " +
                  calculateTotal(calculateFare(widget.fare)).toStringAsFixed(2),
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: calculateTotal(calculateFare(widget.fare)) > 0
                      ? Colors.black
                      : Colors.red),
            ),
          ]),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Provide a photo of the items you want to sell:",
            ),
          ),
          if (pickedFile == null) ...[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xff45b5a8)),
              ),
              child: Text("Select a photo"),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  pickedFile = image;
                });
              },
            )
          ] else ...[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(const Color(
                    0xff45b5a8)), // Set the desired background color
              ),
              child: const Text("Replace photo"),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  pickedFile = image;
                });
              },
            )
          ],
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Select a range date for pick up:",
            ),
          ),
          if (startDate != null) Text(startDateString!),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(const Color(0xff45b5a8)),
            ),
            child: const Text("Select start date"),
            onPressed: () async {
              final DateTime? datePicked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2024));
              if (datePicked != null) {
                setState(() {
                  startDate = datePicked;
                  startDateString = DateFormat('MMM d yyyy').format(startDate!);
                });
              }
            },
          ),
          if (endDate != null) Text(endDateString!),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary:
                  startDate != null ? const Color(0xff45b5a8) : Colors.grey,
            ),
            onPressed: startDate != null
                ? () async {
                    final DateTime? datePicked = await showDatePicker(
                        context: context,
                        initialDate: startDate!,
                        firstDate: startDate!,
                        lastDate: startDate!.add(const Duration(days: 7)));
                    if (datePicked != null) {
                      setState(() {
                        endDate = datePicked;
                        endDateString =
                            DateFormat('MMM d yyyy').format(endDate!);
                      });
                    }
                  }
                : null,
            child: const Text("Select end date"),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Set pick up location:",
            ),
          ),
          if (pin != null) Text(pin.toString()),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xff45b5a8)),
              ),
              onPressed: () async {
                LatLng temp = await showModalBottomSheet(
                    context: context,
                    enableDrag: false,
                    builder: (builder) {
                      return const PickLocation();
                    });
                setState(() {
                  pin = temp;
                });
              },
              child: const Text("Select location")),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: (pickedFile != null &&
                            startDate != null &&
                            endDate != null &&
                            pin != null)
                        ? const Color(0xff45b5a8)
                        : Colors.grey),
                onPressed: () async {
                  if (pickedFile != null &&
                      startDate != null &&
                      endDate != null &&
                      pin != null) {
                    List<Map<String, dynamic>> items = [];
                    widget.items.forEach((element) {
                      items.add({
                        "name": element.name,
                        "price": element.price,
                        "quantity": element.quantity,
                        "subtotal": element.subtotal,
                      });
                    });
                    await FirebaseFirestore.instance
                        .collection("requests")
                        .add({
                      "items": items,
                      "timestamp": DateTime.now(),
                      "owner": FirebaseAuth.instance.currentUser!.uid,
                      "junkshop_id": widget.junkshop_id,
                      "pickup_date": [startDate, endDate],
                      "status": "PENDING",
                      "fare": calculateFare(widget.fare),
                      "total": calculateTotal(calculateFare(widget.fare)),
                      "pickup_location": [pin?.latitude, pin?.longitude],
                      "phone": await getNumber(
                          FirebaseAuth.instance.currentUser!.uid),
                    }).then((value) async {
                      await FirebaseStorage.instance
                          .ref(value.id)
                          .putFile(File(pickedFile!.path));
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Important Notice'),
                            content: const Text(
                              'Please be aware that the price displayed is an estimated value and subject to change based on the actual weight and other relevant factors. The final price will be determined during the evaluation process. Thank you for your understanding.',
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                      Navigator.pop(context);
                    });
                    await writeNotification();
                  } else {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                  "Please attach a photo and a pick-up date to this sell request."),
                            ),
                          );
                        });
                  }
                },
                child: Text("Send Sell Request"),
              ))
            ],
          )
        ]),
      ),
    );
  }
}
