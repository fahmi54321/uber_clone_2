import 'package:flutter/material.dart';
import 'package:uber_clone_2/datamodels/address.dart';

class AppData extends ChangeNotifier{

  Address pickupAddress;
  Address destinationAddress;

  void updatePickupAddress(Address pickup){
    pickupAddress = pickup;
    notifyListeners();
  }

  void updateDestinationAddress(Address destination){
    destinationAddress = destination;
    notifyListeners();
  }

}