import 'package:uber_clone_2/datamodels/nearbydriver.dart';

class FireHelper{
  static List<NearbyDriver> nearbyDriver = [];

  static void removeFromList(String key){
    int index = nearbyDriver.indexWhere((element) => element.key == key);
    nearbyDriver.removeAt(index);
  }

  static void updateNearbyLocation(NearbyDriver driver){
    int index = nearbyDriver.indexWhere((element) => element.key == driver.key);

    nearbyDriver[index].latitude = driver.latitude;
    nearbyDriver[index].longitude = driver.longitude;
  }
}