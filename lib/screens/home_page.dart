import 'package:flutter/material.dart';
import 'package:tixly/screens/feed_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // 0 = Feed, 1 = Diario, 2 = Wallet, 3 = Profilo

  final List<Widget> _screens =  [
    FeedScreen(),
    Center(child: Text('Diario')),
    SizedBox(),
    Center(child: Text('Wallet')),
    Center(child: Text('Profilo')),
  ];

  void _onTabSelected(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        backgroundColor: Color(0xFF0A304A),
        activeColor: Colors.white,
        initialActiveIndex: _currentIndex,
        onTap: (index) {
          if(index == 2) {
            //TODO: Mostra crea post
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: [
          TabItem(icon: Icons.home, title: 'Feed'),
          TabItem(icon: Icons.book, title: 'Diary'),
          TabItem(icon: Icons.add),
          TabItem(icon: Icons.wallet, title: 'Wallet'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
      )
    );
  }
}
