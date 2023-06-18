import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool offers = true;
  bool location_services = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Language'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle language selection
            },
          ),
          ListTile(
            title: Text('Receive push notification'),
            trailing: Switch(
              value: notifications,
              onChanged: (value) {
                setState(() {
                  notifications = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Receive offers by email'),
            trailing: Switch(
              value: offers,
              onChanged: (value) {
                setState(() {
                  offers = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Enable Location Services'),
            trailing: Switch(
              value: location_services,
              onChanged: (value) {
                setState(() {
                  location_services = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
