import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text('Profile'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('My Addresses'),
            leading: Icon(Icons.location_on),
            onTap: () {
              // Handle My Addresses option
              // You can navigate to a new page or perform an action
            },
          ),
          ListTile(
            title: Text('Change Email Address'),
            leading: Icon(Icons.email),
            onTap: () {
              // Handle Change Email Address option
              // You can navigate to a new page or perform an action
            },
          ),
          ListTile(
            title: Text('Change Password'),
            leading: Icon(Icons.lock),
            onTap: () {
              // Handle Change Password option
              // You can navigate to a new page or perform an action
            },
          ),
        ],
      ),
    );
  }
}
