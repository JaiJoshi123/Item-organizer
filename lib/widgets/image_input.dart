import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import './clickable_image.dart';

class ImageInput extends StatefulWidget {
  String? initialImageUrl;
  Function onSelectImage, unFocusAll;
  ImageInput(
      {required this.onSelectImage,
      required this.unFocusAll,
      this.initialImageUrl});

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _pickedImage;
  String? _initialImageUrl;

  @override
  void initState() {
    super.initState();
    _initialImageUrl = widget.initialImageUrl;
  }

  Future<void> _chooseImage(BuildContext context, bool isCamera) async {
    Navigator.of(context).pop();
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );

    if (imageFile == null) {
      return;
    }

    setState(() {
      _pickedImage = File(imageFile.path);
    });
    widget.onSelectImage(_pickedImage);
  }

  Widget _createModalSheetIcons(
      String title, IconData icon, bool isCamera, BuildContext context) {
    return InkWell(
      onTap: () => _chooseImage(context, isCamera),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            child: Icon(
              icon,
              color: Colors.white,
            ),
            backgroundColor: Colors.black,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(title),
        ],
      ),
    );
  }

  void _selectImage(BuildContext context) async {
    widget.unFocusAll();
    final height = MediaQuery.of(context).size.height * 0.2;
    await showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        height: height,
        padding: EdgeInsets.only(top: height * 0.1, bottom: height * 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _createModalSheetIcons(
              "Camera",
              Icons.camera_alt,
              true,
              context,
            ),
            _createModalSheetIcons(
              "Gallery",
              Icons.image_search,
              false,
              context,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_pickedImage != null)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                child: ClickableImage(
                  image: _pickedImage,
                  isFile: true,
                  imageId: "NewItemImage",
                ),
              ),
              Positioned(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _pickedImage = null;
                      widget.onSelectImage(null);
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                right: 5,
                top: 5,
              ),
            ],
          ),
        if (_pickedImage == null && _initialImageUrl != null)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                child: ClickableImage(
                  image: _initialImageUrl,
                  isFile: false,
                  imageId: "NewItemImage",
                ),
              ),
              Positioned(
                child: Container(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Current Image",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(30.0))),
                ),
                left: 5,
                top: 5,
              ),
            ],
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _selectImage(context),
            icon: Icon(Icons.add_a_photo),
            label: _pickedImage == null
                ? (_initialImageUrl == null
                    ? Text("Add an image")
                    : Text("Replace image?"))
                : Text("Replace image?"),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
