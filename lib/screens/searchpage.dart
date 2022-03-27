import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone_2/brand_colors.dart';
import 'package:uber_clone_2/datamodels/prediction.dart';
import 'package:uber_clone_2/dataprovider/appdata.dart';
import 'package:uber_clone_2/globalvariable.dart';
import 'package:uber_clone_2/helpers/requesthelpers.dart';

class SearchPage extends StatefulWidget {

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  var pickupController = TextEditingController();
  var destinationController = TextEditingController();

  var focusDestination = FocusNode();

  bool focused = false;
  void setFocus(){
    if(!focused){
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  void searchPlace(String placeName) async{

    if(placeName.length > 1){
      String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=123254251&components=country:id';
      var response = await RequestHelper.getRequest(url);

      if(response == 'failed'){
        return;
      }

      //todo 2 (finish)
      if(response['status'] == 'OK'){
        var predictionJson = response['predictions'];
        var thisList = (predictionJson as List).map((e) => Prediction.fromJson(e)).toList();
      }
    }

  }

  @override
  Widget build(BuildContext context) {

    setFocus();

    String address = Provider.of<AppData>(context).pickupAddress.placeName ?? '';
    pickupController.text = address;

    return Scaffold(
      body: Column(children: [
        Container(
          height: 210,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                spreadRadius: 0.5,
                offset: Offset(0.7,0.7),
              )
            ]
          ),
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, top: 48, right: 24, bottom: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                        ),
                      ),
                      Center(
                        child: Text(
                          'Set Destination',
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Brand-Bold'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Row(
                    children: [
                      Image.asset('images/pickicon.png', width: 16, height: 16),
                      SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorLightGrayFair,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextField(
                              controller: pickupController,
                              decoration: InputDecoration(
                                  hintText: 'Pickup location',
                                  fillColor: BrandColors.colorLightGrayFair,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 10, top: 8, bottom: 8)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Image.asset('images/desticon.png', width: 16, height: 16),
                      SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorLightGrayFair,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextField(
                              onChanged: (value){
                                searchPlace(value);
                              },
                              focusNode: focusDestination,
                              controller: destinationController,
                              decoration: InputDecoration(
                                  hintText: 'Where to?',
                                  fillColor: BrandColors.colorLightGrayFair,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 10, top: 8, bottom: 8)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
      ],),
    );
  }
}
