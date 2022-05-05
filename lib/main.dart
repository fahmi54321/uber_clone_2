import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone_2/dataprovider/appdata.dart';
import 'package:uber_clone_2/globalvariable.dart';
import 'package:uber_clone_2/mainpage.dart';
import 'package:uber_clone_2/screens/loginpage.dart';
import 'package:uber_clone_2/screens/registerpage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:448216127030:android:50dede8b8479a13e62aa97',
      gcmSenderID: '297855924061',
      databaseURL: 'https://uber-d5e16-default-rtdb.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:448216127030:android:50dede8b8479a13e62aa97',
      apiKey: 'AIzaSyD12_TVFRT2F_k-QMrfFt7vUpYhITwoHYQ',
      databaseURL: 'https://uber-d5e16-default-rtdb.firebaseio.com',
    ),
  );

  //todo 1
  currentFirebaseUser = await FirebaseAuth.instance.currentUser();


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
        home: LoginPage(),
        initialRoute: (currentFirebaseUser == null) ? LoginPage.id : MainPage.id, //todo 2 (finish)
        routes: {
          RegisterPage.id : (context) => RegisterPage(),
          LoginPage.id : (context) => LoginPage(),
          MainPage.id : (context) => MainPage(),
        },
      ),
    );
  }
}

