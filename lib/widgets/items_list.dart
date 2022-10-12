import 'package:flutter/material.dart';

import '../widgets/clickable_image.dart';

import '../helpers/db_helper.dart';

import '../screens/item_details_screen.dart';

enum ItemsView {
  List,
  Grid,
  Details,
}

enum Sort {
  CreatedAt,
  UpdatedAt,
  Name,
}

enum SortBy {
  Ascending,
  Descending,
}

class ItemsList extends StatefulWidget {
  final List<Item> items;
  final Function(String) onListTap;
  ItemsList({required this.items, required this.onListTap});

  @override
  State<ItemsList> createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<Map<String, dynamic>> _views = [
    {
      "view": ItemsView.Details,
      "title": "Details view",
      "icon": Icons.format_list_bulleted,
    },
    {
      "view": ItemsView.List,
      "title": "List view",
      "icon": Icons.view_list,
    },
    {
      "view": ItemsView.Grid,
      "title": "Grid view",
      "icon": Icons.grid_view,
    },
  ];

  Sort _currentSort = Sort.UpdatedAt;
  SortBy _currentSortBy = SortBy.Ascending;
  int _currentItemsViewIndex = 0;

  PopupMenuItem<Sort> createPopupMenuItem(String title, Sort sort) {
    return PopupMenuItem<Sort>(
      value: sort,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            child: Text(title),
          ),
          if (sort == _currentSort) Icon(Icons.check),
        ],
      ),
    );
  }

  String get sortTitle {
    switch (_currentSort) {
      case Sort.Name:
        return "Name";
      case Sort.CreatedAt:
        return "Created At";
      case Sort.UpdatedAt:
        return "Updated At";
      default:
        return "Updated At";
    }
  }

  List<Item> get updatedItems {
    if (_currentSortBy == SortBy.Descending) {
      if (_currentSort == Sort.Name) {
        widget.items.sort((a, b) => a.name.compareTo(b.name));
        return widget.items;
      } else if (_currentSort == Sort.CreatedAt) {
        widget.items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return widget.items;
      } else if (_currentSort == Sort.UpdatedAt) {
        widget.items.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        return widget.items;
      }
    } else {
      if (_currentSort == Sort.Name) {
        widget.items.sort((b, a) => a.name.compareTo(b.name));
        return widget.items;
      } else if (_currentSort == Sort.CreatedAt) {
        widget.items.sort((b, a) => a.createdAt.compareTo(b.createdAt));
        return widget.items;
      } else if (_currentSort == Sort.UpdatedAt) {
        widget.items.sort((b, a) => a.updatedAt.compareTo(b.updatedAt));
        return widget.items;
      }
    }

    return widget.items;
  }

  Widget getRecentlyWidget(Item item) {
    bool isRecentlyCreated = !item.createdAt
        .difference(DateTime.now().subtract(Duration(minutes: 30)))
        .isNegative;
    bool isRecentlyUpdated = !item.updatedAt
        .difference(DateTime.now().subtract(Duration(minutes: 30)))
        .isNegative;

    String? title = isRecentlyCreated
        ? "Recently Created"
        : isRecentlyUpdated
            ? "Recently Updated"
            : null;
    return title == null
        ? Text("")
        : Chip(
            label: Text(
              title,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.black54,
          );
  }

  Widget get listWidget {
    switch (_views[_currentItemsViewIndex]["view"]) {
      case ItemsView.Details:
        return ListView.builder(
          itemBuilder: (_, i) {
            final item = updatedItems[i];

            return Card(
              elevation: 0,
              child: ListTile(
                title: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Last Updated At:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${item.updatedAtDate}",
                      style: TextStyle(fontSize: 15),
                    ),
                    getRecentlyWidget(item),
                  ],
                ),
                trailing: FavoriteButton(
                  isFavorite: item.isFavorite,
                  itemId: item.id,
                ),
                onTap: () => widget.onListTap(item.id),
              ),
            );
          },
          itemCount: widget.items.length,
        );
      case ItemsView.Grid:
        return OrientationBuilder(
          builder: (context, orientation) => GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio:
                  orientation == Orientation.portrait ? 1 / 1.35 : 1 / 1.6,
              // crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemBuilder: (ctx, i) {
              final item = updatedItems[i];

              return GestureDetector(
                onTap: () => widget.onListTap(item.id),
                child: Card(
                  key: ValueKey(item.id),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            FavoriteButton(
                              isFavorite: item.isFavorite,
                              itemId: item.id,
                            ),
                          ],
                        ),
                        Text(
                          item.currentLocation.location,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Created At:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${item.createdAtDate}",
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Last Updated At:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${item.updatedAtDate}",
                          style: TextStyle(fontSize: 15),
                        ),
                        Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: getRecentlyWidget(item),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: updatedItems.length,
          ),
        );
      case ItemsView.List:
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (_, i) {
            final item = updatedItems[i];

            return GestureDetector(
              onTap: () => widget.onListTap(item.id),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: CustomFadeInImage(
                                imageUrl: item.currentLocation.imageUrl),
                          ),
                        ),
                        Positioned(
                          top: 15,
                          right: 15,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                                border: Border.all(
                                    color: Colors.grey.withAlpha(40),
                                    width: 2)),
                            // padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: FavoriteButton(
                                isFavorite: item.isFavorite,
                                itemId: item.id,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${item.name}",
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 26),
                          ),
                          Text(
                            item.currentLocation.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Created At: ${item.createdAtDate}",
                          ),
                          Text(
                            "Last Updated At: ${item.updatedAtDate}",
                            style: TextStyle(fontSize: 15),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: getRecentlyWidget(item),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: widget.items.length,
        );
      default:
        return Text("List");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.items.length == 0
        ? Center(
            child: Text("No items added yet!"),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Row(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: "Change list view",
                      child: Ink(
                        child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          onTap: () {
                            setState(() {
                              _currentItemsViewIndex =
                                  (_currentItemsViewIndex + 1) % _views.length;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                _views[_currentItemsViewIndex]["icon"],
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(_views[_currentItemsViewIndex]["title"])
                            ],
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Tooltip(
                      message: "Change list view",
                      child: GestureDetector(
                        onTapDown: (position) {
                          double left = position.globalPosition.dx;
                          double top = position.globalPosition.dy;
                          showMenu<Sort>(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              left,
                              top,
                              left + 1,
                              top + 1,
                            ),
                            items: [
                              createPopupMenuItem("Name", Sort.Name),
                              createPopupMenuItem("Created At", Sort.CreatedAt),
                              createPopupMenuItem("Updated At", Sort.UpdatedAt),
                            ],
                          ).then((value) {
                            if (value != null) {
                              setState(() {
                                _currentSort = value;
                              });
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.filter_list_alt),
                            SizedBox(
                              width: 5,
                            ),
                            Text(sortTitle),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: _currentSortBy == SortBy.Descending
                          ? "Sort by descending"
                          : "Sort by ascending",
                      icon: _currentSortBy == SortBy.Descending
                          ? Icon(Icons.arrow_downward)
                          : Icon(Icons.arrow_upward),
                      onPressed: () {
                        setState(() {
                          if (_currentSortBy == SortBy.Ascending) {
                            _currentSortBy = SortBy.Descending;
                          } else {
                            _currentSortBy = SortBy.Ascending;
                          }
                        });
                      },
                    ),
                  ],
                ),
                visualDensity: VisualDensity(vertical: -4),
              ),
              Expanded(
                child: listWidget,
              ),
            ],
          );
  }
}
