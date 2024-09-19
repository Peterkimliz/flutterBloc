import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullImagePageRoute extends StatelessWidget {
  final String imageDownloadUrl;

  const FullImagePageRoute({Key? key, required this.imageDownloadUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: CachedNetworkImage(
              imageUrl: imageDownloadUrl,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              placeholder: (context, url) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorWidget: (context, url, error) => const Stack(
                children: [Center(child: CircularProgressIndicator())],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.red,
                        size: 30,
                      ))),
            ),
          )
        ],
      ),
    );
  }
}
