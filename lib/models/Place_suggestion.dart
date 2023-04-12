class PlaceSuggestion {
  late String placeId;
  late String description;

  PlaceSuggestion({required this.description, required this.placeId});

  PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    placeId = json["place_id"];
    description = json["description"];
  }

  Map<String, dynamic> toJson() =>
      {"place_id": placeId, "description": description};
}
