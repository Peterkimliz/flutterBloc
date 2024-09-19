import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/location_controller.dart';

class Suggestion {
  final String placeId;
  final String description;
  final String title;

  Suggestion(this.placeId, this.description, this.title);
}

class PlaceDetail {
  String? address;
  double? latitude;
  double? longitude;
  String? name;

  PlaceDetail({
    this.address,
    this.latitude,
    this.longitude,
    this.name,
  });
}

class LocationSearchScreen extends StatelessWidget {
  final String title;
  final String type;

  LocationSearchScreen({Key? key, required this.title, required this.type})
      : super(key: key) {
    locationController.suggestion.clear();
  }

  final _controller = TextEditingController();
  final LocationController locationController = Get.find<LocationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  iconSize: 32,
                  padding: const EdgeInsets.only(left: 16, top: 8),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
                  child: Text(
                    title,
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 18, top: 8, right: 18),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextFormField(
                controller: _controller,
                textAlign: TextAlign.start,
                autocorrect: false,
                onChanged: (value) {
                  if (value.trim().isNotEmpty) {
                    locationController.fetchPlacesByName(value.toLowerCase());
                  }
                },
                autofocus: true,
                decoration: InputDecoration(
                  icon: Container(
                    margin: const EdgeInsets.only(left: 12),
                    width: 32,
                    child: const Icon(
                      Icons.search_rounded,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                  hintText: "Enter location",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                return locationController.loadingLocation.value
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          Suggestion suggestion =
                              locationController.suggestion.elementAt(index);
                          return ListTile(
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 8, bottom: 4),
                                  child: Text(
                                    suggestion.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 4, bottom: 8),
                                  child: Text(
                                    suggestion.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            leading: Container(
                              child: const Icon(
                                Icons.place_rounded,
                                color: Colors.black,
                                size: 32,
                              ),
                            ),
                            onTap: () async {
                              Get.back();
                              locationController.fetchPlaceDetail(
                                  placeId: suggestion.placeId, type: type);

                            },
                          );
                        },
                        itemCount: locationController.suggestion.length,
                      );
              }),
            )
          ],
        ),
      ),
    );
  }
}

