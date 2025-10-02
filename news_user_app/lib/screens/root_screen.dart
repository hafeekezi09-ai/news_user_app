// lib/screens/root_screen.dart
import 'package:flutter/material.dart';
import 'package:news_user_app/screens/newspaper_screens.dart';

import 'explore_screen.dart';
import 'categories_screen.dart';
import 'magazines_screen.dart';

import 'articles_screen.dart';
import 'search_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  // Keep pages alive (state preserved when switching tabs)
  final List<Widget> _pages = const [
    ExploreScreen(),     // Home
    CategoriesScreen(),  // All categories
    MagazinesScreen(),   // Premium magazines (glossy grid)
    NewspapersScreen(),  // Daily newspapers (simple list)
    ArticlesScreen(),    // Articles feed (blog-style)
    SearchScreen(),      // Search
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Magazines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Newspapers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}
