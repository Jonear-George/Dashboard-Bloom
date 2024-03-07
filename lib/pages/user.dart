// ignore_for_file: use_key_in_widget_constructors, use_super_parameters, prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  runApp(UserApp());
}

class UserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management App',
      home: UsersScreen(),
    );
  }
}

class UserDialog extends StatelessWidget {
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? userPhoneNumber;

  const UserDialog({
    Key? key,
    this.userId,
    this.userName,
    this.userEmail,
    this.userPhoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: userName ?? '');
    TextEditingController emailController = TextEditingController(text: userEmail ?? '');
    TextEditingController phoneNumberController = TextEditingController(text: userPhoneNumber ?? '');
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    bool _passwordsMatch() {
      return passwordController.text.trim() == confirmPasswordController.text.trim();
    }

    return AlertDialog(
      title: Text(userId != null ? 'Edit User' : 'Add User'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            if (userId == null) ...[
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                validator: (value) {
                  if (!_passwordsMatch()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            String name = nameController.text.trim();
            String email = emailController.text.trim();
            String phoneNumber = phoneNumberController.text.trim();
            String password = passwordController.text.trim();

            if (userId != null) {
              await FirebaseFirestore.instance.collection('Users').doc(userId).update({
                'name': name,
                'email': email,
                'phoneNumber': phoneNumber,
              });
            } else {
              if (_passwordsMatch()) {
                await FirebaseFirestore.instance.collection('Users').add({
                  'name': name,
                  'email': email,
                  'phoneNumber': phoneNumber,
                  'password': password, // Save password to Firestore
                });
              } else {
                // Show error if passwords don't match
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
                return; // Exit function if passwords don't match
              }
            }

            Navigator.of(context).pop();
          },
          child: Text(userId != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _usersStream = FirebaseFirestore.instance.collection('Users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return UserDialog();
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _usersStream = FirebaseFirestore.instance
                      .collection('Users')
                      .where('name', isGreaterThanOrEqualTo: value)
                      .where('name', isLessThan: '${value}z')
                      .snapshots();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No users found.'),
                  );
                }

                List<DataRow> rows = snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  String id = document.id;

                  return DataRow(cells: [
                    DataCell(Text(id)), // Display ID in the DataTable
                    DataCell(Text(data['name'] ?? '')),
                    DataCell(Text(data['email'] ?? '')),
                    DataCell(Text(data['phoneNumber'] ?? '')),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return UserDialog(
                                    userId: id,
                                    userName: data['name'],
                                    userEmail: data['email'],
                                    userPhoneNumber: data['phoneNumber'],
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete User'),
                                    content: Text('Are you sure you want to delete this user?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance.collection('Users').doc(id).delete();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(label: Text('ID')), // ID Column added
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Phone Number')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: rows,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
