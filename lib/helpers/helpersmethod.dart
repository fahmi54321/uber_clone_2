import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_2/datamodels/address.dart';
import 'package:uber_clone_2/datamodels/directiondetails.dart';
import 'package:uber_clone_2/datamodels/user.dart';
import 'package:uber_clone_2/dataprovider/appdata.dart';
import 'package:uber_clone_2/globalvariable.dart';
import 'package:uber_clone_2/helpers/requesthelpers.dart';
import 'package:provider/provider.dart';

class HelperMethods{
  static Future<dynamic> findCoordinateAddress(Position position,context) async{
    String placeAddress = '';

    var connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
      return placeAddress;
    }

    String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    if(response != 'failed'){
      placeAddress = response['results'][0]['formatted_address'];

      Address pickupAddress = Address();
      pickupAddress.latitude = position.latitude;
      pickupAddress.longitude = position.longitude;
      pickupAddress.placeName = placeAddress;


      Provider.of<AppData>(context,listen: false).updatePickupAddress(pickupAddress);

    }

    return placeAddress;

  }

  static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition) async{
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';


    var response = await RequestHelper.getRequest(url);

    if(response == 'failed'){
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.durationText = response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue = response['routes'][0]['legs'][0]['duration']['value'];
    directionDetails.distanceText = response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue = response['routes'][0]['legs'][0]['distance']['value'];
    directionDetails.encodePoints = response['routes'][0]['overview_polyline']['points'];

    return directionDetails;

  }

  static int estimateFares(DirectionDetails details){
    // per km = $0.3
    // per minute = $0.2
    // base fare = $3

    double baseFare = 3;
    double distanceFare = (details.distanceValue/1000) * 0.3;
    double timeFare = (details.durationValue/60) * 0.2;

    double totalFare = baseFare + distanceFare + timeFare;

    return totalFare.truncate();

  }

  static void getCurrentUserInfo() async{
    currentFirebaseUser = await FirebaseAuth.instance.currentUser();
    String userId = currentFirebaseUser.uid;

    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users/$userId');
    userRef.once().then((DataSnapshot snapshot) {
      if(snapshot.value != null){
        currentUserInfo = User.fromSnaphsot(snapshot);

      }
    });
  }

  static double generateRandomNumber(int max){
    var randomGenerator = Random();
    int randInt = randomGenerator.nextInt(max);

    return randInt.toDouble();
  }

}

