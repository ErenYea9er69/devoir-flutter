import 'package:flutter/material.dart';
import 'user.dart';
import 'manage_groups.dart';
import 'manage_students.dart';
import 'manage_teachers.dart';
import 'manage_absences.dart';
import 'manage_matieres.dart';
import 'moy.dart';
import 'absensetop3.dart';

class Dashboard extends StatefulWidget {
  final User? user;

  const Dashboard({super.key, this.user});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ManageGroupsScreen(),
    ManageStudentsScreen(),
    ManageTeachersScreen(),
    ManageAbsencesScreen(),
    ManageMatieresScreen(),
    moypage(),
    top3absence(),
  ];

  final List<String> _titles = const [
    "Manage Groups",
    "Student Management",
    "Manage Teachers",
    "Manage Absences",
    "Manage Matieres",
    "moy classe",
    "top 3 absenec",
  ];

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'NABEUL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Exercise for groups:\nDSI33 and DSI31',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.group_work),
              title: const Text('Manage groups'),
              selected: _selectedIndex == 0,
              onTap: () => _onSelectItem(0),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Manage students'),
              selected: _selectedIndex == 1,
              onTap: () => _onSelectItem(1),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Manage teachers'),
              selected: _selectedIndex == 2,
              onTap: () => _onSelectItem(2),
            ),
            ListTile(
              leading: const Icon(Icons.event_note),
              title: const Text('Manage absences'),
              selected: _selectedIndex == 3,
              onTap: () => _onSelectItem(3),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Manage matieres'),
              selected: _selectedIndex == 4,
              onTap: () => _onSelectItem(4),
            ),
            ListTile(
              title: const Text('moy classe'),
              selected: _selectedIndex == 5,
              onTap: () => _onSelectItem(5),
            ),
            ListTile(
              title: const Text('top 3 absenec'),
              selected: _selectedIndex == 6,
              onTap: () => _onSelectItem(6),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Close'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
