import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/db_helper.dart';

import '../widgets/items_list.dart';

import './item_details_screen.dart';
import './new_item_screen.dart';
import './new_category_screen.dart';
import './search_screen.dart';

class ItemsListScreen extends StatefulWidget {
  static const routeName = '/item_list';

  ItemsListScreen({Key? key}) : super(key: key);

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool isDeleting = false;

  void _openNewItemScreen(String? initialCategoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => NewItemScreen(
          initialCategoryId: initialCategoryId,
        ),
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
    ).then((value) {
      Navigator.of(context).pop();
    });
  }

  void _openItemDetailsScreen(String itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ItemDetailsScreen(
          itemId: itemId,
        ),
      ),
    ).then((value) {
      if (value != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${value} was deleted successfully.",
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
    });
  }

  void deleteCategory(Category category) async {
    setState(() {
      isDeleting = true;
    });
    Provider.of<DBHelper>(context, listen: false)
        .deleteCategory(category: category)
        .then((value) {
      setState(() {
        isDeleting = false;
      });
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final categoryData = ModalRoute.of(context)!.settings.arguments as Category;
    return isDeleting
        ? Scaffold(
            appBar: AppBar(
              title: Text(categoryData.name),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.black,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Deleting category..."),
                  SizedBox(
                    height: 5,
                  ),
                  CircularProgressIndicator(
                    color: Colors.black,
                  )
                ],
              ),
            ),
          )
        : StreamBuilder<List<Item>>(
            stream: categoryData.id == "All"
                ? Provider.of<DBHelper>(context, listen: false)
                    .getAllItemsStream()
                : Provider.of<DBHelper>(context, listen: false)
                    .getCategoryItemsStream(categoryData.id),
            builder: (context, itemsSnapshot) {
              if (itemsSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(categoryData.name),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.black,
                  ),
                  body: LinearProgressIndicator(
                    color: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                );
              }

              if (itemsSnapshot.hasData) {
                final items = itemsSnapshot.data!;
                return Scaffold(
                  appBar: AppBar(
                    title: Text(categoryData.name),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.black,
                    actions: [
                      IconButton(
                        tooltip: "Search",
                        onPressed: items == null
                            ? null
                            : () {
                                showSearch<String?>(
                                  context: context,
                                  delegate: SearchItems(items: items),
                                ).then((itemId) {
                                  if (itemId == null) return;
                                  _openItemDetailsScreen(itemId);
                                }).onError((error, stackTrace) {
                                  print(error);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("Some error occured!")));
                                });
                              },
                        icon: Icon(Icons.search),
                      ),
                      IconButton(
                        tooltip: "Add a new item",
                        onPressed: () => _openNewItemScreen(
                            categoryData.id == "All" ? null : categoryData.id),
                        icon: Icon(Icons.add_box),
                      ),
                    ],
                  ),
                  body: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CategoryDetails(
                          totalItems: items.length,
                          category: categoryData,
                          onEdit: _openNewCategoryScreen,
                          onDelete: deleteCategory,
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            ItemsList(
                              items: items,
                              onListTap: _openItemDetailsScreen,
                            ),
                            Positioned.fill(
                              bottom: 10,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: ElevatedButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side:
                                            BorderSide(color: Colors.grey[50]!),
                                      ),
                                    ),
                                  ),
                                  onPressed: () => _openNewItemScreen(
                                      categoryData.id == "All"
                                          ? null
                                          : categoryData.id),
                                  icon: Icon(Icons.add),
                                  label: Text("Add Item"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Center(
                child: Icon(
                  Icons.error,
                  size: 50,
                ),
              );
            },
          );
  }
}

class CategoryDetails extends StatefulWidget {
  final int totalItems;
  final Category category;
  final Function(Category) onEdit;
  final Function(Category) onDelete;

  CategoryDetails({
    required this.category,
    required this.totalItems,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CategoryDetails> createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(
        () {
          isOpen = !isOpen;
        },
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: (isOpen ? 8 : 0), left: 8, right: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "View Category Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 30,
                  ),
                ],
              ),
              if (isOpen)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.category.description != null &&
                          widget.category.description!.trim() != "")
                        Text(
                          widget.category.description!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (widget.category.description != null &&
                          widget.category.description!.trim() != "")
                        SizedBox(
                          height: 5,
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Created At",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                widget.category.createdAtMonthDate,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Updated At",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                widget.category.updatedAtMonthDate,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Total Items",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "${widget.totalItems}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (widget.category.id != "All")
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  widget.onEdit(widget.category);
                                },
                                icon: Icon(Icons.edit),
                                label: Text("Edit"),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.black),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Navigator.of(context).pop(true);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        "Are you sure you want to delete?",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Text(
                                        "Category: ${widget.category.name} and ${widget.totalItems} items belonging to it will be deleted forever!",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.spaceAround,
                                      actions: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          icon: Icon(Icons.delete),
                                          label: Text("Delete"),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          icon: Icon(Icons.cancel),
                                          label: Text("Cancel"),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.black),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      widget.onDelete(widget.category);
                                    }
                                  });
                                },
                                icon: Icon(Icons.delete),
                                label: Text("Delete"),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
