import 'package:plugme/models/place_prediction.dart';
import 'package:flutter/material.dart';
Widget placePredictionCard({required PlacePrediction placePrediction}) {
  return Container(
    padding: const EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.add_location),
            const SizedBox(
              width: 14.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${placePrediction.structuredFormatting!.mainText}",
                    overflow: TextOverflow.ellipsis,
                    style:
                    const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 3.0,
                  ),
                  Text(
                    "${placePrediction.structuredFormatting!.secondaryText}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                ],
              ),
            )
          ],
        ),
        const Divider()
      ],
    ),
  );
}