import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone_2/brand_colors.dart';
import 'package:uber_clone_2/datamodels/address.dart';
import 'package:uber_clone_2/datamodels/prediction.dart';
import 'package:uber_clone_2/dataprovider/appdata.dart';
import 'package:uber_clone_2/globalvariable.dart';
import 'package:uber_clone_2/helpers/requesthelpers.dart';
import 'package:uber_clone_2/widgets/progress_dialog.dart';

class PredictionTile extends StatelessWidget {

  final Prediction prediction;
  PredictionTile({this.prediction});

  void getPlaceDetails(String placeId,context) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => ProgressDialog(status: 'Please wait...'),
    );

    String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context); // close dialog

    if(response['status'] == 'OK'){
      Address thisPlace = Address();
      thisPlace.placeName = response['result']['name'];
      thisPlace.placeId = placeId;
      thisPlace.latitude = response['result']['geometry']['location']['lat'];
      thisPlace.longitude = response['result']['geometry']['location']['lng'];
      
      Provider.of<AppData>(context,listen: false).updateDestinationAddress(thisPlace);
      print(thisPlace.placeName);

      Navigator.pop(context,'getDirection');
      
    }

  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        getPlaceDetails(prediction.placeId,context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 8,),
            Row(
              children: [
                Icon(OMIcons.locationOn, color: BrandColors.colorDimText),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prediction.mainText,overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 2),
                      Text(
                        prediction.secondaryText,
                        overflow: TextOverflow.ellipsis, maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          color: BrandColors.colorDimText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}