/**

    {
    "plus_code" : {
    "compound_code" : "P27Q+MCM New York, NY, USA",
    "global_code" : "87G8P27Q+MCM"
    },
    "results" : [
    {
    "address_components" : [
    {
    "long_name" : "277",
    "short_name" : "277",
    "types" : [ "street_number" ]
    },
    {
    "long_name" : "Bedford Avenue",
    "short_name" : "Bedford Ave",
    "types" : [ "route" ]
    },
    {
    "long_name" : "Williamsburg",
    "short_name" : "Williamsburg",
    "types" : [ "neighborhood", "political" ]
    },
    {
    "long_name" : "Brooklyn",
    "short_name" : "Brooklyn",
    "types" : [ "political", "sublocality", "sublocality_level_1" ]
    },
    {
    "long_name" : "Kings County",
    "short_name" : "Kings County",
    "types" : [ "administrative_area_level_2", "political" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "NY",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    },
    {
    "long_name" : "11211",
    "short_name" : "11211",
    "types" : [ "postal_code" ]
    }
    ],
    "formatted_address" : "277 Bedford Ave, Brooklyn, NY 11211, USA",
    "geometry" : {
    "location" : {
    "lat" : 40.7142205,
    "lng" : -73.9612903
    },
    "location_type" : "ROOFTOP",
    "viewport" : {
    "northeast" : {
    "lat" : 40.71556948029149,
    "lng" : -73.95994131970849
    },
    "southwest" : {
    "lat" : 40.7128715197085,
    "lng" : -73.9626392802915
    }
    }
    },
    "place_id" : "ChIJd8BlQ2BZwokRAFUEcm_qrcA",
    "plus_code" : {
    "compound_code" : "P27Q+MF Brooklyn, NY, USA",
    "global_code" : "87G8P27Q+MF"
    },
    "types" : [ "street_address" ]
    },
    {
    "address_components" : [
    {
    "long_name" : "279",
    "short_name" : "279",
    "types" : [ "street_number" ]
    },
    {
    "long_name" : "Bedford Avenue",
    "short_name" : "Bedford Ave",
    "types" : [ "route" ]
    },
    {
    "long_name" : "Williamsburg",
    "short_name" : "Williamsburg",
    "types" : [ "neighborhood", "political" ]
    },
    {
    "long_name" : "Brooklyn",
    "short_name" : "Brooklyn",
    "types" : [ "political", "sublocality", "sublocality_level_1" ]
    },
    {
    "long_name" : "Kings County",
    "short_name" : "Kings County",
    "types" : [ "administrative_area_level_2", "political" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "NY",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    },
    {
    "long_name" : "11211",
    "short_name" : "11211",
    "types" : [ "postal_code" ]
    },
    {
    "long_name" : "4203",
    "short_name" : "4203",
    "types" : [ "postal_code_suffix" ]
    }
    ],
    "formatted_address" : "279 Bedford Ave, Brooklyn, NY 11211, USA",
    "geometry" : {
    "bounds" : {
    "northeast" : {
    "lat" : 40.7142628,
    "lng" : -73.96121309999999
    },
    "southwest" : {
    "lat" : 40.7141534,
    "lng" : -73.9613792
    }
    },
    "location" : {
    "lat" : 40.7142015,
    "lng" : -73.96130769999999
    },
    "location_type" : "ROOFTOP",
    "viewport" : {
    "northeast" : {
    "lat" : 40.7155570802915,
    "lng" : -73.95994716970849
    },
    "southwest" : {
    "lat" : 40.7128591197085,
    "lng" : -73.96264513029149
    }
    }
    },
    "place_id" : "ChIJRYYERGBZwokRAM4n1GlcYX4",
    "types" : [ "premise" ]
    },
    {
    "address_components" : [
    {
    "long_name" : "277",
    "short_name" : "277",
    "types" : [ "street_number" ]
    },
    {
    "long_name" : "Bedford Avenue",
    "short_name" : "Bedford Ave",
    "types" : [ "route" ]
    },
    {
    "long_name" : "Williamsburg",
    "short_name" : "Williamsburg",
    "types" : [ "neighborhood", "political" ]
    },
    {
    "long_name" : "Brooklyn",
    "short_name" : "Brooklyn",
    "types" : [ "political", "sublocality", "sublocality_level_1" ]
    },
    {
    "long_name" : "Kings County",
    "short_name" : "Kings County",
    "types" : [ "administrative_area_level_2", "political" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "NY",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    },
    {
    "long_name" : "11211",
    "short_name" : "11211",
    "types" : [ "postal_code" ]
    }
    ],
    "formatted_address" : "277 Bedford Ave, Brooklyn, NY 11211, USA",
    "geometry" : {
    "location" : {
    "lat" : 40.7142205,
    "lng" : -73.9612903
    },
    "location_type" : "ROOFTOP",
    "viewport" : {
    "northeast" : {
    "lat" : 40.71556948029149,
    "lng" : -73.95994131970849
    },
    "southwest" : {
    "lat" : 40.7128715197085,
    "lng" : -73.9626392802915
    }
    }
    },
    "place_id" : "ChIJF0hlQ2BZwokRsrY2RAlFbAE",
    "plus_code" : {
    "compound_code" : "P27Q+MF Brooklyn, NY, USA",
    "global_code" : "87G8P27Q+MF"
    },
    "types" : [ "establishment", "point_of_interest" ]
    },
    {
    "address_components" : [
    {
    "long_name" : "291-275",
    "short_name" : "291-275",
    "types" : [ "street_number" ]
    },
    {
    "long_name" : "Bedford Avenue",
    "short_name" : "Bedford Ave",
    "types" : [ "route" ]
    },
    {
    "long_name" : "Williamsburg",
    "short_name" : "Williamsburg",
    "types" : [ "neighborhood", "political" ]
    },
    {
    "long_name" : "Brooklyn",
    "short_name" : "Brooklyn",
    "types" : [ "political", "sublocality", "sublocality_level_1" ]
    },
    {
    "long_name" : "Kings County",
    "short_name" : "Kings County",
    "types" : [ "administrative_area_level_2", "political" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "NY",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    },
    {
    "long_name" : "11211",
    "short_name" : "11211",
    "types" : [ "postal_code" ]
    }
    ],
    "formatted_address" : "291-275 Bedford Ave, Brooklyn, NY 11211, USA",
    "geometry" : {
    "bounds" : {
    "northeast" : {
    "lat" : 40.7145065,
    "lng" : -73.9612923
    },
    "southwest" : {
    "lat" : 40.7139055,
    "lng" : -73.96168349999999
    }
    },
    "location" : {
    "lat" : 40.7142045,
    "lng" : -73.9614845
    },
    "location_type" : "GEOMETRIC_CENTER",
    "viewport" : {
    "northeast" : {
    "lat" : 40.7155549802915,
    "lng" : -73.96013891970848
    },
    "southwest" : {
    "lat" : 40.7128570197085,
    "lng" : -73.96283688029149
    }
    }
    },
    "place_id" : "ChIJ8ThWRGBZwokR3E1zUisk3LU",
    "types" : [ "route" ]
    },
    {
    "address_components" : [
    {
    "long_name" : "P27Q+MC",
    "short_name" : "P27Q+MC",
    "types" : [ "plus_code" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "New York",
    "types" : [ "locality", "political" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "NY",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    }
    ],
    "formatted_address" : "P27Q+MC New York, NY, USA",
    "geometry" : {
    "bounds" : {
    "northeast" : {
    "lat" : 40.71425,
    "lng" : -73.96137499999999
    },
    "southwest" : {
    "lat" : 40.714125,
    "lng" : -73.9615
    }
    },
    "location" : {
    "lat" : 40.714224,
    "lng" : -73.96145199999999
    },
    "location_type" : "GEOMETRIC_CENTER",
    "viewport" : {
    "northeast" : {
    "lat" : 40.71553648029149,
    "lng" : -73.96008851970849
    },
    "southwest" : {
    "lat" : 40.71283851970849,
    "lng" : -73.96278648029151
    }
    }
    },
    "place_id" : "GhIJWAIpsWtbREARHyv4bYh9UsA",
    "plus_code" : {
    "compound_code" : "P27Q+MC New York, NY, USA",
    "global_code" : "87G8P27Q+MC"
    },
    "types" : [ "plus_code" ]
    },
    {
    "address_components" : [
    {
    "long_name" : "South Williamsburg",
    "short_name" : "South Williamsburg",
    "types" : [ "neighborhood", "political" ]
    },
    {
    "long_name" : "Brooklyn",
    "short_name" : "Brooklyn",
    "types" : [ "political", "sublocality", "sublocality_level_1" ]
    },
    {
    "long_name" : "Kings County",
    "short_name" : "Kings County",
    "types" : [ "administrative_area_level_2", "political" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "NY",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    }
    ],
    "formatted_address" : "South Williamsburg, Brooklyn, NY, USA",
    "geometry" : {
    "bounds" : {
    "northeast" : {
    "lat" : 40.7167119,
    "lng" : -73.9420904
    },
    "southwest" : {
    "lat" : 40.6984866,
    "lng" : -73.9699432
    }
    },
    "location" : {
    "lat" : 40.7043921,
    "lng" : -73.9565551
    },
    "location_type" : "APPROXIMATE",
    "viewport" : {
    "northeast" : {
    "lat" : 40.7167119,
    "lng" : -73.9420904
    },
    "southwest" : {
    "lat" : 40.6984866,
    "lng" : -73.9699432
    }
    }
    },
    "place_id" : "ChIJR3_ODdlbwokRYtN19kNtcuk",
    "types" : [ "neighborhood", "political" ]
    },
    {
    "address_components" : [
    {
    "long_name" : "11211",
    "short_name" : "11211",
    "types" : [ "postal_code" ]
    },
    {
    "long_name" : "Brooklyn",
    "short_name" : "Brooklyn",
    "types" : [ "political", "sublocality", "sublocality_level_1" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "New York",
    "types" : [ "locality", "political" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "NY",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    }
    ],
    "formatted_address" : "Brooklyn, NY 11211, USA",
    "geometry" : {
    "bounds" : {
    "northeast" : {
    "lat" : 40.7280089,
    "lng" : -73.9207299
    },
    "southwest" : {
    "lat" : 40.7008331,
    "lng" : -73.9644697
    }
    },
    "location" : {
    "lat" : 40.7093358,
    "lng" : -73.9565551
    },
    "location_type" : "APPROXIMATE",
    "viewport" : {
    "northeast" : {
    "lat" : 40.7280089,
    "lng" : -73.9207299
    },
    "southwest" : {
    "lat" : 40.7008331,
    "lng" : -73.9644697
    }
    }
    },
    "place_id" : "ChIJvbEjlVdZwokR4KapM3WCFRw",
    "types" : [ "postal_code" ]
    },
    {
    "address_components" : [
    {
    "long_name" : "Williamsburg",
    "short_name" : "Williamsburg",
    "types" : [ "neighborhood", "political" ]
    },
    {
    "long_name" : "Brooklyn",
    "short_name" : "Brooklyn",
    "types" : [ "political", "sublocality", "sublocality_level_1" ]
    },
    {
    "long_name" : "Kings County",
    "short_name" : "Kings County",
    "types" : [ "administrative_area_level_2", "political" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "NY",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    }
    ],
    "formatted_address" : "Williamsburg, Brooklyn, NY, USA",
    "geometry" : {
    "bounds" : {
    "northeast" : {
    "lat" : 40.7251773,
    "lng" : -73.936498
    },
    "southwest" : {
    "lat" : 40.6979329,
    "lng" : -73.96984499999999
    }
    },
    "location" : {
    "lat" : 40.7081156,
    "lng" : -73.9570696
    },
    "location_type" : "APPROXIMATE",
    "viewport" : {
    "northeast" : {
    "lat" : 40.7251773,
    "lng" : -73.936498
    },
    "southwest" : {
    "lat" : 40.6979329,
    "lng" : -73.96984499999999
    }
    }
    },
    "place_id" : "ChIJQSrBBv1bwokRbNfFHCnyeYI",
    "types" : [ "neighborhood", "political" ]
    },
    {
    "address_components" : [
    {
    "long_name" : "Brooklyn",
    "short_name" : "Brooklyn",
    "types" : [ "political", "sublocality", "sublocality_level_1" ]
    },
    {
    "long_name" : "Kings County",
    "short_name" : "Kings County",
    "types" : [ "administrative_area_level_2", "political" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "NY",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    }
    ],
    "formatted_address" : "Brooklyn, NY, USA",
    "geometry" : {
    "bounds" : {
    "northeast" : {
    "lat" : 40.739446,
    "lng" : -73.83336509999999
    },
    "southwest" : {
    "lat" : 40.551042,
    "lng" : -74.05663
    }
    },
    "location" : {
    "lat" : 40.6781784,
    "lng" : -73.94415789999999
    },
    "location_type" : "APPROXIMATE",
    "viewport" : {
    "northeast" : {
    "lat" : 40.739446,
    "lng" : -73.83336509999999
    },
    "southwest" : {
    "lat" : 40.551042,
    "lng" : -74.05663
    }
    }
    },
    "place_id" : "ChIJCSF8lBZEwokRhngABHRcdoI",
    "types" : [ "political", "sublocality", "sublocality_level_1" ]
    },
    {
    "address_components" : [
    {
    "long_name" : "Kings County",
    "short_name" : "Kings County",
    "types" : [ "administrative_area_level_2", "political" ]
    },
    {
    "long_name" : "Brooklyn",
    "short_name" : "Brooklyn",
    "types" : [ "political", "sublocality", "sublocality_level_1" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "NY",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    }
    ],
    "formatted_address" : "Kings County, Brooklyn, NY, USA",
    "geometry" : {
    "bounds" : {
    "northeast" : {
    "lat" : 40.739446,
    "lng" : -73.83336509999999
    },
    "southwest" : {
    "lat" : 40.551042,
    "lng" : -74.05663
    }
    },
    "location" : {
    "lat" : 40.6528762,
    "lng" : -73.95949399999999
    },
    "location_type" : "APPROXIMATE",
    "viewport" : {
    "northeast" : {
    "lat" : 40.739446,
    "lng" : -73.83336509999999
    },
    "southwest" : {
    "lat" : 40.551042,
    "lng" : -74.05663
    }
    }
    },
    "place_id" : "ChIJOwE7_GTtwokRs75rhW4_I6M",
    "types" : [ "administrative_area_level_2", "political" ]
    },
    {
    "address_components" : [
    {
    "long_name" : "New York",
    "short_name" : "New York",
    "types" : [ "locality", "political" ]
    },
    {
    "long_name" : "New York",
    "short_name" : "NY",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    }
    ],
    "formatted_address" : "New York, NY, USA",
    "geometry" : {
    "bounds" : {
    "northeast" : {
    "lat" : 40.9175771,
    "lng" : -73.70027209999999
    },
    "southwest" : {
    "lat" : 40.4773991,
    "lng" : -74.25908989999999
    }
    },
    "location" : {
    "lat" : 40.7127753,
    "lng" : -74.0059728
    },
    "location_type" : "APPROXIMATE",
    "viewport" : {
    "northeast" : {
    "lat" : 40.9175771,
    "lng" : -73.70027209999999
    },
    "southwest" : {
    "lat" : 40.4773991,
    "lng" : -74.25908989999999
    }
    }
    },
    "place_id" : "ChIJOwg_06VPwokRYv534QaPC8g",
    "types" : [ "locality", "political" ]
    },
    {
    "address_components" : [
    {
    "long_name" : "New York",
    "short_name" : "NY",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    }
    ],
    "formatted_address" : "New York, USA",
    "geometry" : {
    "bounds" : {
    "northeast" : {
    "lat" : 45.015861,
    "lng" : -71.777491
    },
    "southwest" : {
    "lat" : 40.4773991,
    "lng" : -79.7625901
    }
    },
    "location" : {
    "lat" : 43.2994285,
    "lng" : -74.21793260000001
    },
    "location_type" : "APPROXIMATE",
    "viewport" : {
    "northeast" : {
    "lat" : 45.015861,
    "lng" : -71.777491
    },
    "southwest" : {
    "lat" : 40.4773991,
    "lng" : -79.7625901
    }
    }
    },
    "place_id" : "ChIJqaUj8fBLzEwRZ5UY3sHGz90",
    "types" : [ "administrative_area_level_1", "political" ]
    },
    {
    "address_components" : [
    {
    "long_name" : "United States",
    "short_name" : "US",
    "types" : [ "country", "political" ]
    }
    ],
    "formatted_address" : "United States",
    "geometry" : {
    "bounds" : {
    "northeast" : {
    "lat" : 71.5388001,
    "lng" : -66.885417
    },
    "southwest" : {
    "lat" : 18.7763,
    "lng" : 170.5957
    }
    },
    "location" : {
    "lat" : 37.09024,
    "lng" : -95.712891
    },
    "location_type" : "APPROXIMATE",
    "viewport" : {
    "northeast" : {
    "lat" : 71.5388001,
    "lng" : -66.885417
    },
    "southwest" : {
    "lat" : 18.7763,
    "lng" : 170.5957
    }
    }
    },
    "place_id" : "ChIJCzYy5IS16lQRQrfeQ5K5Oxw",
    "types" : [ "country", "political" ]
    }
    ],
    "status" : "OK"
    }

**/