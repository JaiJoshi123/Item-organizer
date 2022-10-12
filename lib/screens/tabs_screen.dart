import 'package:flutter/material.dart';

import '../screens/item_category_screen.dart';
import '../screens/user_account_screen.dart';
import '../screens/favorite_items.dart';
import '../screens/settings_screen.dart';

import '../helpers/tab_navigator.dart';
import '../helpers/db_helper.dart';

class TabsScreen extends StatefulWidget {
  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<TabNavigator>? _pages;
  int _selectedPageIndex = 0;
  Map<String, GlobalKey<NavigatorState>>? _navigatorKeys;
  PageController? pageController;

  @override
  void initState() {
    super.initState();
    _navigatorKeys = {
      ItemCategoryScreen.routeName: GlobalKey<NavigatorState>(),
      FavoriteItemsScreen.routeName: GlobalKey<NavigatorState>(),
      UserAccountScreen.routeName: GlobalKey<NavigatorState>(),
      SettingsScreen.routeName: GlobalKey<NavigatorState>(),
    };
    _pages = [
      TabNavigator(
        pageRoute: ItemCategoryScreen.routeName,
        navigatorKey: _navigatorKeys![ItemCategoryScreen.routeName]
            as GlobalKey<NavigatorState>,
      ),
      TabNavigator(
        pageRoute: FavoriteItemsScreen.routeName,
        navigatorKey: _navigatorKeys![FavoriteItemsScreen.routeName]
            as GlobalKey<NavigatorState>,
      ),
      TabNavigator(
        pageRoute: UserAccountScreen.routeName,
        navigatorKey: _navigatorKeys![UserAccountScreen.routeName]
            as GlobalKey<NavigatorState>,
      ),
      TabNavigator(
        pageRoute: SettingsScreen.routeName,
        navigatorKey: _navigatorKeys![SettingsScreen.routeName]
            as GlobalKey<NavigatorState>,
      ),
    ];
    pageController = PageController();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    pageController!.jumpToPage(_selectedPageIndex);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !await _navigatorKeys![_pages![_selectedPageIndex].pageRoute]!
              .currentState!
              .maybePop(),
      child: Scaffold(
        body: PageView(
          controller: pageController,
          children: _pages!,
          onPageChanged: _onPageChanged,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          backgroundColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.black,
          currentIndex: _selectedPageIndex,
          // showSelectedLabels: false,
          // showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border),
              activeIcon: Icon(Icons.star),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              activeIcon: Icon(Icons.account_circle),
              label: 'Account',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  // Widget _buildOffstageNavigator(String pageRoute) {
  //   return Offstage(
  //     offstage: _pages[_selectedPageIndex]["route"] != pageRoute,
  //     child: TabNavigator(
  //       navigatorKey: _navigatorKeys[pageRoute]!,
  //       pageRoute: pageRoute,
  //     ),
  //   );
  // }
}
