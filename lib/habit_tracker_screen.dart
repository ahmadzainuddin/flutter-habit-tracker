import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_habit_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'personal_info_screen.dart';
import 'reports_screen.dart';

class HabitTrackerScreen extends StatefulWidget {
  final String username;

  const HabitTrackerScreen({super.key, required this.username});

  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  Map<String, String> selectedHabitsMap = {};
  Map<String, String> completedHabitsMap = {};
  String name = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? widget.username;
      selectedHabitsMap = Map<String, String>.from(
        jsonDecode(prefs.getString('selectedHabitsMap') ?? '{}'),
      );
      completedHabitsMap = Map<String, String>.from(
        jsonDecode(prefs.getString('completedHabitsMap') ?? '{}'),
      );
    });
  }

  Future<void> _saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedHabitsMap', jsonEncode(selectedHabitsMap));
    await prefs.setString('completedHabitsMap', jsonEncode(completedHabitsMap));
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add opacity if not included.
    }
    return Color(int.parse('0x$hexColor'));
  }

  Color _getHabitColor(String habit, Map<String, String> habitsMap) {
    String? colorHex = habitsMap[habit];
    if (colorHex != null) {
      try {
        return _getColorFromHex(colorHex);
      } catch (e) {
        print('Error parsing color for $habit: $e');
      }
    }
    return Colors.blue; // Default color in case of error.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Text(
          name.isNotEmpty ? name : 'Loading...',
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade700),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Text(
                      (name.isNotEmpty ? name.trim()[0] : 'H').toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name.isNotEmpty ? name : 'Menu',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configure'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddHabitScreen(),
                  ),
                ).then((updatedHabits) {
                  _loadUserData(); // Reload data after returning
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Personal Info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalInfoScreen(),
                  ),
                ).then((_) {
                  _loadUserData(); // Reload data after returning
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                _signOut(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'To Do 📝',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          selectedHabitsMap.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Text(
                      'Use the + button to create some habits!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: selectedHabitsMap.length,
                    itemBuilder: (context, index) {
                      String habit = selectedHabitsMap.keys.elementAt(index);
                      Color habitColor = _getHabitColor(
                        habit,
                        selectedHabitsMap,
                      );
                      return Dismissible(
                        key: Key(habit),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            String color = selectedHabitsMap.remove(habit)!;
                            completedHabitsMap[habit] = color;
                            _saveHabits();
                          });
                        },
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Swipe to Complete',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.check, color: Colors.white),
                            ],
                          ),
                        ),
                        child: _buildHabitCard(habit, habitColor),
                      );
                    },
                  ),
                ),
          const Divider(),
          const Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Done ✅🎉',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          completedHabitsMap.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Swipe right on an activity to mark as done.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: completedHabitsMap.length,
                    itemBuilder: (context, index) {
                      String habit = completedHabitsMap.keys.elementAt(index);
                      Color habitColor = _getHabitColor(
                        habit,
                        completedHabitsMap,
                      );
                      return Dismissible(
                        key: Key(habit),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          setState(() {
                            String color = completedHabitsMap.remove(habit)!;
                            selectedHabitsMap[habit] = color;
                            _saveHabits();
                          });
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: const Row(
                            children: [
                              Icon(Icons.undo, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Swipe to Undo',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        child: _buildHabitCard(
                          habit,
                          habitColor,
                          isCompleted: true,
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      floatingActionButton: selectedHabitsMap.isEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddHabitScreen()),
                ).then((_) {
                  _loadUserData(); // Reload data after returning
                });
              },
              backgroundColor: Colors.blue.shade700,
              tooltip: 'Add Habits',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _signOut(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Widget _buildHabitCard(
    String title,
    Color color, {
    bool isCompleted = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: color,
      child: Container(
        height: 60, // Adjust the height for thicker cards.
        child: ListTile(
          title: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          trailing: isCompleted
              ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
              : null,
        ),
      ),
    );
  }
}

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'add_habit_screen.dart';
// import 'shared_preferences.dart' as habit_prefs;

// class HabitTrackerScreen extends StatefulWidget {
//   final String username;

//   const HabitTrackerScreen({super.key, required this.username});

//   @override
//   _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
// }

// class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
//   Map<String, String> selectedHabitsMap = {};
//   Map<String, String> completedHabitsMap = {};
//   String name = '';
//   List<String> recentActions = [];
//   List<String> notifications = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   void _showNotifications() async {
//     final notifs = notifications;
//     if (notifs.isEmpty) return;
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Notifications'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: ListView(
//             shrinkWrap: true,
//             children: notifs
//                 .map((n) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: Text(n),
//                     ))
//                 .toList(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               await habit_prefs.HabitPrefs.clearNotifications();
//               Navigator.of(context).pop();
//               _loadUserData();
//             },
//             child: const Text('Clear All'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _loadUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final loadedActions = await habit_prefs.HabitPrefs.getUserActions();
//     final loadedNotifs = await habit_prefs.HabitPrefs.getNotifications();
//     setState(() {
//       name = prefs.getString('name') ?? widget.username;
//       selectedHabitsMap = Map<String, String>.from(
//         jsonDecode(prefs.getString('selectedHabitsMap') ?? '{}'),
//       );
//       completedHabitsMap = Map<String, String>.from(
//         jsonDecode(prefs.getString('completedHabitsMap') ?? '{}'),
//       );
//       recentActions = loadedActions;
//       notifications = loadedNotifs;
//     });
//   }

//   Future<void> _saveHabits() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selectedHabitsMap', jsonEncode(selectedHabitsMap));
//     await prefs.setString('completedHabitsMap', jsonEncode(completedHabitsMap));
//   }

//   Color _getColorFromHex(String hexColor) {
//     hexColor = hexColor.replaceAll('#', '');
//     if (hexColor.length == 6) {
//       hexColor = 'FF$hexColor'; // Add opacity if not included.
//     }
//     return Color(int.parse('0x$hexColor'));
//   }

//   Color _getHabitColor(String habit, Map<String, String> habitsMap) {
//     String? colorHex = habitsMap[habit];
//     if (colorHex != null) {
//       try {
//         return _getColorFromHex(colorHex);
//       } catch (e) {
//         print('Error parsing color for $habit: $e');
//       }
//     }
//     return Colors.blue; // Default color in case of error.
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue.shade700,
//         title: Text(
//           name.isNotEmpty ? name : 'Loading...',
//           style: const TextStyle(
//             fontSize: 24,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         automaticallyImplyLeading: true,
//       ),
//       body: Column(
//         children: [
//           if (notifications.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Card(
//                 child: ListTile(
//                   leading: const Icon(Icons.notifications),
//                   title: Text('Notifications (' + notifications.length.toString() + ')'),
//                   trailing: TextButton(
//                     onPressed: _showNotifications,
//                     child: const Text('View'),
//                   ),
//                 ),
//               ),
//             ),
//           if (recentActions.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Recent Actions', style: TextStyle(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 6),
//                       ...recentActions.reversed.take(3).map((e) => Text('• ' + e)).toList(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text(
//               'To Do 📝',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//           selectedHabitsMap.isEmpty
//               ? const Expanded(
//                   child: Center(
//                     child: Text(
//                       'Use the + button to create some habits!',
//                       style: TextStyle(fontSize: 18, color: Colors.grey),
//                     ),
//                   ),
//                 )
//               : Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16.0),
//                     itemCount: selectedHabitsMap.length,
//                     itemBuilder: (context, index) {
//                       String habit = selectedHabitsMap.keys.elementAt(index);
//                       Color habitColor = _getHabitColor(
//                         habit,
//                         selectedHabitsMap,
//                       );
//                       return Dismissible(
//                         key: Key(habit),
//                         direction: DismissDirection.endToStart,
//                         onDismissed: (direction) {
//                           setState(() {
//                             String color = selectedHabitsMap.remove(habit)!;
//                             completedHabitsMap[habit] = color;
//                             _saveHabits();
//                           });
//                           habit_prefs.HabitPrefs.saveUserAction('Completed: ' + habit);
//                           habit_prefs.HabitPrefs.addNotification('You completed ' + habit);
//                           _loadUserData();
//                         },
//                         background: Container(
//                           color: Colors.green,
//                           alignment: Alignment.centerRight,
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Text(
//                                 'Swipe to Complete',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                               SizedBox(width: 10),
//                               Icon(Icons.check, color: Colors.white),
//                             ],
//                           ),
//                         ),
//                         child: _buildHabitCard(habit, habitColor),
//                       );
//                     },
//                   ),
//                 ),
//           Divider(),
//           const Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               'Done ✅🎉',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//           completedHabitsMap.isEmpty
//               ? const Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Text(
//                     'Swipe right on an activity to mark as done.',
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                 )
//               : Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16.0),
//                     itemCount: completedHabitsMap.length,
//                     itemBuilder: (context, index) {
//                       String habit = completedHabitsMap.keys.elementAt(index);
//                       Color habitColor = _getHabitColor(
//                         habit,
//                         completedHabitsMap,
//                       );
//                       return Dismissible(
//                         key: Key(habit),
//                         direction: DismissDirection.startToEnd,
//                         onDismissed: (direction) {
//                           setState(() {
//                             String color = completedHabitsMap.remove(habit)!;
//                             selectedHabitsMap[habit] = color;
//                             _saveHabits();
//                           });
//                           habit_prefs.HabitPrefs.saveUserAction('Restored: ' + habit);
//                           _loadUserData();
//                         },
//                         background: Container(
//                           color: Colors.red,
//                           alignment: Alignment.centerLeft,
//                           padding: EdgeInsets.symmetric(horizontal: 20),
//                           child: const Row(
//                             children: [
//                               Icon(Icons.undo, color: Colors.white),
//                               SizedBox(width: 10),
//                               Text(
//                                 'Swipe to Undo',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ],
//                           ),
//                         ),
//                         child: _buildHabitCard(
//                           habit,
//                           habitColor,
//                           isCompleted: true,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//         ],
//       ),
//       floatingActionButton: selectedHabitsMap.isEmpty
//           ? FloatingActionButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => AddHabitScreen()),
//                 ).then((_) {
//                   _loadUserData(); // Reload data after returning
//                 });
//               },
//               child: Icon(Icons.add),
//               backgroundColor: Colors.blue.shade700,
//               tooltip: 'Add Habits',
//             )
//           : null,
//     );
//   }

//   Widget _buildHabitCard(
//     String title,
//     Color color, {
//     bool isCompleted = false,
//   }) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       color: color,
//       child: Container(
//         height: 60, // Adjust the height for thicker cards.
//         child: ListTile(
//           title: Text(
//             title.toUpperCase(),
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           trailing: isCompleted
//               ? Icon(Icons.check_circle, color: Colors.green, size: 28)
//               : null,
//         ),
//       ),
//     );
//   }
// }
