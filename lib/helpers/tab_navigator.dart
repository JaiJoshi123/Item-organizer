import 'package:flutter/material.dart';

import '../screens/item_category_screen.dart';
import '../screens/user_account_screen.dart';
import '../screens/favorite_items.dart';
import '../screens/settings_screen.dart';

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String pageRoute;

  TabNavigator({required this.navigatorKey, required this.pageRoute});

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (pageRoute) {
      case ItemCategoryScreen.routeName:
        child = ItemCategoryScreen();
        break;
      case UserAccountScreen.routeName:
        child = UserAccountScreen();
        break;
      case FavoriteItemsScreen.routeName:
        child = FavoriteItemsScreen();
        break;
      case SettingsScreen.routeName:
        child = SettingsScreen();
        break;
      default:
        child = ItemCategoryScreen();
        break;
    }
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
