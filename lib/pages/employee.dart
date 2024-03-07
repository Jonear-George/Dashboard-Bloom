import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  runApp(EmployeeApp());
}

class EmployeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Management App',
      home: Adminscreen(),
    );
  }
}

class EmployeeDialog extends StatelessWidget {
  final String? employeeId;
  final String? employeeName;
  final String? employeeEmail;
  final String? employeePhoneNumber;

  const EmployeeDialog({
    Key? key,
    this.employeeId,
    this.employeeName,
    this.employeeEmail,
    this.employeePhoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: employeeName ?? '');
    TextEditingController emailController = TextEditingController(text: employeeEmail ?? '');
    TextEditingController phoneNumberController = TextEditingController(text: employeePhoneNumber ?? '');
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    return AlertDialog(
      title: Text(employeeId != null ? 'Edit Employee' : 'Add Employee'),
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
            if (employeeId == null) ...[
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
                  if (value != passwordController.text) {
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

            if (employeeId != null) {
              await FirebaseFirestore.instance.collection('Admin').doc(employeeId).update({
                'name': name,
                'email': email,
                'phoneNumber': phoneNumber,
              });
            } else {
              if (passwordController.text.trim() == confirmPasswordController.text.trim()) {
                await FirebaseFirestore.instance.collection('Admin').add({
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
          child: Text(employeeId != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
class Adminscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Admin').snapshots(),
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
              child: Text('No Admin found.'),
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
                            return EmployeeDialog(
                              employeeId: id,
                              employeeName: data['name'],
                              employeeEmail: data['email'],
                              employeePhoneNumber: data['phoneNumber'],
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
                              title: Text('Delete Employee'),
                              content: Text('Are you sure you want to delete this employee?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance.collection('Admin').doc(id).delete();
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
            scrollDirection: Axis.vertical,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Phone Number')),
                DataColumn(label: Text('Actions')),
              ],
              rows: rows,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return EmployeeDialog();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
