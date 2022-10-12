import 'package:flutter/material.dart';

import '../widgets/items_list.dart';

import '../helpers/db_helper.dart';

class SearchItems extends SearchDelegate<String?> {
  List<Item> items;
  late List<Item> _searchResults;

  SearchItems({required this.items});

  @override
  String get searchFieldLabel => "Search for any item";

  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        color: Colors.black,
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      color: Colors.black,
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    // List<Item> _searchResults = items
    //     .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
    //     .toList();

    return ItemsList(
      items: _searchResults,
      onListTap: (String itemId) {
        close(context, itemId);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    _searchResults = items
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ItemsList(
      items: _searchResults,
      onListTap: (String itemId) {
        close(context, itemId);
      },
    );
  }
}
