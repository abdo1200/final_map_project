import 'dart:async';

import 'package:final_map_project/constants/my_strings.dart';
import 'package:final_map_project/models/Place_suggestion.dart';
import 'package:final_map_project/models/place.dart';
import 'package:final_map_project/provider/map_provider.dart';
import 'package:final_map_project/screens/widgets/place_item.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

import '../../constants/my_colors.dart';

class FloatingSearch extends StatefulWidget {
  @override
  State<FloatingSearch> createState() => _FloatingSearchState();
}

class _FloatingSearchState extends State<FloatingSearch> {
  final FloatingSearchBarController controller = FloatingSearchBarController();

  late Place selectedPlace;
  bool searchEnabled = false;
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return
        // searchEnabled?
        FloatingSearchBar(
      controller: controller,
      elevation: 6,
      hintStyle: const TextStyle(fontSize: 18, color: Colors.white),
      queryStyle: const TextStyle(fontSize: 18, color: Colors.white),
      borderRadius: BorderRadius.circular(30),
      backgroundColor: MyColors.green,
      hint: searchEnabled ? 'Find a place..' : '',
      border: const BorderSide(style: BorderStyle.none),
      margins: searchEnabled
          ? const EdgeInsets.fromLTRB(20, 70, 20, 0)
          : EdgeInsets.fromLTRB(width(context) * .7, 70, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 45,
      iconColor: Colors.white,
      scrollPadding: const EdgeInsets.only(top: 0, bottom: 10),
      transitionDuration: const Duration(milliseconds: 500),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: searchEnabled ? width(context) * .9 : width(context) * .155,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) async {
        await Provider.of<MapProvider>(context, listen: false)
            .fetchSuggestions(query);
      },
      onFocusChanged: (_) {
        Provider.of<MapProvider>(context, listen: false)
                .isSearchedPlaceMarkerClicked =
            !Provider.of<MapProvider>(context, listen: false)
                .isSearchedPlaceMarkerClicked;
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
              padding: EdgeInsets.only(right: 0),
              icon: Icon(
                Icons.search,
                color: Colors.white,
                size: width(context) * .08,
              ),
              onPressed: () {
                if (!searchEnabled) {
                  setState(() {
                    searchEnabled = true;
                    expanded = true;
                  });
                }
              }),
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildPlacesList(context),
              // buildDiretionsBloc(),
            ],
          ),
        );
      },
    );
  }

  Widget buildPlacesList(context) {
    List<PlaceSuggestion>? places =
        Provider.of<MapProvider>(context, listen: true).places;
    return ListView.builder(
        itemBuilder: (ctx, index) {
          return InkWell(
            onTap: () async {
              Provider.of<MapProvider>(context, listen: false).placeSuggestion =
                  places[index];
              controller.close();
              await Provider.of<MapProvider>(context, listen: false)
                  .getPlaceLocation(places[index].placeId)
                  .then((value) {
                Provider.of<MapProvider>(context, listen: false).place = value;
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
              animatecontroller.animateCamera(CameraUpdate.newCameraPosition(
                  Provider.of<MapProvider>(context, listen: false)
                      .goToSearchedForPlace!));
              Provider.of<MapProvider>(context, listen: false)
                  .buildSearchedPlaceMarker();

              Timer.periodic(Duration(milliseconds: 500), ((timer) {
                setState(() {
                  searchEnabled = false;
                  expanded = false;
                });
                timer.cancel();
              }));
            },
            child: PlaceItem(
              suggestion: places[index],
            ),
          );
        },
        itemCount: places.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics());
  }
}
