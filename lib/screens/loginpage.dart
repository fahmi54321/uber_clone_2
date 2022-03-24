import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uber_clone_2/brand_colors.dart';
import 'package:uber_clone_2/mainpage.dart';
import 'package:uber_clone_2/screens/registerpage.dart';
import 'package:uber_clone_2/widgets/progress_dialog.dart';
import 'package:uber_clone_2/widgets/taxi_button.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  var emailControler = TextEditingController();

  var passwordControler = TextEditingController();

  void login() async {

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) => ProgressDialog(status: 'Logging you in'),
    );

    final FirebaseUser user = (await _auth
            .signInWithEmailAndPassword(
      email: emailControler.text,
      password: passwordControler.text,
    ).catchError((ex) {


      // check error and display message
      Navigator.pop(context); // close dialog
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);


    })).user;

    if (user != null) {
      DatabaseReference databaseReference =
          FirebaseDatabase.instance.reference().child('users/${user.uid}');

      databaseReference.once().then((snapshot) {
        if (snapshot.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, MainPage.id, (route) => false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                ),
                Image(
                  alignment: Alignment.center,
                  height: 100,
                  width: 100,
                  image: AssetImage(
                    'images/logo.png',
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Sign In as a Rider',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'Brand-Bold',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailControler,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Email address',
                            labelStyle: TextStyle(
                              fontSize: 14,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            )),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: passwordControler,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: 14,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            )),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      TaxiButton(
                        title: 'LOGIN',
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          var connectivityResult =
                              await Connectivity().checkConnectivity();
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar('No internet connectivity');
                          }

                          if (!emailControler.text.contains('@')) {
                            showSnackBar(
                                'Please provide a valid email address');
                            return;
                          }
                          if (passwordControler.text.length < 8) {
                            showSnackBar('password must be least 8 characters');
                            return;
                          }

                          login();
                        },
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RegisterPage.id,
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Don\'t have an account, sign up here',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
