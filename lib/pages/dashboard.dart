import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Circular loading indicator
                } else {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    int userCount = snapshot.data?.size ?? 0; // Count of documents in 'Users' collection
                    return Column(
                      children: [
                        Text(
                          'Number of Users: $userCount',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 20),
                        // Adding a small circular chart here
                        Container(
                          width: 150,
                          height: 150,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: userCount.toDouble(),
                                  color: Colors.blue,
                                  title: 'Users',
                                  radius: 50,
                                ),
                                PieChartSectionData(
                                  value: (100 - userCount).toDouble().clamp(0.0, 100.0),
                                  color: Colors.grey,
                                  title: 'Other',
                                  radius: 50,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
