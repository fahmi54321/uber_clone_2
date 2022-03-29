import 'package:firebase_database/firebase_database.dart';

class User{
  String fullName;
  String email;
  String phone;
  String id;

  User({this.fullName,this.email,this.phone,this.id,});

  User.fromSnaphsot(DataSnapshot dataSnapshot){
    id = dataSnapshot.key;
    phone = dataSnapshot.value['phone'];
    email = dataSnapshot.value['email'];
    fullName = dataSnapshot.value['fullname'];
  }
}