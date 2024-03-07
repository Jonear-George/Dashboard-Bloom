import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({Key? key}) : super(key: key);

  @override
  _AdminRegisterPageState createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addAdmin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        // Register email/password to Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Check if registration to Firebase Authentication was successful
        if (userCredential.user != null) {
          // If successful, also store admin details in Firestore
          await _firestore.collection('Admin').doc(email).set({
            'email': email,
            'password': password,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Admin added successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear the text fields after successful addition
          _emailController.clear();
          _passwordController.clear();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding admin: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Registration'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _addAdmin,
              child: Text('Add Admin'),
            ),
            SizedBox(height: 40.0),
            Text(
              'Registered Admins:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Admin').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                List<Widget> adminList = [];
                final admins = snapshot.data!.docs;

                for (var admin in admins) {
                  final adminEmail = admin['email'];
                  adminList.add(
                    ListTile(
                      title: Text(adminEmail),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteAdmin(adminEmail),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: adminList,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAdmin(String email) async {
    try {
      await _firestore.collection('Admin').doc(email).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Admin deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting admin: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
