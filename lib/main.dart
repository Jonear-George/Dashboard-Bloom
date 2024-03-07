// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:bloom/auth/login.dart';
import 'package:bloom/pages/bookings.dart';
import 'package:bloom/pages/dashboard.dart';
import 'package:bloom/pages/employee.dart';
import 'package:bloom/pages/room.dart';
import 'package:bloom/pages/user.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCVEQkI0_7xcZY9DjkvNr0NErtZ0Ktoi8Y",
      databaseURL:
          "https://bloom-hotel-f4c79-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "bloom-hotel-f4c79",
      messagingSenderId: "57826761431",
      appId: "1:57826761431:web:ab66852aec5bf070bd2e92",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SideNavBar(),
      theme: ThemeData(
        primaryColor: Colors.purple,
        hintColor: Colors.green,
      ),
    );
  }
}

class SideNavBar extends StatefulWidget {
  @override
  _SideNavBarState createState() => _SideNavBarState();
}

class _SideNavBarState extends State<SideNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    UsersScreen(),
    EmployeeApp(),
    BookingsScreen(),
    Room(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth * 0.15;
        return Center(
          child: Scaffold(
            body: Row(
              children: <Widget>[
                Container(
                  width: maxWidth,
                  color: Colors.orange,
                  child: Drawer(
                    backgroundColor: Colors.purple,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                child: Center(
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/Bloom.jpg',
                                      fit: BoxFit.cover,
                                      height: 130,
                                      width: 130,
                                    ),
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Center(
                                  child: Text(
                                    'Dashboard',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _onItemTapped(0);
                                },
                              ),
                              Divider(
                                color: Colors.red,
                              ),
                              ListTile(
                                title: Center(
                                  child: Text(
                                    'Users',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _onItemTapped(1);
                                },
                              ),
                              ListTile(
                                title: Center(
                                  child: Text(
                                    'Admin',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _onItemTapped(2);
                                },
                              ),
                              ListTile(
                                title: Center(
                                  child: Text(
                                    'Bookings',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _onItemTapped(3);
                                },
                              ),
                              Divider(
                                color: Colors.red,
                              ),
                              ListTile(
                                title: Center(
                                  child: Text(
                                    'Room',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _onItemTapped(4);
                                },
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: Center(
                            child: Icon(
                              Icons.logout,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            _logout(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                  thickness: 1,
                  width: 1,
                ),
                Expanded(
                  child: _widgetOptions.elementAt(_selectedIndex),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
