import 'package:final_map_project/constants/my_colors.dart';
import 'package:final_map_project/models/Place_suggestion.dart';
import 'package:final_map_project/provider/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class FavouritsWidget extends StatelessWidget {
  final List<PlaceSuggestion> favouritePlaces;
  const FavouritsWidget({super.key, required this.favouritePlaces});

  @override
  Widget build(BuildContext context) {
    return favouritePlaces.isNotEmpty
        ? Container(
            height: 30,
            margin: EdgeInsets.only(top: 10),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: favouritePlaces.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () async {
                    Provider.of<MapProvider>(context, listen: false)
                        .placeSuggestion = favouritePlaces[index];

                    await Provider.of<MapProvider>(context, listen: false)
                        .getPlaceLocation(favouritePlaces[index].placeId)
                        .then((value) {
                      Provider.of<MapProvider>(context, listen: false).place =
                          value;
                      Provider.of<MapProvider>(context, listen: false)
                          .goToSearchedForPlace = CameraPosition(
                        bearing: 0.0,
                        tilt: 0.0,
                        target: LatLng(
                          value.result.geometry.location.lat,
                          value.result.geometry.location.lng,
                        ),
                        zoom: 13,
                      );
                    });
                    final GoogleMapController animatecontroller =
                        await Provider.of<MapProvider>(context, listen: false)
                            .mapController
                            .future;
                    animatecontroller.animateCamera(
                        CameraUpdate.newCameraPosition(
                            Provider.of<MapProvider>(context, listen: false)
                                .goToSearchedForPlace!));
                    Provider.of<MapProvider>(context, listen: false)
                        .buildSearchedPlaceMarker();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: MyColors.navy,
                        borderRadius: BorderRadius.circular(50)),
                    child: Text(
                        favouritePlaces[index].description.split(',')[0],
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                );
              },
            ),
          )
        : Container();
  }
}
