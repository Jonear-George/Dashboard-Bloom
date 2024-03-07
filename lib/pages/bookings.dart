// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(BookingsApp());
}

class BookingsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking App',
      home: BookingsScreen(),
    );
  }
}

class BookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final bookings = snapshot.data?.docs ?? [];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 10.0,
                  columns: [
                    DataColumn(label: Text('Booking ID')),
                    DataColumn(label: Text('Room Name')),
                    DataColumn(label: Text('Check-In')),
                    DataColumn(label: Text('Check-Out')),
                    DataColumn(label: Text('Adults')),
                    DataColumn(label: Text('Children')),
                    DataColumn(label: Text('Total Price')),
                    DataColumn(label: Text('Username')), // Changed 'userId' to 'Username'
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: bookings.map((booking) {
                    String bookingId = booking.id;
                    String roomName = booking['roomName'] ?? 'N/A';
                    String checkInDate = booking['checkInDate'] ?? 'N/A';
                    String checkOutDate = booking['checkOutDate'] ?? 'N/A';
                    int adults = booking['adults'] ?? 0;
                    int children = booking['children'] ?? 0;
                    String totalPrice = booking['totalPrice'] ?? 'N/A';
                    String username = booking['username'] ?? 'N/A'; // Changed 'userId' to 'username'

                    return DataRow(cells: [
                      DataCell(Text(bookingId)),
                      DataCell(Text(roomName)),
                      DataCell(Text(checkInDate)),
                      DataCell(Text(checkOutDate)),
                      DataCell(Text(adults.toString())),
                      DataCell(Text(children.toString())),
                      DataCell(Text(totalPrice)),
                      DataCell(Text(username)), // Changed 'userId' to 'username'
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editBooking(context, bookingId, roomName, checkInDate, checkOutDate, adults, children, totalPrice, username);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteBooking(context, bookingId);
                            },
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addBooking(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addBooking(BuildContext context) {
    String roomName = '';
    String checkInDate = '';
    String checkOutDate = '';
    int adults = 0;
    int children = 0;
    String totalPrice = '';
    String username = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Booking'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Room Name'),
                  onChanged: (value) {
                    roomName = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Check-In Date'),
                  onChanged: (value) {
                    checkInDate = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Check-Out Date'),
                  onChanged: (value) {
                    checkOutDate = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Adults'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    adults = int.tryParse(value) ?? 0;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Children'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    children = int.tryParse(value) ?? 0;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Total Price'),
                  onChanged: (value) {
                    totalPrice = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Username'),
                  onChanged: (value) {
                    username = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('bookings').add({
                  'roomName': roomName,
                  'checkInDate': checkInDate,
                  'checkOutDate': checkOutDate,
                  'adults': adults,
                  'children': children,
                  'totalPrice': totalPrice,
                  'username': username, // Changed 'userId' to 'username'
                });

                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _editBooking(BuildContext context, String bookingId, String roomName, String checkInDate, String checkOutDate, int adults, int children, String totalPrice, String username) {
    TextEditingController roomNameController = TextEditingController(text: roomName);
    TextEditingController checkInDateController = TextEditingController(text: checkInDate);
    TextEditingController checkOutDateController = TextEditingController(text: checkOutDate);
    TextEditingController adultsController = TextEditingController(text: adults.toString());
    TextEditingController childrenController = TextEditingController(text: children.toString());
    TextEditingController totalPriceController = TextEditingController(text: totalPrice);
    TextEditingController usernameController = TextEditingController(text: username);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Booking'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: roomNameController,
                  decoration: InputDecoration(labelText: 'Room Name'),
                ),
                TextFormField(
                  controller: checkInDateController,
                  decoration: InputDecoration(labelText: 'Check-In Date'),
                ),
                TextFormField(
                  controller: checkOutDateController,
                  decoration: InputDecoration(labelText: 'Check-Out Date'),
                ),
                TextFormField(
                  controller: adultsController,
                  decoration: InputDecoration(labelText: 'Adults'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: childrenController,
                  decoration: InputDecoration(labelText: 'Children'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: totalPriceController,
                  decoration: InputDecoration(labelText: 'Total Price'),
                ),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
                  'roomName': roomNameController.text,
                  'checkInDate': checkInDateController.text,
                  'checkOutDate': checkOutDateController.text,
                  'adults': int.tryParse(adultsController.text) ?? 0,
                  'children': int.tryParse(childrenController.text) ?? 0,
                  'totalPrice': totalPriceController.text,
                  'username': usernameController.text,
                });

                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteBooking(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Booking'),
          content: Text('Are you sure you want to delete this booking?'),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();

                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
