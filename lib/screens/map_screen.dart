import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:final_map_project/constants/my_colors.dart';
import 'package:final_map_project/constants/my_strings.dart';
import 'package:final_map_project/main.dart';
import 'package:final_map_project/models/Place_suggestion.dart';
import 'package:final_map_project/models/place.dart';
import 'package:final_map_project/models/nearby_search.dart' as nearby;
import 'package:final_map_project/models/place_directions.dart';
import 'package:final_map_project/provider/map_provider.dart';
import 'package:final_map_project/screens/widgets/favourits_widget.dart';
import 'package:final_map_project/screens/widgets/floating_search.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  FloatingSearchBarController controller = FloatingSearchBarController();
  late String mapStyle;
  PlaceDirections? placeDirections;
  var progressIndicator = false;
  late List<LatLng> polylinePoints;
  late String time;
  late String distance;
  List<PlaceSuggestion> favouritePlaces = [];
  List<String> favouritePlacesKeys = [];
  GoogleMapController? mapController;
  bool stationsEnabled = false;

  @override
  void initState() {
    super.initState();
    // rootBundle.loadString('assets/map_style.json').then((string) {
    //   mapStyle = string;
    // });
    getFavouritPlaces();
  }

  Widget buildMap() {
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      markers: Provider.of<MapProvider>(context, listen: true).markers,
      initialCameraPosition: Provider.of<MapProvider>(context, listen: false)
          .myCurrentLocationCameraPosition,
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        Provider.of<MapProvider>(context, listen: false)
            .mapController
            .complete(controller);
        //mapController!.setMapStyle(mapStyle);
      },
      polylines: placeDirections != null
          ? {
              Polyline(
                polylineId: const PolylineId('my_polyline'),
                color: Colors.black,
                width: 2,
                points: polylinePoints,
              ),
            }
          : {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(
            children: [
              buildMap(),
              FloatingSearch(),
              FavouritsWidget(favouritePlaces: favouritePlaces),
              stationsEnabled
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              Provider.of<MapProvider>(context, listen: false)
                                  .nearby!
                                  .results
                                  .length,
                          itemBuilder: (context, index) {
                            nearby.Result result =
                                Provider.of<MapProvider>(context, listen: false)
                                    .nearby!
                                    .results[index];

                            return GestureDetector(
                              onTap: () async {
                                Provider.of<MapProvider>(context, listen: false)
                                        .placeSuggestion =
                                    PlaceSuggestion(
                                        description: result.name,
                                        placeId: result.placeId);
                                await Provider.of<MapProvider>(context,
                                        listen: false)
                                    .getPlaceLocation(result.placeId)
                                    .then((value) {
                                  Provider.of<MapProvider>(context,
                                          listen: false)
                                      .place = value;
                                  Provider.of<MapProvider>(context,
                                          listen: false)
                                      .goToSearchedForPlace = CameraPosition(
                                    bearing: 0.0,
                                    tilt: 0.0,
                                    target: LatLng(
                                      value.result.geometry.location.lat,
                                      value.result.geometry.location.lng,
                                    ),
                                    zoom: 35,
                                  );
                                });
                                final GoogleMapController animatecontroller =
                                    await Provider.of<MapProvider>(context,
                                            listen: false)
                                        .mapController
                                        .future;
                                animatecontroller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        Provider.of<MapProvider>(context,
                                                listen: false)
                                            .goToSearchedForPlace!));
                                // Provider.of<MapProvider>(context, listen: false)
                                //     .buildSearchedPlaceMarker();
                              },
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(
                                      bottom: 32, left: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  width: width(context) * .80,
                                  decoration: BoxDecoration(
                                      color: MyColors.navy,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/bus-station.png',
                                            width: 25,
                                          ),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: Text(
                                              result.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            'Distance: ${result.geometry.location.timeAndDistance.distanceText}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Duration: ${result.geometry.location.timeAndDistance.durationText}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : Provider.of<MapProvider>(context, listen: false)
                          .isSearchedPlaceMarkerClicked
                      ? Container()
                      : Provider.of<MapProvider>(context, listen: true)
                                  .placeSuggestion !=
                              null
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(bottom: 32),
                                height: 65,
                                width: width(context) * .93,
                                decoration: BoxDecoration(
                                    color: MyColors.navy,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 70),
                                  child: Text(
                                    Provider.of<MapProvider>(context,
                                            listen: false)
                                        .placeSuggestion!
                                        .description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container()
            ],
          ),
          floatingActionButton: Provider.of<MapProvider>(context, listen: false)
                  .isSearchedPlaceMarkerClicked
              ? Container()
              : Stack(
                  children: <Widget>[
                    stationsEnabled
                        ? Container()
                        : Provider.of<MapProvider>(context, listen: false)
                                    .place ==
                                null
                            ? Container()
                            : Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(32, 0, 8, 20),
                                  child: FloatingActionButton(
                                    backgroundColor: MyColors.green,
                                    onPressed: () async {
                                      Place selectedPlace =
                                          Provider.of<MapProvider>(context,
                                                  listen: false)
                                              .place!;
                                      placeDirections =
                                          await Provider.of<MapProvider>(
                                                  context,
                                                  listen: false)
                                              .getDirections(
                                                  LatLng(position!.latitude,
                                                      position!.longitude),
                                                  LatLng(
                                                      selectedPlace
                                                          .result
                                                          .geometry
                                                          .location
                                                          .lat,
                                                      selectedPlace
                                                          .result
                                                          .geometry
                                                          .location
                                                          .lng));
                                      setState(() {
                                        polylinePoints = placeDirections!
                                            .polylinePoints
                                            .map((e) =>
                                                LatLng(e.latitude, e.longitude))
                                            .toList();
                                      });
                                    },
                                    child: const Icon(Icons.directions,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                        child: FloatingActionButton(
                          backgroundColor: MyColors.navy,
                          onPressed:
                              Provider.of<MapProvider>(context, listen: true)
                                  .goToMyCurrentLocation,
                          child: const Icon(Icons.share_location_rounded,
                              color: MyColors.green),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(30, 0, 0, 100),
                        child: FloatingActionButton(
                          backgroundColor: MyColors.navy,
                          onPressed: () async {
                            if (stationsEnabled) {
                              if (Provider.of<MapProvider>(context,
                                          listen: false)
                                      .place !=
                                  null) {
                                await Provider.of<MapProvider>(context,
                                        listen: false)
                                    .clearNearBusStation(
                                        result: Provider.of<MapProvider>(
                                                context,
                                                listen: false)
                                            .place!
                                            .result);
                              } else {
                                await Provider.of<MapProvider>(context,
                                        listen: false)
                                    .clearNearBusStation();
                              }

                              setState(() {
                                stationsEnabled = false;
                              });
                            } else {
                              await Provider.of<MapProvider>(context,
                                      listen: false)
                                  .getNearPlaces(
                                      position!.latitude, position!.longitude);
                              setState(() {
                                stationsEnabled = true;
                              });
                            }
                          },
                          child: const Icon(Icons.bus_alert_rounded,
                              color: MyColors.green),
                        ),
                      ),
                    ),
                    stationsEnabled
                        ? Container()
                        : Provider.of<MapProvider>(context, listen: false)
                                    .place ==
                                null
                            ? Container()
                            : Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                  child: FloatingActionButton(
                                    backgroundColor: MyColors.green,
                                    onPressed: () async {
                                      PlaceSuggestion place =
                                          Provider.of<MapProvider>(context,
                                                  listen: false)
                                              .placeSuggestion!;
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      if (favouritePlacesKeys
                                          .contains(place.placeId)) {
                                        prefs.remove(place.placeId);
                                        getFavouritPlaces();

                                        await getFavouritPlaces();
                                        // ignore: use_build_context_synchronously
                                        AnimatedSnackBar.material(
                                          'Place deleted from favourits',
                                          duration: const Duration(seconds: 1),
                                          type: AnimatedSnackBarType.error,
                                        ).show(context);
                                      } else {
                                        prefs.setString(
                                            place.placeId, place.description);
                                        await getFavouritPlaces();

                                        // ignore: use_build_context_synchronously
                                        AnimatedSnackBar.material(
                                          'Place added to favourits successfully',
                                          duration: const Duration(seconds: 1),
                                          type: AnimatedSnackBarType.success,
                                        ).show(context);
                                      }
                                    },
                                    child: Icon(
                                        favouritePlacesKeys.contains(
                                                Provider.of<MapProvider>(
                                                        context,
                                                        listen: false)
                                                    .placeSuggestion!
                                                    .placeId)
                                            ? Icons.bookmark_remove_rounded
                                            : Icons.bookmark_add_outlined,
                                        color: MyColors.navy),
                                  ),
                                ),
                              ),
                  ],
                )),
    );
  }

  getFavouritPlaces() async {
    favouritePlaces = [];
    favouritePlacesKeys = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (!favouritePlacesKeys.contains(key)) {
        favouritePlacesKeys.add(key);
        PlaceSuggestion favPlace =
            PlaceSuggestion(placeId: key, description: prefs.getString(key)!);
        favouritePlaces.add(favPlace);
      }
    }
    setState(() {});
    print(favouritePlacesKeys);
  }
}
