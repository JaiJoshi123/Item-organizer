import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as sysPaths;

import '../helpers/db_helper.dart';

import '../screens/new_item_screen.dart';
import '../screens/new_item_location_screen.dart';

import '../widgets/clickable_image.dart';

enum ShareOptions {
  Text,
  Image,
  Both,
}

class ItemDetailsScreen extends StatefulWidget {
  static const routeName = "/item";

  String itemId;
  ItemDetailsScreen({required this.itemId});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool isUpdating = false;
  String loadingTitle = "Deleting Item...";

  Widget _createDetailsItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            thickness: 2,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            content,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Divider(
            thickness: 2,
          ),
        ],
      ),
    );
  }

  void restorePreviousLocation(String itemId, String previousLocationId) {
    setState(() {
      isUpdating = true;
      loadingTitle = "Updating item...";
    });
    Provider.of<DBHelper>(context, listen: false)
        .restorePreviousLocation(
      itemId: itemId,
      previousLocationId: previousLocationId,
    )
        .then((value) {
      setState(() {
        isUpdating = false;
      });
    });
  }

  Widget _createAppBarIconButton(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: ClipOval(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white54,
          ),
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.portrait;
    print(isPotrait);
    return Scaffold(
      body: isUpdating
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(loadingTitle),
                  SizedBox(
                    height: 10,
                  ),
                  CircularProgressIndicator(color: Colors.black),
                ],
              ),
            )
          : StreamBuilder<Item>(
              stream: Provider.of<DBHelper>(context, listen: false)
                  .getSingleItemStream(widget.itemId),
              builder: (ctx, itemSnapshot) {
                if (itemSnapshot.connectionState == ConnectionState.waiting) {
                  return const SafeArea(
                    child: LinearProgressIndicator(
                      color: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                  );
                }

                if (itemSnapshot.hasData) {
                  final item = itemSnapshot.data!;
                  return SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                ClickableImage(
                                  image: item.currentLocation.imageUrl,
                                  isFile: false,
                                  imageId: item.id,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      _createAppBarIconButton(IconButton(
                                        icon: Icon(Icons.arrow_back),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )),
                                      Spacer(),
                                      _createAppBarIconButton(FavoriteButton(
                                        isFavorite: item.isFavorite,
                                        itemId: item.id,
                                      )),
                                      _createAppBarIconButton(
                                        ShareButton(
                                          item: item,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: Chip(
                                    label: Text(
                                      item.currentLocation.updatedAtMonthDate,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.black54,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 30,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Created At: ${item.createdAtDate}",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Last Updated At: ${item.updatedAtDate}",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                  thickness: 2,
                                ),
                                Text(
                                  "Description",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Divider(
                                  thickness: 2,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                  thickness: 2,
                                ),
                                Text(
                                  "Current Location",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Created At: ${item.currentLocation.createdAtDate}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "Last Updated At: ${item.currentLocation.updatedAtDate}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  item.currentLocation.location,
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Divider(
                                  thickness: 2,
                                ),
                              ],
                            ),
                          ),
                          PreviousLocations(
                            onRestoreLocation: restorePreviousLocation,
                            previousLocations: item.previousLocations,
                            itemId: item.id,
                            height: isPotrait
                                ? MediaQuery.of(context).size.height * 0.3
                                : MediaQuery.of(context).size.height * 0.8,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => NewItemLocationScreen(
                                          item: item,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.add_location_alt),
                                  label: Text("Add a new location"),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => NewItemScreen(
                                          initialItem: item,
                                          initialCategoryId: item.categoryId,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.edit),
                                  label: Text("Edit"),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(
                                            "Are you sure you want to delete"),
                                        content: Text(
                                          "${item.name} will be deleted forever",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        actionsAlignment:
                                            MainAxisAlignment.spaceAround,
                                        actions: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.of(ctx).pop(true);
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
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.of(ctx).pop(false);
                                            },
                                            icon: Icon(Icons.close),
                                            label: Text("Cancel"),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.black),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).then((value) {
                                      if (value == true) {
                                        setState(() {
                                          isUpdating = true;
                                        });
                                        Provider.of<DBHelper>(context,
                                                listen: false)
                                            .deleteItem(widget.itemId)
                                            .then((value) {
                                          setState(() {
                                            isUpdating = false;
                                          });
                                          Navigator.of(context).pop(item.name);
                                        });
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
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
            ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  bool isFavorite;
  String itemId;
  FavoriteButton({required this.isFavorite, required this.itemId});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: widget.isFavorite ? Icon(Icons.star) : Icon(Icons.star_border),
      onPressed: () async {
        setState(() {
          widget.isFavorite = !widget.isFavorite;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: widget.isFavorite
              ? Text("Item added to Favorites")
              : Text("Item removed from Favorites"),
        ));
        Provider.of<DBHelper>(context, listen: false)
            .toggleFavorite(widget.itemId)
            .onError((error, stackTrace) => setState(() {
                  widget.isFavorite = !widget.isFavorite;
                }));
      },
    );
  }
}

class ShareButton extends StatefulWidget {
  final Item item;
  ShareButton({required this.item});

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  bool isSharing = false;
  Future<void> shareItemData(Item item, ShareOptions choice) async {
    setState(() {
      isSharing = true;
    });

    switch (choice) {
      case ShareOptions.Text:
        await Share.shareWithResult(
          "Name: ${item.name}\nDescription: ${item.description}\nLocation: ${item.currentLocation.location}\nCreated At: ${item.createdAt}\nLast updated At: ${item.updatedAt}",
        );
        break;
      case ShareOptions.Image:
        final imageUri = Uri.parse(item.currentLocation.imageUrl);
        final response = await http.get(imageUri);
        final bytes = response.bodyBytes;

        final temp = await sysPaths.getApplicationDocumentsDirectory();
        final imagePath = "${temp.path}/${item.id}.jpg";
        File(imagePath).writeAsBytesSync(bytes);

        await Share.shareFilesWithResult(
          [imagePath],
        );
        await File(imagePath).delete();
        break;
      case ShareOptions.Both:
        final imageUri = Uri.parse(item.currentLocation.imageUrl);
        final response = await http.get(imageUri);
        final bytes = response.bodyBytes;

        final temp = await sysPaths.getApplicationDocumentsDirectory();
        final imagePath = "${temp.path}/${item.id}.jpg";
        File(imagePath).writeAsBytesSync(bytes);

        await Share.shareFilesWithResult(
          [imagePath],
          text:
              "Name: ${item.name}\nDescription: ${item.description}\nLocation: ${item..currentLocation.location}\nCreated At: ${item.createdAt}\nLast updated At: ${item.updatedAt}",
        );
        await File(imagePath).delete();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isSharing
        ? CircularProgressIndicator(
            color: Colors.black,
          )
        : IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              showDialog<ShareOptions>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("How do you want to share?"),
                  actionsAlignment: MainAxisAlignment.spaceAround,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop(ShareOptions.Text);
                        },
                        icon: Icon(Icons.list_alt),
                        label: Text("Only Item Details"),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop(ShareOptions.Image);
                        },
                        icon: Icon(Icons.image),
                        label: Text("Only Item image"),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop(ShareOptions.Both);
                        },
                        icon: Icon(Icons.all_inclusive),
                        label: Text("Both item details and image"),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "*sharing with image takes time.",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ).then(
                (value) {
                  if (value != null) {
                    shareItemData(widget.item, value).then((value) {
                      setState(() {
                        isSharing = false;
                      });
                    });
                  }
                },
              );
            });
  }
}

class PreviousLocations extends StatefulWidget {
  final Function onRestoreLocation;
  final String itemId;
  final List<ItemLocation> previousLocations;
  final double height;
  PreviousLocations({
    required this.previousLocations,
    required this.height,
    required this.itemId,
    required this.onRestoreLocation,
  });

  @override
  State<PreviousLocations> createState() => _PreviousLocationsState();
}

class _PreviousLocationsState extends State<PreviousLocations> {
  @override
  Widget build(BuildContext context) {
    widget.previousLocations.sort((b, a) => a.updatedAt.compareTo(b.updatedAt));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              thickness: 2,
            ),
            Text(
              "Previous Locations",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: widget.previousLocations.length > 0
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, i) {
                        final prevLoc = widget.previousLocations[i];
                        final containerHeight = widget.height;

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        child: ClickableImage(
                                          image: prevLoc.imageUrl,
                                          isFile: false,
                                          imageId: prevLoc.id,
                                        ),
                                      ),
                                      Text(
                                        prevLoc.location,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Created At: ",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        prevLoc.createdAtDate,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Last Updated At: ",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        prevLoc.updatedAtDate,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            icon: Icon(Icons.rotate_left),
                                            label: Text("Restore Location"),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.black),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            icon: Icon(Icons.close),
                                            label: Text("Back"),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.black),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ).then((value) {
                              if (value == true) {
                                widget.onRestoreLocation(
                                    widget.itemId, prevLoc.id);
                              }
                            });
                          },
                          child: Container(
                            height: containerHeight,
                            width: containerHeight,
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Stack(
                                  children: [
                                    FadeInImage(
                                      placeholder: AssetImage(
                                          'assets/images/image_loader.gif'),
                                      image: NetworkImage(prevLoc.imageUrl),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: containerHeight,
                                    ),
                                    Positioned(
                                      top: 5,
                                      left: 5,
                                      child: Chip(
                                        label: Text(
                                          prevLoc.updatedAtMonthDate,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: widget.previousLocations.length,
                    )
                  : Center(
                      child: Text("No previous locations"),
                    ),
            ),
            Divider(
              thickness: 2,
            ),
          ],
        ),
      ),
    );
  }
}
