import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone_2/datamodels/directiondetails.dart';
import 'package:uber_clone_2/datamodels/nearbydriver.dart';
import 'package:uber_clone_2/dataprovider/appdata.dart';
import 'package:uber_clone_2/helpers/firehelper.dart';
import 'package:uber_clone_2/helpers/helpersmethod.dart';
import 'package:uber_clone_2/screens/searchpage.dart';
import 'package:uber_clone_2/styles/styles.dart';
import 'package:uber_clone_2/widgets/brand_divider.dart';
import 'package:uber_clone_2/widgets/progress_dialog.dart';
import 'package:uber_clone_2/widgets/taxi_button.dart';

import 'brand_colors.dart';
import 'globalvariable.dart';

class MainPage extends StatefulWidget {
  static const String id = 'main';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;
  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};

  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  double rideDetailsSheetHeight= 0; // (Platform.isAndroid) ? 235 : 260
  double requestingSheetHeight= 0; // (Platform.isAbdroid) ? 195 : 220

  DirectionDetails tripDirectionDetails;


  var geolocator = Geolocator();
  Position currentPosition;

  bool drawerCanOpen = true;

  DatabaseReference rideRef;

  void setupPositionLocator() async{
      Position position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      currentPosition = position;

      LatLng pos = LatLng(position.latitude, position.longitude);
      CameraPosition cp = CameraPosition(target: pos,zoom: 14);
      mapController.animateCamera(CameraUpdate.newCameraPosition(cp));


      // String address = await HelperMethods.findCoordinateAddress(position,context);
      startGeofireListener();

  }

  Future<void> getDirection() async{
    var pickup = Provider.of<AppData>(context,listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context,listen: false).destinationAddress;

    var pickLatlng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatlng = LatLng(destination.latitude, destination.longitude);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => ProgressDialog(status: 'Please wait'),
    );

    var thisDetails = await HelperMethods.getDirectionDetails(pickLatlng, destinationLatlng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    Navigator.pop(context);

    print(thisDetails.encodePoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodePoints);

    polylineCoordinates.clear();

    if(results.isNotEmpty){
      // loop through all PointLatlng points and convert them
      // to a list of LatLng, required by the Polyline
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _polylines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);

    });

    // set bounds, make polyline to fit into the map
    LatLngBounds bounds;

    if(pickLatlng.latitude > destinationLatlng.latitude && pickLatlng.longitude > destinationLatlng.longitude){
      bounds = LatLngBounds(southwest: destinationLatlng, northeast: pickLatlng);
    }else if(pickLatlng.longitude > destinationLatlng.longitude){
      bounds = LatLngBounds(
        southwest: LatLng(pickLatlng.latitude, destinationLatlng.longitude),
        northeast: LatLng(
          destinationLatlng.latitude,
          pickLatlng.longitude,
        ),
      );
    }else if(pickLatlng.latitude > destinationLatlng.latitude){
      bounds = LatLngBounds(
        southwest: LatLng(destinationLatlng.latitude, pickLatlng.longitude),
        northeast: LatLng(
          pickLatlng.latitude,
          destinationLatlng.longitude,
        ),
      );
    }else{
      bounds = LatLngBounds(southwest: pickLatlng, northeast: destinationLatlng);
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    // set marker
    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName,snippet: 'My Location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: destination.placeName,snippet: 'Destination'),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    // set circle
    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatlng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatlng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });

  }

  void showDetailSheet() async{
    await getDirection();

    setState(() {
      searchSheetHeight = 0;
      rideDetailsSheetHeight = (Platform.isAndroid) ? 235 : 260;
      mapBottomPadding = (Platform.isAndroid) ? 240 : 230;
      drawerCanOpen = false;
    });
  }

  resetApp(){

    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _circles.clear();
      _markers.clear();
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = 0;
      searchSheetHeight = (Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
      drawerCanOpen = true;
    });

    setupPositionLocator();
  }

  void showRequestingSheet(){
    setState(() {
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = (Platform.isAndroid) ? 195 : 220;
      mapBottomPadding = (Platform.isAndroid) ? 200 : 190;

      drawerCanOpen = true;
    });

    createRideRequest();
  }

  void createRideRequest(){
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();

    var pickup = Provider.of<AppData>(context,listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context,listen: false).destinationAddress;

    Map pickupMap = {
      'latitude' : pickup.latitude.toString(),
      'longitude' : pickup.longitude.toString(),
    };

    Map destinationMap = {
      'latitude' : destination.latitude.toString(),
      'longitude' : destination.longitude.toString(),
    };

    Map rideMap = {
      'created_at' : DateTime.now().toString(),
      'rider_name' : currentUserInfo.fullName,
      'rider_phone' : currentUserInfo.phone,
      'pickup_address' : pickup.placeName,
      'destination_address' : destination.placeName,
      'location' : pickupMap,
      'destination' : destinationMap,
      'payment_method' : 'card',
      'driver_id' :  'waiting',
    };

    rideRef.set(rideMap);

  }

  void cancelRequest(){
    rideRef.remove();
  }

  void startGeofireListener() {
    Geofire.initialize('driversAvailable');

    Geofire.queryAtLocation(
        currentPosition.latitude, currentPosition.longitude, 20).listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:

            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];

            FireHelper.nearbyDriver.add(nearbyDriver); //todo 1

            break;

          case Geofire.onKeyExited:
            
            FireHelper.removeFromList(map['key']); //todo 2
            
            break;

          case Geofire.onKeyMoved:
          // Update your key's location

            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];

            FireHelper.updateNearbyLocation(nearbyDriver); //todo 3

            break;

          case Geofire.onGeoQueryReady:
          // All Intial Data is loaded
            print('firehelper length : ${FireHelper.nearbyDriver.length}'); //todo 4 (finish)

            break;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    HelperMethods.getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPadding),
            initialCameraPosition: googlePlex,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;

              setState(() {
                mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
              });

              setupPositionLocator();

            },
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            polylines: _polylines,
            markers: _markers,
            circles: _circles,
          ),

          // MenuButton
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: (){
                if(drawerCanOpen){
                  scaffoldKey.currentState.openDrawer();
                }else{
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7,0.7),
                    )
                  ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    (drawerCanOpen) ? Icons.menu : Icons.arrow_back,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          // SearchSheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: searchSheetHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 18,),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Nice to see you',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        'Where are you going',
                        style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async{
                          var response = await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));

                          if(response == 'getDirection'){
                            showDetailSheet();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7),
                                ),
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(12.9),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: 10),
                                Text('Search Destination'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Row(
                        children: [
                          Icon(
                            OMIcons.home,
                            color: BrandColors.colorDimText,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((Provider.of<AppData>(context).pickupAddress !=
                                        null)
                                    ? Provider.of<AppData>(context)
                                        .pickupAddress
                                        .placeName
                                    : 'Add Home',overflow: TextOverflow.ellipsis,maxLines: 1,),
                                SizedBox(height: 3),
                                Text(
                                  'Your residential address',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: BrandColors.colorDimText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      BrandDivider(),

                      SizedBox(height: 16,),

                      Row(
                        children: [
                          Icon(
                            OMIcons.workOutline,
                            color: BrandColors.colorDimText,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Work'),
                              SizedBox(height: 3),
                              Text(
                                'Your office address',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: BrandColors.colorDimText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // RideDetails Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                height: rideDetailsSheetHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: BrandColors.colorAccent1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(children: [
                            Image.asset('images/taxi.png',height: 70,width: 70),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Taxi',style: TextStyle(fontSize: 18,fontFamily: 'Brand-Bold'),),
                                  Text(
                                    (tripDirectionDetails != null)
                                        ? tripDirectionDetails.distanceText
                                        : '',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: BrandColors.colorTextLight),
                                  ),
                                ],
                            ),
                            Expanded(child: Container()),
                              Text(
                                  (tripDirectionDetails != null)
                                      ? '\$${HelperMethods.estimateFares(tripDirectionDetails)}'
                                      : '',
                                  style: TextStyle(
                                      fontSize: 18, fontFamily: 'Brand-Bold')),
                            ],),
                        ),
                      ),
                      SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(children: [
                          Icon(FontAwesomeIcons.moneyBillAlt,size: 18,color: BrandColors.colorTextLight),
                          SizedBox(width: 16),
                          Text('Cash'),
                          SizedBox(width: 5),
                          Icon(Icons.keyboard_arrow_down,color: BrandColors.colorTextLight,size: 16),
                        ],),
                      ),
                      SizedBox(height: 22),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: TaxiButton(
                          title: 'REQUEST CAB',
                          color: BrandColors.colorGreen,
                          onPressed: () {
                            showRequestingSheet();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Requesting sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15),),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      spreadRadius: 0.5,
                      offset: Offset(0.7,0.7),
                    ),
                  ]
                ),
                height: requestingSheetHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextLiquidFill(
                          text: 'Requesting a Ride...',
                          waveColor: BrandColors.colorTextLight,
                          boxBackgroundColor: Colors.white,
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Brand-Bold',
                          ),
                          boxHeight: 40.0,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: (){
                          cancelRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              width: 1,
                              color: BrandColors.colorLightGrayFair,
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 25,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Cancel ride',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Container(color: Colors.white,height: 160,child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(children: [
                  Image.asset('images/user_icon.png',height: 60,width: 60),
                  SizedBox(width: 15,),
                  Column(mainAxisAlignment: MainAxisAlignment.center,children: [
                    Text('Fahmi',style: TextStyle(fontSize: 20,fontFamily: 'Brand-Bold')),
                    SizedBox(height: 5),
                    Text('View Profile'),
                  ],),
                ],),
              ),),
              BrandDivider(),

              SizedBox(height: 10),

              ListTile(
                leading: Icon(OMIcons.cardGiftcard),
                title: Text('Free Rides',style: kDrawerItemStyle,),
              ),

              ListTile(
                leading: Icon(OMIcons.creditCard),
                title: Text('Payments',style: kDrawerItemStyle,),
              ),

              ListTile(
                leading: Icon(OMIcons.history),
                title: Text('Ride History',style: kDrawerItemStyle,),
              ),

              ListTile(
                leading: Icon(OMIcons.contactSupport),
                title: Text('Support',style: kDrawerItemStyle,),
              ),

              ListTile(
                leading: Icon(OMIcons.info),
                title: Text('About',style: kDrawerItemStyle,),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
