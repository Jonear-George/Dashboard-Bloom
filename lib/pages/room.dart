import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Room extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Room').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<DataRow> roomRows =
              snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return DataRow(
              cells: [
                DataCell(Text(data['name'].toString())),
                DataCell(Text(data['price'].toString())),
                DataCell(Text(data['desc'].toString())),
                DataCell(Text(data['adult'].toString())),
                DataCell(Text(data['children'].toString())),
                DataCell(
                  // Assuming 'img' contains a URL to the image
                  Image.network(
                    data['img'].toString(),
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            );
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Adult')),
                  DataColumn(label: Text('Children')),
                  DataColumn(label: Text('Image')),
                ],
                rows: roomRows,
              ),
            ),
          );
        },
      ),
    );
  }
}
