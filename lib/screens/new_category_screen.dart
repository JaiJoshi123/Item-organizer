import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/db_helper.dart';

class NewCategoryScreen extends StatefulWidget {
  static const routeName = "/new_category";
  Category? initialCategory;
  NewCategoryScreen({this.initialCategory});
  @override
  State<NewCategoryScreen> createState() => _NewCategoryScreenState();
}

class _NewCategoryScreenState extends State<NewCategoryScreen> {
  bool isUploading = false;

  var _nameFocusNode = FocusNode();
  var _descriptionFocusNode = FocusNode();

  TextEditingController? _nameController;
  TextEditingController? _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.initialCategory != null) {
      _nameController!.text = widget.initialCategory!.name;
      _descriptionController!.text = widget.initialCategory!.description ?? "";
    }
  }

  void _saveCategory() async {
    _nameFocusNode.unfocus();
    _descriptionFocusNode.unfocus();
    if (_nameController!.text.isEmpty || _nameController!.text == "All") {
      return;
    }
    setState(() {
      isUploading = true;
    });
    Provider.of<DBHelper>(context, listen: false)
        .addCategory(
      name: _nameController!.text,
      description: _descriptionController!.text,
    )
        .then((value) {
      setState(() {
        isUploading = false;
      });
      Navigator.of(context).pop();
    });
  }

  void _editCategory() async {
    _nameFocusNode.unfocus();
    _descriptionFocusNode.unfocus();
    if (widget.initialCategory == null ||
        _nameController!.text.isEmpty ||
        _nameController!.text == "All") {
      return;
    }
    setState(() {
      isUploading = true;
    });
    Provider.of<DBHelper>(context, listen: false)
        .editCategory(
      initialCategory: widget.initialCategory!,
      name: _nameController!.text,
      description: _descriptionController!.text,
    )
        .then((value) {
      setState(() {
        isUploading = false;
      });
      Navigator.of(context).pop();
    }).onError((error, stackTrace) {
      print(error.toString());
    });
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
        title: isUploading ? Text("Uploading..") : Text("Add a new category"),
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
                  Text("Uploading Category, Please wait.."),
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
                              labelText: "Name",
                              icon: Icons.text_fields,
                              focusNode: _nameFocusNode,
                              controller: _nameController!),
                          SizedBox(
                            height: 10,
                          ),
                          createTextField(
                              labelText: "Description",
                              icon: Icons.abc,
                              focusNode: _descriptionFocusNode,
                              maxLines: 3,
                              controller: _descriptionController!),
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
                    icon: widget.initialCategory == null
                        ? Icon(Icons.add)
                        : Icon(Icons.edit),
                    label: widget.initialCategory == null
                        ? Text('Add Category')
                        : Text('Edit Category'),
                    onPressed: widget.initialCategory == null
                        ? _saveCategory
                        : _editCategory,
                  ),
                )
              ],
            ),
    );
  }
}
