// To parse this JSON data, do
//
//     final nearbyBuses = nearbyBusesFromJson(jsonString);

import 'dart:convert';

import 'package:final_map_project/main.dart';
import 'package:final_map_project/models/place_directions.dart';
import 'package:final_map_project/webservices/places_webservices.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

NearbyBuses nearbyBusesFromJson(String str) =>
    NearbyBuses.fromJson(json.decode(str));

class NearbyBuses {
  NearbyBuses({
    required this.htmlAttributions,
    required this.nextPageToken,
    required this.results,
    required this.status,
  });

  List<dynamic> htmlAttributions;
  String nextPageToken;
  List<Result> results;
  String status;

  factory NearbyBuses.fromJson(Map<String, dynamic> json) => NearbyBuses(
        htmlAttributions:
            List<dynamic>.from(json["html_attributions"].map((x) => x)),
        nextPageToken: json["next_page_token"] ?? '',
        results:
            List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
        status: json["status"],
      );
}

class Result {
  Result({
    required this.geometry,
    required this.icon,
    required this.iconMaskBaseUri,
    required this.name,
    required this.placeId,
    required this.rating,
    required this.reference,
    required this.userRatingsTotal,
    required this.vicinity,
    this.priceLevel,
  });

  Geometry geometry;
  String icon;
  String iconMaskBaseUri;
  String name;
  String placeId;
  double rating;
  String reference;
  int userRatingsTotal;
  String vicinity;
  int? priceLevel;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        geometry: Geometry.fromJson(json["geometry"]),
        icon: json["icon"],
        iconMaskBaseUri: json["icon_mask_base_uri"],
        name: json["name"],
        placeId: json["place_id"],
        rating: json["rating"]?.toDouble(),
        reference: json["reference"],
        userRatingsTotal: json["user_ratings_total"],
        vicinity: json["vicinity"],
        priceLevel: json["price_level"],
      );
}

enum BusinessStatus { OPERATIONAL }

class Geometry {
  Geometry({
    required this.location,
  });

  Location location;

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        location: Location.fromJson(json["location"]),
      );

  Map<String, dynamic> toJson() => {
        "location": location.toJson(),
      };
}

class Location {
  Location({
    required this.lat,
    required this.lng,
    required this.timeAndDistance,
  });

  double lat;
  double lng;
  TimeAndDistance timeAndDistance;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
      lat: json["lat"]?.toDouble(),
      lng: json["lng"]?.toDouble(),
      timeAndDistance: TimeAndDistance.getDirections(json["lat"], json["lng"]));

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}

class TimeAndDistance {
  String? distanceText;
  String? durationText;

  TimeAndDistance.getDirections(double lat, double lng) {
    PlacesWebservices()
        .getDirections(
            LatLng(position!.latitude, position!.longitude), LatLng(lat, lng))
        .then((value) async {
      PlaceDirections test = PlaceDirections.fromJson(value);
      distanceText = test.totalDistance;
      durationText = test.totalDuration;
    });
  }
}
