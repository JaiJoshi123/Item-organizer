import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './screens/tabs_screen.dart';

import './helpers/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var db = DBHelper();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => DBHelper(),
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.robotoCondensedTextTheme(
            Theme.of(context).textTheme,
          ),
          primaryColor: Colors.white,
          accentColor: Colors.black12,
          buttonColor: Colors.black,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return SplashScreen();
            } else if (userSnapshot.hasData) {
              return TabsScreen();
            } else if (userSnapshot.hasError) {
              return Center(
                child: Text("Error occured!"),
              );
            } else {
              return AuthScreen();
            }
          },
        ), //ItemCategoryScreen(),
      ),
    );
  }
}
