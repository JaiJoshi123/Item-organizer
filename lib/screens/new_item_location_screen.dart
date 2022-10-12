import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/db_helper.dart';

import '../widgets/image_input.dart';

class NewItemLocationScreen extends StatefulWidget {
  static const routeName = "/new_item_location";

  final Item item;

  NewItemLocationScreen({required this.item});

  @override
  State<NewItemLocationScreen> createState() => _NewItemLocationScreenState();
}

class _NewItemLocationScreenState extends State<NewItemLocationScreen> {
  bool isUploading = false;

  File? _pickedImage;

  final _locationFocusNode = FocusNode();
  final _locationController = TextEditingController();

  void _addLocation() async {
    setState(() {
      isUploading = true;
    });

    if (_locationController.text.isEmpty ||
        _locationController.text == "All" ||
        _pickedImage == null) {
      return;
    }
    Provider.of<DBHelper>(context, listen: false)
      ..addLocation(
        item: widget.item,
        newLocation: _locationController.text,
        newLocationImage: _pickedImage!,
      ).then((value) {
        setState(() {
          isUploading = false;
        });
        Navigator.of(context).pop();
      });
  }

  void selectImage(File? selectedImage) {
    _pickedImage = selectedImage;
  }

  void unFocusAll() {
    _locationFocusNode.unfocus();
  }

  TextField createTextField({
    required String labelText,
    required IconData icon,
    required FocusNode focusNode,
    required TextEditingController controller,
    int? maxLines = null,
  }) {
    return TextField(
      cursorColor: Colors.black,
      focusNode: focusNode,
      keyboardType:
          maxLines != null ? TextInputType.text : TextInputType.multiline,
      textInputAction: TextInputAction.next,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          icon,
          color: Colors.black54,
        ),
        floatingLabelStyle: TextStyle(color: Colors.black),
        focusColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: maxLines == null
            ? EdgeInsets.symmetric(horizontal: 20)
            : EdgeInsets.all(20),
      ),
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        title: isUploading ? Text("Uploading..") : Text("Add a new location"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isUploading ? Colors.grey : Colors.black,
          ),
          onPressed: isUploading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Uploading new location, Please wait.."),
                  SizedBox(
                    height: 10,
                  ),
                  CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 10,
                      ),
                      child: Column(
                        children: [
                          createTextField(
                            labelText: "Location",
                            icon: Icons.abc,
                            maxLines: 3,
                            focusNode: _locationFocusNode,
                            controller: _locationController,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ImageInput(
                              onSelectImage: selectImage,
                              unFocusAll: unFocusAll)
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).buttonColor,
                      ),
                      elevation: MaterialStateProperty.all(0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    icon: Icon(Icons.add_location_alt),
                    label: Text('Add New Location'),
                    onPressed: _addLocation,
                  ),
                )
              ],
            ),
    );
  }
}
