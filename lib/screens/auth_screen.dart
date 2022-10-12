import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/db_helper.dart';

class AuthScreen extends StatelessWidget {
  var userEmail = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Item Organizer",
                style: TextStyle(fontSize: 50),
              ),
              ClipOval(
                child: SizedBox(
                  height: 256,
                  width: 256,
                  child: Image.asset('assets/images/app_logo.png'),
                ),
              ),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () async {
                    await Provider.of<DBHelper>(context, listen: false)
                        .googleLogin();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 30,
                          child: Image.asset(
                            'assets/images/google_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ), // <-- Use 'Image.asset(...)' here
                        SizedBox(width: 12),
                        Text(
                          'Sign in with Google',
                          style: TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
