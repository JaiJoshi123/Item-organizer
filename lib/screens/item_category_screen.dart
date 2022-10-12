import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/new_item_screen.dart';
import '../screens/new_category_screen.dart';
import '../screens/items_list_screen.dart';

import '../widgets/category_item.dart';

import '../helpers/db_helper.dart';

class ItemCategoryScreen extends StatefulWidget {
  static const routeName = "/";

  @override
  State<ItemCategoryScreen> createState() => _ItemCategoryScreenState();
}

class _ItemCategoryScreenState extends State<ItemCategoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _openNewItemScreen(BuildContext context, String? initialCategoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => NewItemScreen(),
        settings: RouteSettings(arguments: initialCategoryId),
      ),
    );
  }

  void _openNewCategoryScreen(Category? initialCategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => NewCategoryScreen(
          initialCategory: initialCategory,
        ),
      ),
    );
  }

  void _openItemsListScreen(category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ItemsListScreen(),
        settings: RouteSettings(arguments: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/app_logo.png'),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "Item Organizer",
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: StreamBuilder<List<Category>>(
          stream: Provider.of<DBHelper>(context, listen: false)
              .getAllCategoriesStream(),
          builder: (ctx, categorySnapshot) {
            if (categorySnapshot.connectionState == ConnectionState.waiting) {
              return const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(
                  color: Colors.black,
                  backgroundColor: Colors.white,
                ),
              );
            }

            final categories = categorySnapshot.data!;

            return Stack(
              children: [
                GridView.builder(
                  padding: const EdgeInsets.all(25),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemBuilder: (ctx, i) {
                    if (i == 0) {
                      return CategoryItem(
                        color: Colors.white,
                        category: Category(
                          name: "All",
                          id: "All",
                          description: "",
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                        key: ValueKey("All"),
                        isAll: true,
                        onPress: _openItemsListScreen,
                      );
                    } else if (i == categories.length + 1) {
                      return Card(
                        key: ValueKey(
                            "Add Category:${Provider.of<DBHelper>(context, listen: false).getCurrentUser.uid}"),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: () => _openNewCategoryScreen(null),
                          splashColor: Colors.grey,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return CategoryItem(
                        color: Colors.white,
                        category: categories[i - 1],
                        key: ValueKey(categories[i - 1].id),
                        isAll: false,
                        onPress: _openItemsListScreen,
                      );
                    }
                  },
                  itemCount: categories.length + 2,
                ),
                if (categories.length > 0)
                  Positioned.fill(
                    bottom: 10,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.grey[50]!),
                            ),
                          ),
                        ),
                        onPressed: () => _openNewItemScreen(context, "All"),
                        icon: Icon(Icons.add),
                        label: Text("Add Item"),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
