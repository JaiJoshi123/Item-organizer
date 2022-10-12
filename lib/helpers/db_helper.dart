import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

class ItemLocation {
  String imageUrl, location, id;
  DateTime createdAt, updatedAt;

  ItemLocation({
    required this.id,
    required this.createdAt,
    required this.imageUrl,
    required this.location,
    required this.updatedAt,
  });

  /// Provides a user readable date for createdAt property
  String get createdAtDate {
    return DateFormat('dd/MM/yyyy, hh:mm a').format(createdAt);
  }

  /// Provides a user readable date for updatedAt property
  String get updatedAtDate {
    return DateFormat('dd/MM/yyyy, hh:mm a').format(updatedAt);
  }

  /// Provides a user readable date for createdAt property
  String get createdAtMonthDate {
    return DateFormat('MMM d, ' 'yy').format(createdAt);
  }

  /// Provides a user readable date for updatedAt property
  String get updatedAtMonthDate {
    return DateFormat('MMM d, ' 'yy').format(updatedAt);
  }
}

class Item {
  String id, name, categoryId, description;
  DateTime createdAt, updatedAt;
  bool isFavorite;

  ItemLocation currentLocation;
  List<ItemLocation> previousLocations;

  Item({
    required this.id,
    required this.categoryId,
    required this.createdAt,
    required this.description,
    required this.name,
    required this.updatedAt,
    required this.isFavorite,
    required this.currentLocation,
    this.previousLocations = const [],
  });

  /// Provides a user readable date for createdAt property
  String get createdAtDate {
    return DateFormat('dd/MM/yyyy, hh:mm a').format(createdAt);
  }

  /// Provides a user readable date for updatedAt property
  String get updatedAtDate {
    return DateFormat('dd/MM/yyyy, hh:mm a').format(updatedAt);
  }
}

class Category {
  String id, name;
  DateTime createdAt, updatedAt;

  String? description;

  Category({
    required this.createdAt,
    required this.updatedAt,
    this.description,
    required this.id,
    required this.name,
  });

  String get createdAtMonthDate {
    return DateFormat('MMM d, ' 'yy').format(createdAt);
  }

  /// Provides a user readable date for updatedAt property
  String get updatedAtMonthDate {
    return DateFormat('MMM d, ' 'yy').format(updatedAt);
  }
}

class DBHelper with ChangeNotifier {
  User get getCurrentUser {
    return FirebaseAuth.instance.currentUser!;
  }

  String get categoriesPath {
    return 'Categories/${getCurrentUser.uid}/User_Categories';
  }

  String get itemsPath {
    return 'Items/${getCurrentUser.uid}/User_Items';
  }

  Item _getItemFromFirebaseDoc(doc) {
    return Item(
      id: doc.reference.id,
      categoryId: doc.data()["categoryId"],
      createdAt: doc.data()["createdAt"].toDate(),
      description: doc.data()["description"],
      currentLocation: ItemLocation(
        id: doc.data()["currentLocation"]["id"],
        createdAt: doc.data()["currentLocation"]["createdAt"].toDate(),
        imageUrl: doc.data()["currentLocation"]["imageUrl"],
        location: doc.data()["currentLocation"]["location"],
        updatedAt: doc.data()["currentLocation"]["updatedAt"].toDate(),
      ),
      name: doc.data()["name"],
      updatedAt: doc.data()["updatedAt"].toDate(),
      isFavorite: doc.data()["isFavorite"],
      previousLocations: doc.data()["previousLocations"] != null &&
              doc.data()["previousLocations"].length > 0
          ? doc
              .data()["previousLocations"]
              .map<ItemLocation>(
                (prevLoc) => ItemLocation(
                  id: prevLoc["id"],
                  createdAt: prevLoc["createdAt"].toDate(),
                  imageUrl: prevLoc["imageUrl"],
                  location: prevLoc["location"],
                  updatedAt: prevLoc["updatedAt"].toDate(),
                ),
              )
              .toList()
          : [],
    );
  }

  Stream<List<Item>> getFavoriteItemsStream() {
    var stream = FirebaseFirestore.instance
        .collection(itemsPath)
        .where("isFavorite", isEqualTo: true)
        .snapshots();

    return stream.map((qShot) => qShot.docs
        .map(
          (doc) => _getItemFromFirebaseDoc(doc),
        )
        .toList());
  }

