import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trashsure/my_header_drawer.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  final DocumentSnapshot userData;
  final LatLng position;
  const HomePage({Key? key, required this.userData, required this.position})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  GoogleMapController? mapController; //contrller for Google map
  Set<Marker> markers = Set(); //markers for google map
  LatLng showLocation = LatLng(14.413, 120.9737);

  @override
  void initState() {
    final geo = GeoFlutterFire();
    final _firestore = FirebaseFirestore.instance;

    final center = geo.point(
        latitude: widget.position.latitude,
        longitude: widget.position.longitude);

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: _firestore.collection("junkshops"))
        .within(center: center, radius: 20, field: "location");

    stream.listen((event) {
      Set<Marker> markers_new = Set();
      event.forEach((element) {
        log("Hi");
        dynamic data = element.data();
        LatLng location = LatLng(data['location']['geopoint'].latitude,
            data['location']['geopoint'].longitude);
        markers_new.add(Marker(
          markerId: MarkerId(data['location']['geohash'].toString()),
          position: LatLng(data['location']['geopoint'].latitude,
              data['location']['geopoint'].longitude), //position of marker
          onTap: () {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (Builder) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: JunkshopWidget(
                        loc: LatLng(data['location']['geopoint'].latitude,
                            data['location']['geopoint'].longitude)),
                  );
                });
          },
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        ));
      });
      setState(() {
        markers = markers_new;
      });
    });

    //you can add more markers here
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff45b5a8),
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: Color(0xff45b5a8)),
        title: Text("Trashsure"),
        centerTitle: true,
      ),
      drawer: MyHeaderDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: GoogleMap(
              //Map widget from google_maps_flutter package
              zoomGesturesEnabled: true, //enable Zoom in, out on map
              initialCameraPosition: CameraPosition(
                //innital position in map
                target: LatLng(widget.position.latitude,
                    widget.position.longitude), //initial position
                zoom: 10.0, //initial zoom level
              ),
              markers: markers, //markers to show on map
              mapType: MapType.normal, //map type

              onMapCreated: (controller) {
                //method called when map is created
                setState(() {
                  mapController = controller;
                });
              },
            )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(children: [
                Row(
                  children: [
                    Text(
                      "Enter location",
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
                TextField(
                    decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.only(top: 20), // add padding to adjust text
                  isDense: true,
                  hintText: "Search Address",
                  prefixIcon: Padding(
                    padding:
                        EdgeInsets.only(top: 15), // add padding to adjust icon
                    child: Icon(Icons.search),
                  ),
                )),
                Row(
                  children: [
                    Expanded(
                        child: MaterialButton(
                      color: Colors.deepPurple[200],
                      onPressed: () {
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (Builder) {
                              return BottomPopUpModal();
                            });
                      },
                      child: Text(
                        "Sell on Marketplace",
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: 240,
                )
              ]),
            )
          ],
        ),
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
  String? items, description;
  DateTime selectedDate = DateTime.now();
  TextEditingController _date = TextEditingController();
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2023),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _date.value = TextEditingValue(text: picked.toString());
      });
  }

  Future<void> _uploadImages(String id) async {
    for (int i = 0; i < pickedImages!.length; i++) {
      File file = File(pickedImages![i].path);

      Reference storageReference = FirebaseStorage.instance.ref().child(
          '${id}/${pickedImages![i].name}'); // Replace 'your_folder_name' with your desired folder in Firebase Storage

      await storageReference.putFile(file);
    }
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
            children: [
              Text(
                "Sell in Marketplace",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Expanded(
                  child: MaterialButton(
                color: Colors.deepPurple[200],
                onPressed: () async {
                  ImagePicker picker = ImagePicker();
                  List<XFile>? pickedFiles = await picker.pickMultiImage();
                  setState(() {
                    pickedImages = pickedFiles;
                  });
                },
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Add Photos",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ))
            ],
          ),
          SizedBox(
            height: 12,
          ),
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
            height: 24,
          ),
          Card(
            elevation: 4,
            child: TextField(
                onChanged: (value) {
                  setState(() {
                    items = value;
                  });
                },
                decoration: InputDecoration(
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
          Card(
            elevation: 4,
            child: TextField(
                onChanged: (value) {
                  setState(() {
                    weight = int.parse(value);
                  });
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
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
          Card(
            elevation: 4,
            child: TextField(
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                decoration: InputDecoration(
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
          GestureDetector(
            onTap: () {
              _selectDate(context);
            },
            child: AbsorbPointer(
                child: Card(
              elevation: 4,
              child: TextField(
                  controller: _date,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.only(top: 16), // add padding to adjust text
                    isDense: true,
                    hintText: "Date",
                    prefixIcon: Padding(
                      padding:
                          EdgeInsets.only(top: 4), // add padding to adjust icon
                      child: Icon(Icons.date_range),
                    ),
                  )),
            )),
          ),
          Expanded(
            child: SizedBox(
              height: 1,
            ),
          ),
          Row(
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
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.deepPurple[200],
              ),
              Expanded(
                child: SizedBox(),
              ),
              MaterialButton(
                onPressed: () async {
                  if (items != null &&
                      weight != null &&
                      pickedImages != null &&
                      selectedDate != null) {
                    FirebaseFirestore.instance.collection("marketplace").add({
                      "items": items,
                      "weight": weight,
                      "description": description,
                      "date": selectedDate,
                      "owner_id": FirebaseAuth.instance.currentUser?.uid,
                      "bought": false
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
                      title: Text("Missing Fields"),
                      content: Text(
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
                child: Text(
                  "Confirm",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.deepPurple[200],
              )
            ],
          )
        ]),
      ),
    );
  }
}

@override
class JunkshopWidget extends StatefulWidget {
  final LatLng loc;
  const JunkshopWidget({Key? key, required this.loc}) : super(key: key);

  @override
  State<JunkshopWidget> createState() => _JunkshopWidgetState();
}

class _JunkshopWidgetState extends State<JunkshopWidget> {
  bool expanded = false;
  bool sent = false;
  DocumentSnapshot? junkshopData;
  String? category;
  String? other_category;
  XFile? pickedFile;
  DateTime? date;
  String req_id = "";
  List<bool> isCheckedList = List.generate(10, (index) => false);
  List<String> weightList = List.generate(10, (index) => '');

  Future<QuerySnapshot> getJunkshopByCoordinates(
      double latitude, double longitude) async {
    CollectionReference junkshopsCollection =
        FirebaseFirestore.instance.collection('junkshops');

    QuerySnapshot querySnapshot = await junkshopsCollection
        .where('location.geopoint', isEqualTo: GeoPoint(latitude, longitude))
        .limit(1)
        .get();

    setState(() {
      junkshopData = querySnapshot.docs[0];
    });

    return querySnapshot;
  }

  TextStyle bold_large = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  TextStyle bold_medium = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  TextStyle regular_normal = TextStyle(fontSize: 16);

  String _getCheckboxTitle(int index) {
    switch (index) {
      case 0:
        return 'Cardboard';
      case 1:
        return 'Copper';
      case 2:
        return 'Paper';
      case 3:
        return 'Iron Alloys';
      case 4:
        return 'Newspaper';
      case 5:
        return 'Bottles';
      case 6:
        return 'Assorted Papers';
      case 7:
        return 'Aluminum Can';
      case 8:
        return 'Inkjet Cartridge';
      case 9:
        return 'Others';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      width: MediaQuery.of(context).size.width,
      height: expanded
          ? MediaQuery.of(context).size.height * 0.8
          : MediaQuery.of(context).size.height * 0.25,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: FutureBuilder(
            future: getJunkshopByCoordinates(
                widget.loc.latitude, widget.loc.longitude),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                dynamic snapshotData = snapshot.data!.docs[0].data();
                return ListView(
                  children: [
                    if (!expanded && !sent) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          snapshotData['name'],
                          style: bold_large,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          snapshotData['address'],
                          style: regular_normal,
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.star),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    snapshotData['ratings'],
                                    style: bold_medium,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.punch_clock),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    snapshotData['time'],
                                    style: regular_normal,
                                  ),
                                ],
                              )
                            ]),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                            child: Text("Send a Sell Request"),
                            onPressed: () {
                              setState(() {
                                expanded = !expanded;
                              });
                            },
                          ))
                        ],
                      )
                    ] else if (!sent) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Sell Request",
                          style: bold_large,
                        ),
                      ),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text("Sending Request to: ",
                                  style: TextStyle(fontSize: 16)),
                              Text(
                                snapshotData['name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )
                            ],
                          )),
                      SizedBox(
                        height: 16,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Choose on the following you wish to sell:",
                          style: regular_normal,
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      for (var i = 0; i < 10; i++)
                        ListTile(
                          leading: Checkbox(
                            value: isCheckedList[i],
                            onChanged: (bool? value) {
                              setState(() {
                                isCheckedList[i] = value!;
                              });
                            },
                          ),
                          title: Text(
                            _getCheckboxTitle(i),
                          ),
                          trailing: SizedBox(
                            width: 120,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (String value) {
                                setState(() {
                                  weightList[i] = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Weight in Kg',
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 16,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Provide a photo of the items you want to sell:",
                          style: regular_normal,
                        ),
                      ),
                      Row(
                        children: [
                          if (pickedFile == null) ...[
                            Expanded(
                                child: ElevatedButton(
                              child: Text("Select a photo"),
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery);
                                setState(() {
                                  pickedFile = image;
                                });
                              },
                            ))
                          ] else ...[
                            Expanded(
                                child: ElevatedButton(
                              child: Text("Replace photo"),
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery);
                                setState(() {
                                  pickedFile = image;
                                });
                              },
                            ))
                          ]
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Choose the most convenient date for you:",
                          style: regular_normal,
                        ),
                      ),
                      if (date == null) ...[
                        ElevatedButton(
                          child: Text("Select a date"),
                          onPressed: () async {
                            final DateTime? datePicked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2024));
                            if (datePicked != null) {
                              setState(() {
                                date = datePicked;
                              });
                            }
                          },
                        )
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "${date?.month}/${date?.day}/${date?.year}",
                              style: bold_medium,
                            ),
                            ElevatedButton(
                              child: Text("Replace date"),
                              onPressed: () async {
                                final DateTime? datePicked =
                                    await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2023));
                                if (datePicked != null) {
                                  setState(() {
                                    date = datePicked;
                                  });
                                }
                              },
                            )
                          ],
                        )
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel")),
                          ElevatedButton(
                              onPressed: () {
                                if (date != null && pickedFile != null) {
                                  FirebaseFirestore.instance
                                      .collection("requests")
                                      .add({
                                    "items": {
                                      for (int i = 0; i < 10; i++)
                                        {_getCheckboxTitle(i): weightList[i]}
                                    },
                                    "date": date,
                                    "owner_id":
                                        FirebaseAuth.instance.currentUser?.uid,
                                    "junkshop_id": junkshopData?.id,
                                    "complete": false
                                  }).then((value) {
                                    FirebaseStorage.instance
                                        .ref(value.id)
                                        .putFile(File(pickedFile!.path))
                                        .then(
                                      (p0) {
                                        setState(() {
                                          pickedFile = null;
                                          req_id = value.id;
                                          sent = true;
                                        });
                                      },
                                    );
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
                                    title: Text("Missing Fields"),
                                    content: Text(
                                        "You are missing some information in your sell request. Please try again."),
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
                              child: Text("Confirm"))
                        ],
                      )
                    ] else ...[
                      Text(
                        "Sell Request",
                        style: bold_large,
                      ),
                      Text(
                        "${date?.month}/${date?.day}/${date?.year}",
                        style: bold_medium,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  snapshotData['name'],
                                  style: bold_medium,
                                ),
                              ),
                              Text(
                                snapshotData['address'],
                                style: regular_normal,
                              ),
                            ],
                          )),
                          Expanded(
                              child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Request ID",
                                  style: regular_normal,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  req_id,
                                  style: regular_normal,
                                ),
                              ),
                            ],
                          )),
                        ],
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      SizedBox(
                        height: 64,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                            child: Text("Finish"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ))
                        ],
                      )
                    ]
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }
}
