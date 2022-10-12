import 'dart:io';

import 'package:flutter/material.dart';

class ImageScreen extends StatelessWidget {
  static const routeName = "/image";

  dynamic image;
  bool isFile;
  String imageId;

  ImageScreen({
    required this.image,
    required this.imageId,
    required this.isFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              maxScale: 20,
              child: isFile
                  ? Hero(
                      tag: imageId,
                      child: Image.file(
                        image,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Hero(
                      tag: imageId,
                      child: Image.network(
                        image,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