  Stream<List<Item>> getAllItemsStream() {
    var stream = FirebaseFirestore.instance.collection(itemsPath).snapshots();

    return stream.map((qShot) => qShot.docs
        .map(
          (doc) => _getItemFromFirebaseDoc(doc),
        )
        .toList());
  }

  Stream<List<Item>> getCategoryItemsStream(String categoryId) {
    var stream = FirebaseFirestore.instance
        .collection(itemsPath)
        .where("categoryId", isEqualTo: categoryId)
        .snapshots();

    return stream.map((qShot) => qShot.docs
        .map(
          (doc) => _getItemFromFirebaseDoc(doc),
        )
        .toList());
  }

  Stream<Item> getSingleItemStream(String itemId) {
    var stream =
        FirebaseFirestore.instance.doc("${itemsPath}/$itemId").snapshots();

    return stream.map((doc) {
      return _getItemFromFirebaseDoc(doc);
    });
  }

  Stream<List<Category>> getAllCategoriesStream() {
    var stream =
        FirebaseFirestore.instance.collection(categoriesPath).snapshots();

    return stream.map((qShot) => qShot.docs
        .map(
          (doc) => Category(
            id: doc.reference.id,
            createdAt: doc.data()["createdAt"].toDate(),
            updatedAt: doc.data()["updatedAt"].toDate(),
            description: doc.data()["description"],
            name: doc.data()["name"],
          ),
        )
        .toList());
  }

