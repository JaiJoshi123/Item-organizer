import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = "/Settings";
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy_outlined),
            Text("Under construction"),
          ],
        ),
      ),
    );
  }
}
