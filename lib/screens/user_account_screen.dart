import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/db_helper.dart';

import '../widgets/clickable_image.dart';

class UserAccountScreen extends StatefulWidget {
  static const routeName = "/user";

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DBHelper>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello, ${provider.getCurrentUser.displayName}"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        primary: false,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: ClipOval(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.width * 0.6,
                  child: ClickableImage(
                    image: provider.getCurrentUser.photoURL!,
                    isFile: false,
                    imageId: provider.getCurrentUser.uid,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              provider.getCurrentUser.email!,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 26),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Center(
            child: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).buttonColor,
                ),
              ),
              onPressed: () async {
                await provider.logout();
              },
              icon: Icon(Icons.logout),
              label: Text("Logout"),
            ),
          ),
        ],
      ),
    );
  }
}