  Future<void> addCategory({required String name, String? description}) async {
    try {
      var currentTimestamp = Timestamp.now();
      final category =
          await FirebaseFirestore.instance.collection(categoriesPath).add(
        {
          'name': name.trim().toCapitalized(),
          'description': description,
          'createdAt': currentTimestamp,
          'updatedAt': currentTimestamp,
        },
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editCategory({
    required Category initialCategory,
    required String name,
    String? description,
  }) async {
    try {
      var currentTimestamp = Timestamp.now();
      await FirebaseFirestore.instance
          .doc("$categoriesPath/${initialCategory.id}")
          .update(
        {
          'name': name.trim().toCapitalized(),
          'description': description,
          'updatedAt': currentTimestamp,
        },
      );
      notifyListeners();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> deleteCategory({
    required Category category,
  }) async {
    try {
      await FirebaseFirestore.instance
          .doc("$categoriesPath/${category.id}")
          .delete();
      final itemsSnapshot =
          await FirebaseFirestore.instance.collection(itemsPath).get();
      final allItems = itemsSnapshot.docs;
      final filteredItems = allItems
          .where((document) => document.data()["categoryId"] == category.id)
          .toList();
      for (QueryDocumentSnapshot<Map<String, dynamic>> item in filteredItems) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('Item_images')
            .child(getCurrentUser.uid)
            .child(item.reference.id);
        final itemImages = await ref.listAll();

        for (var itemImageRef in itemImages.items) {
          await itemImageRef.delete();
        }
        await item.reference.delete();
      }

      notifyListeners();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> addItem({
    required String name,
    required String itemDescription,
    required String itemCurrentLocation,
    required String categoryId,
    required File image,
  }) async {
    var uniqueId = Uuid().v4();
    print(uniqueId);
    try {
      final _currentTimestamp = Timestamp.now();
      final addedItem =
          await FirebaseFirestore.instance.collection(itemsPath).add({
        "name": name.toCapitalized(),
        "description": itemDescription,
        "currentLocation": {
          "id": uniqueId,
          "location": itemCurrentLocation,
          "createdAt": _currentTimestamp,
          "updatedAt": _currentTimestamp,
        },
        "categoryId": categoryId,
        "createdAt": _currentTimestamp,
        "updatedAt": _currentTimestamp,
        "previousLocations": [],
        "isFavorite": false,
      });

      final ref = FirebaseStorage.instance
          .ref()
          .child('Item_images')
          .child(getCurrentUser.uid)
          .child(addedItem.id)
          .child("$uniqueId.jpg");

      String imageUrl = '';
      final UploadTask storageUploadTask = ref.putFile(image);
      await storageUploadTask.whenComplete(() async {
        imageUrl = await ref.getDownloadURL();
      });

      await addedItem.update({
        "currentLocation.imageUrl": imageUrl,
      });
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleFavorite(String itemId) async {
    try {
      final itemData =
          await FirebaseFirestore.instance.doc('${itemsPath}/$itemId').get();
      await itemData.reference.update({
        "isFavorite": !itemData.data()!["isFavorite"],
      });
      notifyListeners();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await FirebaseFirestore.instance.doc('$itemsPath/$itemId').delete();
      final ref = FirebaseStorage.instance
          .ref()
          .child('Item_images')
          .child(getCurrentUser.uid)
          .child(itemId);
      final itemImages = await ref.listAll();

      for (var itemImageRef in itemImages.items) {
        await itemImageRef.delete();
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editItem({
    required Item item,
    required String name,
    required String itemDescription,
    required String currentLocation,
    required String categoryId,
    File? currentLocationImage,
  }) async {
    final _currentTimestamp = Timestamp.now();
    try {
      if (currentLocationImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('Item_images')
            .child(getCurrentUser.uid)
            .child(item.id)
            .child("${item.currentLocation.id}.jpg");

        String imageUrl = '';
        final UploadTask storageUploadTask = ref.putFile(currentLocationImage);
        await storageUploadTask.whenComplete(() async {
          imageUrl = await ref.getDownloadURL();
        });

        await FirebaseFirestore.instance.doc("$itemsPath/${item.id}").update({
          "name": name.toCapitalized(),
          "description": itemDescription,
          "categoryId": categoryId,
          "updatedAt": _currentTimestamp,
          "currentLocation.imageUrl": imageUrl,
          "currentLocation.updatedAt": _currentTimestamp,
          "currentLocation.location": currentLocation,
        });
      } else {
        await FirebaseFirestore.instance.doc("$itemsPath/${item.id}").update({
          "name": name.toCapitalized(),
          "description": itemDescription,
          "categoryId": categoryId,
          "updatedAt": _currentTimestamp,
          "currentLocation.updatedAt": _currentTimestamp,
          "currentLocation.location": currentLocation,
        });
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addLocation({
    required Item item,
    required String newLocation,
    required File newLocationImage,
  }) async {
    final _currentTimestamp = Timestamp.now();
    final uniqueId = Uuid().v4();
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('Item_images')
          .child(getCurrentUser.uid)
          .child(item.id)
          .child("$uniqueId.jpg");

      String imageUrl = '';
      final UploadTask storageUploadTask = ref.putFile(newLocationImage);
      await storageUploadTask.whenComplete(() async {
        imageUrl = await ref.getDownloadURL();
      });

      await FirebaseFirestore.instance.doc("$itemsPath/${item.id}").update({
        "updatedAt": _currentTimestamp,
        "currentLocation": {
          "id": uniqueId,
          "imageUrl": imageUrl,
          "location": newLocation,
          "createdAt": _currentTimestamp,
          "updatedAt": _currentTimestamp,
        },
        "previousLocations": FieldValue.arrayUnion([
          {
            "id": item.currentLocation.id,
            "location": item.currentLocation.location,
            "imageUrl": item.currentLocation.imageUrl,
            "createdAt": item.currentLocation.createdAt,
            "updatedAt": item.currentLocation.updatedAt,
          },
        ])
      });
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> restorePreviousLocation({
    required String itemId,
    required String previousLocationId,
  }) async {
    try {
      final item =
          await FirebaseFirestore.instance.doc("$itemsPath/${itemId}").get();

      var previousLocation;
      final List<dynamic> updatedPreviousLocations =
          item.data()!["previousLocations"];
      updatedPreviousLocations.removeWhere(
        (prevLoc) {
          bool isPrevLoc = previousLocationId == prevLoc["id"];
          if (isPrevLoc) previousLocation = prevLoc;
          return isPrevLoc;
        },
      );
      updatedPreviousLocations.add(item.data()!["currentLocation"]);

      await item.reference.update({
        "previousLocations": updatedPreviousLocations,
        "updatedAt": Timestamp.now(),
        "currentLocation": previousLocation,
      });
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  final _googleSignIn = GoogleSignIn();

  Future<void> googleLogin() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      final _googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: _googleAuth.accessToken,
        idToken: _googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}
