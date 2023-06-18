import 'package:flutter/material.dart';

class JunkshopItem {
  final String name;
  final List<Junkshop> junkshops;

  JunkshopItem({required this.name, required this.junkshops});
}

class Junkshop {
  final String name;
  final double price;

  Junkshop({required this.name, required this.price});
}

class TopItemsAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _TopItemsAppBarState createState() => _TopItemsAppBarState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class _TopItemsAppBarState extends State<TopItemsAppBar> {
  List<JunkshopItem> topItems = [
    JunkshopItem(
      name: 'Lata',
      junkshops: [
        Junkshop(name: 'MTYJ Junkshop', price: 10.0),
        Junkshop(name: 'Mandias Junkshop', price: 9.0),
        Junkshop(name: 'Car and Ton Junkshop', price: 8.0),
      ],
    ),
    JunkshopItem(
      name: 'Karton',
      junkshops: [
        Junkshop(name: 'Cesar Junkshop', price: 4.0),
        Junkshop(name: 'Penados Junkshop', price: 2.0),
        Junkshop(name: 'Maricar Junkshop', price: 2.50),
      ],
    ),
    JunkshopItem(
      name: 'Bakal',
      junkshops: [
        Junkshop(name: 'P.N.J Junkshop', price: 13.0),
        Junkshop(name: 'Dodoy Junkshop', price: 12.0),
        Junkshop(name: 'MTYJ Junkshop', price: 10.0),
      ],
    ),
    JunkshopItem(
      name: 'Tanso',
      junkshops: [
        Junkshop(name: 'Cesar Junkshop', price: 360.0),
        Junkshop(name: 'Car and Ton Junkshop', price: 330.0),
        Junkshop(name: 'P.N.J Junkshop', price: 320.0),
      ],
    ),
    JunkshopItem(
      name: 'Aluminium',
      junkshops: [
        Junkshop(name: 'P.N.J Junkshop', price: 60.0),
        Junkshop(name: 'Mandias Junkshop', price: 50.0),
        Junkshop(name: 'JD Mande Junkshop', price: 40.0),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('TrashSure'),
      actions: [
        IconButton(
          icon: Icon(Icons.trending_up),
          onPressed: () {
            _showTopItemsDialog();
          },
        ),
      ],
    );
  }

  void _showTopItemsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Market Trends',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                for (int i = 0; i < topItems.length; i++)
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          title: Text(
                            topItems[i].name,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              _showJunkshopsDialog(topItems[i]);
                            },
                            child: Icon(
                              Icons.store_mall_directory_outlined,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showJunkshopsDialog(JunkshopItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Top Junkshops for ${item.name}',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                for (int i = 0; i < item.junkshops.length; i++)
                  ListTile(
                    title: Text(item.junkshops[i].name),
                    subtitle: Text(
                      'Price: ₱${item.junkshops[i].price.toStringAsFixed(2)}/kg',
                    ),
                  ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trashsure',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: TopItemsAppBar(),
        body: Center(
          child: Text('Your App Content'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
