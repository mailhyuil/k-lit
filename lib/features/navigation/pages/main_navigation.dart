import 'package:flutter/material.dart';
import 'package:k_lit/l10n/app_localizations.dart';

import '../../auth/pages/my_page.dart';
import '../../collections/pages/collection_list_page.dart';
import '../../collections/pages/search_page.dart';

/// 메인 네비게이션 - 하단 네비게이션 바로 페이지 전환
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CollectionListPage(),
    SearchPage(),
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark),
            label: t.collections,
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: t.search),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: t.myPage),
        ],
      ),
    );
  }
}
