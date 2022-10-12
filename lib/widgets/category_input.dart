import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/db_helper.dart';

import '../screens/new_category_screen.dart';

class CategoryInput extends StatelessWidget {
  String? initialCategoryId;
  Function onSelectCategory;

  CategoryInput({
    this.initialCategoryId = null,
    required this.onSelectCategory,
  });

  Widget build(BuildContext context) {
    final provider = Provider.of<DBHelper>(context, listen: false);
    return StreamBuilder<List<Category>>(
      stream: provider.getAllCategoriesStream(),
      builder: (context, categoriesSnapshot) {
        if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
          return const Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(
              color: Colors.black,
              backgroundColor: Colors.white,
            ),
          );
        } else if (categoriesSnapshot.hasData) {
          final categories = categoriesSnapshot.data!;
          Category? currentCategory;
          if (initialCategoryId != null) {
            currentCategory = categories
                .firstWhere((category) => category.id == initialCategoryId);
          }

          return CustomDropDownMenu(
            categories: categories,
            onSelectCategory: onSelectCategory,
            currentCategory: currentCategory,
          );
        }
        return Center(
          child: Icon(Icons.error),
        );
      },
    );
  }
}

class CustomDropDownMenu extends StatefulWidget {
  List<Category> categories;
  Category? currentCategory;
  Function onSelectCategory;
  CustomDropDownMenu({
    required this.categories,
    this.currentCategory,
    required this.onSelectCategory,
  });

  @override
  State<CustomDropDownMenu> createState() => _CustomDropDownMenuState();
}

class _CustomDropDownMenuState extends State<CustomDropDownMenu> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: DropdownButtonFormField<Category>(
            items: widget.categories.map((category) {
              return DropdownMenuItem<Category>(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                widget.currentCategory = newValue as Category;
                widget.categories.removeWhere(
                    (category) => category.id == widget.currentCategory!.id);
                widget.categories.insert(0, widget.currentCategory!);
                widget.onSelectCategory(widget.currentCategory!.id);
              });
            },
            value: widget.currentCategory,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.category,
                color: Colors.black54,
              ),
              contentPadding: EdgeInsets.only(left: 20),
              filled: true,
              fillColor: Colors.transparent,
              hintText: "Select Category",
              label: Text("Category"),
              floatingLabelStyle: TextStyle(color: Colors.black),
              focusColor: Colors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.02,
        ),
        CircleAvatar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          child: IconButton(
            tooltip: "Add a new category",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => NewCategoryScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.add,
            ),
          ),
        ),
      ],
    );
  }
}
