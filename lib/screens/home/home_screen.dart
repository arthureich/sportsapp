import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/events/create_event_screen.dart';
import 'package:flutter_application_1/screens/teams/teams.screen.dart';
import 'home_content.dart';
import '../profile/profile_screen.dart'; 
import '../events/my_events_screen.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});
  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    TeamsScreen(),
    MyEventsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildBottomAppBar() {
    final List<String> navBarLabels = ['Início', 'Equipes', 'Meus Eventos', 'Perfil'];
    final List<String> navBarIcons = [
      'assets/icons/home.svg', 
      'assets/icons/team.svg', 
      'assets/icons/list.svg', 
      'assets/icons/profile.svg',
    ];

    return BottomAppBar(
      elevation: 8.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(index: 0, iconPath: navBarIcons[0], label: navBarLabels[0]),
            _buildBottomNavItem(index: 1, iconPath: navBarIcons[1], label: navBarLabels[1]),
            _buildCentralNavItem(),
            _buildBottomNavItem(index: 2, iconPath: navBarIcons[2], label: navBarLabels[2]),
            _buildBottomNavItem(index: 3, iconPath: navBarIcons[3], label: navBarLabels[3]),
          ],
        ),
      ),
    );
  }

  Widget _buildCentralNavItem() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateEventScreen()),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4CAF50)),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({required int index, required String iconPath, required String label}) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? const Color(0xFF4CAF50) : Colors.grey;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, colorFilter: ColorFilter.mode(color, BlendMode.srcIn), height: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}