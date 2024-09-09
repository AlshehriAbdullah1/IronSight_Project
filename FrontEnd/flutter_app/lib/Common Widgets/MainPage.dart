import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iron_sight/features/community_managment/views/communitiesView.dart';
import 'package:iron_sight/features/game_managment/views/games_page_view.dart';
import 'package:iron_sight/features/search_managment/Views/searchView.dart';
import 'package:iron_sight/features/tournament_managment/views/tournament_list_view.dart';
import 'package:iron_sight/features/user_managment/views/profile_page_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 3;
  final List<Widget> _children = [
    // SearchView(),
    CommunityListView(),
    GameView(),
    TournamentListView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _children[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Colors.transparent, // sets the color to transparent
        ),
        child: BottomNavigationBar(
          unselectedItemColor:
              Colors.white, // sets the color of the unselected items
          selectedItemColor: Colors.white,
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: 
          const <BottomNavigationBarItem>[
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.search),
            //   label: 'Search',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Communities',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.gamepad),
              label: 'Games',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_rounded),
              label: 'Tournaments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
