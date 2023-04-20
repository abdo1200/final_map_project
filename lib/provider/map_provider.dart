import 'dart:async';

import 'dart:ui';

import 'package:final_map_project/models/Place_suggestion.dart';
import 'package:final_map_project/models/nearby_search.dart' as nearbyPackage;
import 'package:final_map_project/models/place_directions.dart';
import 'package:final_map_project/webservices/places_webservices.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../models/place.dart';

class MapProvider extends ChangeNotifier {
  Completer<GoogleMapController> mapController = Completer();
  CameraPosition myCurrentLocationCameraPosition = CameraPosition(
    bearing: 0.0,
    target: LatLng(position!.latitude, position!.longitude),
    tilt: 0.0,
    zoom: 17,
  );
  List<PlaceSuggestion> places = [];
  Place? place;
  final sessionToken = const Uuid().v4();
  bool isTimeAndDistanceVisible = false;
  PlaceSuggestion? placeSuggestion;
  nearbyPackage.NearbyBuses? nearby;
  CameraPosition? goToSearchedForPlace;
  Set<Marker> markers = {};
  late Marker searchedPlaceMarker;
  late Marker currentLocationMarker;
  bool isSearchedPlaceMarkerClicked = false;
  bool isFavourite = false;

  Future<void> fetchSuggestions(String place) async {
    final suggestions =
        await PlacesWebservices().fetchSuggestions(place, sessionToken);

    places = suggestions
        .map((suggestion) => PlaceSuggestion.fromJson(suggestion))
        .toList();
    notifyListeners();
  }

  Future<Place> getPlaceLocation(String placeId) async {
    final result =
        await PlacesWebservices().getPlaceLocation(placeId, sessionToken);
    // var readyPlace = Place.fromJson(place);
    return Place.fromJson(result);
  }

  Future<PlaceDirections> getDirections(
      LatLng origin, LatLng destination) async {
    final directions =
        await PlacesWebservices().getDirections(origin, destination);
    await goToMyCurrentLocation();
    return PlaceDirections.fromJson(directions);
  }

  void buildSearchedPlaceMarker() {
    searchedPlaceMarker = Marker(
      position: goToSearchedForPlace!.target,
      markerId: const MarkerId('1'),
      onTap: () {
        // show time and distance

        isSearchedPlaceMarkerClicked = true;
        notifyListeners();
        isTimeAndDistanceVisible = true;
        notifyListeners();
      },
      infoWindow: InfoWindow(title: placeSuggestion!.description),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    // buildCurrentLocationMarker();
    addMarkerToMarkersAndUpdateUI(searchedPlaceMarker);
  }

  // void buildCurrentLocationMarker() async{
  //   currentLocationMarker = Marker(
  //     position: LatLng(position!.latitude, position!.longitude),
  //     markerId: const MarkerId('2'),
  //     onTap: () {},
  //     infoWindow: const InfoWindow(title: "Your current Location"),
  //     icon: await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(size: Size(48, 48)), 'assets/my_icon.png'),
  //   );
  //   addMarkerToMarkersAndUpdateUI(currentLocationMarker);
  // }

  void addMarkerToMarkersAndUpdateUI(Marker marker) {
    markers.add(marker);
    notifyListeners();
  }

  Future<void> goToMyCurrentLocation() async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(myCurrentLocationCameraPosition));
  }

  Future<nearbyPackage.NearbyBuses> getNearPlaces(
      double lat, double long) async {
    final busStation =
        await PlacesWebservices().getNearPlaces(LatLng(lat, long));
    nearby = nearbyPackage.NearbyBuses.fromJson(busStation);
    await nearBusStation(nearby);
    return nearbyPackage.NearbyBuses.fromJson(busStation);
  }

  Future<BitmapDescriptor> _createMarkerImageFromBytes(
      Uint8List imageData, int size) async {
    Codec codec = await instantiateImageCodec(imageData);
    late Uint8List bytes;
    FrameInfo fi = await codec.getNextFrame();
    await fi.image.toByteData(format: ImageByteFormat.png).then((value) {
      bytes = value!.buffer.asUint8List();
    });
    return BitmapDescriptor.fromBytes(
      bytes,
      size: Size(size.toDouble(), size.toDouble()),
    );
  }

  Future<void> nearBusStation(nearbyPackage.NearbyBuses? nearby) async {
    for (var result in nearby!.results) {
      markers.add(
        Marker(
          markerId: MarkerId(result.placeId),
          icon: await _createMarkerImageFromBytes(
              await rootBundle
                  .load('assets/bus-station.png')
                  .then((data) => data.buffer.asUint8List()),
              50),
          position: LatLng(
              result.geometry.location.lat, result.geometry.location.lng),
          infoWindow: InfoWindow(
            title: result.name,
            snippet: result.vicinity,
          ),
        ),
      );
    }
    notifyListeners();
  }

  Future<void> clearNearBusStation({Result? result}) async {
    markers = {};
    if (result != null) {
      searchedPlaceMarker = Marker(
        position:
            LatLng(result.geometry.location.lat, result.geometry.location.lng),
        markerId: const MarkerId('1'),
        onTap: () {
          // show time and distance

          isSearchedPlaceMarkerClicked = true;
          notifyListeners();
          isTimeAndDistanceVisible = true;

          notifyListeners();
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
      addMarkerToMarkersAndUpdateUI(searchedPlaceMarker);
    }
    // buildCurrentLocationMarker();
    notifyListeners();
  }
}
