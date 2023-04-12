import 'package:final_map_project/constants/my_colors.dart';

import 'package:final_map_project/models/Place_suggestion.dart';
import 'package:flutter/material.dart';

class PlaceItem extends StatelessWidget {
  final PlaceSuggestion suggestion;

  const PlaceItem({Key? key, required this.suggestion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var subTitle = suggestion.description
        .replaceAll(suggestion.description.split(',')[0], '');
    return Container(
      width: double.infinity,
      margin: const EdgeInsetsDirectional.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: MyColors.green, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  minLeadingWidth: 10,
                  leading: Icon(
                    Icons.location_on,
                    color: MyColors.navy,
                  ),
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${suggestion.description.split(',')[0]}\n',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text: subTitle.substring(2),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: MyColors.navy,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
