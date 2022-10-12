import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/image_input.dart';
import '../widgets/category_input.dart';

import '../helpers/db_helper.dart';

class NewItemScreen extends StatefulWidget {
  static const routeName = "/new_item";

  Item? initialItem;
  String? initialCategoryId;
  NewItemScreen({this.initialItem, this.initialCategoryId});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  bool isUploading = false;

  var _nameFocusNode = FocusNode();
  var _itemDescriptionFocusNode = FocusNode();
  var _itemLocationFocusNode = FocusNode();
  var _categoryFocusNode = FocusNode();

  TextEditingController? _nameController;
  TextEditingController? _itemLocationController;
  TextEditingController? _itemDescriptionController;
  File? _pickedImage;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _itemLocationController = TextEditingController();
    _itemDescriptionController = TextEditingController();

    if (widget.initialItem != null) {
      _nameController!.text = widget.initialItem!.name;
      _itemDescriptionController!.text = widget.initialItem!.description;
      _itemLocationController!.text =
          widget.initialItem!.currentLocation.location;
    }

    _selectedCategoryId = widget.initialCategoryId;
  }

  void _savePlace() async {
    setState(() {
      isUploading = true;
    });
    unfocusAll();
    if (_nameController!.text.isEmpty ||
        _pickedImage == null ||
        _itemLocationController!.text.isEmpty ||
        _itemDescriptionController!.text.isEmpty ||
        _selectedCategoryId == null) {
      setState(() {
        isUploading = false;
      });

      return;
    }

    Provider.of<DBHelper>(context, listen: false)
        .addItem(
      name: _nameController!.text,
      itemDescription: _itemDescriptionController!.text,
      itemCurrentLocation: _itemLocationController!.text,
      categoryId: _selectedCategoryId!,
      image: _pickedImage!,
    )
        .then((value) {
      setState(() {
        isUploading = false;
      });
      Navigator.of(context).pop();
    });
  }

  void _editPlace() async {
    setState(() {
      isUploading = true;
    });
    unfocusAll();
    if (widget.initialItem == null ||
        _nameController!.text.isEmpty ||
        _itemLocationController!.text.isEmpty ||
        _itemDescriptionController!.text.isEmpty ||
        _selectedCategoryId == null) {
      setState(() {
        isUploading = false;
      });
      return;
    }

    Provider.of<DBHelper>(context, listen: false)
        .editItem(
      item: widget.initialItem!,
      name: _nameController!.text,
      itemDescription: _itemDescriptionController!.text,
      currentLocation: _itemLocationController!.text,
      categoryId: _selectedCategoryId!,
      currentLocationImage: _pickedImage,
    )
        .then((value) {
      setState(() {
        isUploading = false;
      });
      Navigator.of(context).pop();
    });
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
  }

  void selectImage(File? selectedImage) {
    _pickedImage = selectedImage;
  }

  void unfocusAll() {
    _nameFocusNode.unfocus();
    _itemLocationFocusNode.unfocus();
    _itemDescriptionFocusNode.unfocus();
    _categoryFocusNode.unfocus();
  }

  TextField createTextField(
      {required String labelText,
      required IconData icon,
      required FocusNode focusNode,
      required TextEditingController controller,
      int? maxLines = null}) {
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
        title: isUploading
            ? Text("Uploading..")
            : (widget.initialItem != null)
                ? Text("Editing ${widget.initialItem!.name}")
                : Text("Add a new item"),
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
                  Text("Uploading item, Please wait.."),
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
                          CategoryInput(
                            initialCategoryId: _selectedCategoryId,
                            onSelectCategory: selectCategory,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          createTextField(
                              labelText: "Name",
                              icon: Icons.text_fields,
                              focusNode: _nameFocusNode,
                              controller: _nameController!),
                          SizedBox(
                            height: 10,
                          ),
                          createTextField(
                              labelText: "Item Description",
                              icon: Icons.abc,
                              focusNode: _itemDescriptionFocusNode,
                              maxLines: 3,
                              controller: _itemDescriptionController!),
                          SizedBox(
                            height: 10,
                          ),
                          createTextField(
                            labelText: "Item Location",
                            icon: Icons.location_on,
                            focusNode: _itemLocationFocusNode,
                            maxLines: 3,
                            controller: _itemLocationController!,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ImageInput(
                            onSelectImage: selectImage,
                            unFocusAll: unfocusAll,
                            initialImageUrl: widget.initialItem != null
                                ? widget.initialItem!.currentLocation.imageUrl
                                : null,
                          ),
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
                    icon: widget.initialItem == null
                        ? Icon(Icons.add)
                        : Icon(Icons.edit),
                    label: widget.initialItem == null
                        ? Text('Add Item')
                        : Text('Edit Item'),
                    onPressed:
                        widget.initialItem == null ? _savePlace : _editPlace,
                  ),
                )
              ],
            ),
    );
  }
}
