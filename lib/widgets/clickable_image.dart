import 'package:flutter/material.dart';

import '../screens/image_screen.dart';

class ClickableImage extends StatefulWidget {
  dynamic image;
  bool isFile;
  String imageId;
  ClickableImage({
    required this.image,
    required this.isFile,
    required this.imageId,
  });

  @override
  State<ClickableImage> createState() => _ClickableImageState();
}

class _ClickableImageState extends State<ClickableImage> {
  bool showOverlapContainer = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          child: GestureDetector(
            onHorizontalDragStart: (_) {
              setState(() {
                showOverlapContainer = true;
              });
            },
            onHorizontalDragEnd: (_) {
              setState(() {
                showOverlapContainer = false;
              });
            },
            onLongPress: () {
              setState(() {
                showOverlapContainer = true;
              });
            },
            onLongPressEnd: (_) {
              setState(() {
                showOverlapContainer = false;
              });
            },
            onTap: () {
              Navigator.of(context, rootNavigator: false).push(
                MaterialPageRoute(
                  builder: (ctx) => ImageScreen(
                    isFile: widget.isFile,
                    image: widget.image,
                    imageId: widget.imageId,
                  ),
                ),
              );
            },
            child: widget.isFile
                ? Hero(
                    tag: widget.imageId,
                    child: Image.file(
                      widget.image,
                      fit: BoxFit.cover,
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: CustomFadeInImage(
                      imageUrl: widget.image,
                    ),
                  ),
          ),
        ),
        if (showOverlapContainer)
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black54,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Tap to view full screen image",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    Icons.touch_app,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }
}

class CustomFadeInImage extends StatelessWidget {
  const CustomFadeInImage({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      placeholder: AssetImage('assets/images/image_loader.gif'),
      image: NetworkImage(imageUrl),
      fit: BoxFit.cover,
      imageErrorBuilder: (ctx, _, st) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error),
            Text("Couldn't fetch image"),
          ],
        );
      },
    );
  }
}
