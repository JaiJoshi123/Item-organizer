import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/db_helper.dart';

import '../widgets/items_list.dart';
import './item_details_screen.dart';
import './search_screen.dart';

class FavoriteItemsScreen extends StatelessWidget {
  static const routeName = "/favorites";

  @override
  Widget build(BuildContext context) {
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
              content: Text("${value} was deleted successfully."),
            ),
          );
        }
      });
    }

    return StreamBuilder<List<Item>>(
      stream: Provider.of<DBHelper>(context, listen: false)
          .getFavoriteItemsStream(),
      builder: (ctx, favoriteItemsSnapshot) {
        if (favoriteItemsSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Favorite Items"),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.black,
            ),
            body: LinearProgressIndicator(
              color: Colors.black,
              backgroundColor: Colors.white,
            ),
          );
        } else if (favoriteItemsSnapshot.hasData) {
          final favoriteItems = favoriteItemsSnapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text("Favorite Items"),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.black,
              actions: [
                IconButton(
                  tooltip: "Search",
                  onPressed: favoriteItems == null
                      ? null
                      : () {
                          showSearch<String?>(
                            context: context,
                            delegate: SearchItems(items: favoriteItems),
                          ).then((itemId) {
                            if (itemId == null) return;
                            _openItemDetailsScreen(itemId);
                          }).onError((error, stackTrace) {
                            print(error);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Some error occured!")));
                          });
                        },
                  icon: Icon(Icons.search),
                ),
              ],
            ),
            body: ItemsList(
              items: favoriteItems,
              onListTap: _openItemDetailsScreen,
            ),
          );
        }
        print(favoriteItemsSnapshot.error);
        return Center(
          child: Icon(Icons.error),
        );
      },
    );
  }
}
