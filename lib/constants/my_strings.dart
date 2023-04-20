import 'package:flutter/material.dart';

const loginScreen = '/';
const otpScreen = '/otp-screen';
const mapScreen = '/map-screen';
const googleAPIKey = 'AIzaSyBCjxNhoGVDe6YpbS_SoU-mtzXbQgvKxUA';
const suggestionsBaseUrl =
    'https://maps.googleapis.com/maps/api/place/autocomplete/json';
const placeLocationBaseUrl =
    'https://maps.googleapis.com/maps/api/place/details/json';
const directionsBaseUrl =
    'https://maps.googleapis.com/maps/api/directions/json';
const nearBaseUrl =
    'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

double height(context) => MediaQuery.of(context).size.height;
double width(context) => MediaQuery.of(context).size.width;
