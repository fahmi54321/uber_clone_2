import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone_2/dataprovider/appdata.dart';
import 'package:uber_clone_2/mainpage.dart';
import 'package:uber_clone_2/screens/loginpage.dart';
import 'package:uber_clone_2/screens/registerpage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:297855924061:ios:c6de2b69b03a5be8',
      gcmSenderID: '297855924061',
      databaseURL: 'https://uber-clone-33688-default-rtdb.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:414658273257:android:6a25bf0fdd5c2b33c8b578',
      apiKey: 'AIzaSyDkcO01UIRRvWzdcb99HR62-0ra2GsFUIk',
      databaseURL: 'https://uber-clone-33688-default-rtdb.firebaseio.com',
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.blue,
        ),
        home: MainPage(),
        initialRoute: MainPage.id,
        routes: {
          RegisterPage.id : (context) => RegisterPage(),
          LoginPage.id : (context) => LoginPage(),
          MainPage.id : (context) => MainPage(),
        },
      ),
    );
  }
}

