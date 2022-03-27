import 'package:flutter/material.dart';
import 'package:uber_clone_2/datamodels/address.dart';

class AppData extends ChangeNotifier{

  Address pickupAddress;

  //todo 2 (next helpersmethod)
  void updatePickupAddress(Address pickup){
    pickupAddress = pickup;
    notifyListeners();
  }

}