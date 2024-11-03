import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HolidayPageView extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            _firestore.collection('users').doc(_auth.currentUser!.uid).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(child: Text("Error fetching user data"));
          }
          if (!userSnapshot.hasData || userSnapshot.data!.data() == null) {
            return Center(child: Text("User not found"));
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final userRole = userData['roleType'] ?? '';

          if (userRole != 'manager') {
            return Center(child: Text("No access"));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("No employees found"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data!.docs[index].data()
                      as Map<String, dynamic>?;
                  // Ensure `data` is valid
                  if (data == null) {
                    return SizedBox.shrink();
                  }

                  return EmployeeCard(
                    name: data['fullName'] ??
                        'Unknown', // Default to 'Unknown' if name is missing
                    role: data['roleType'] ?? 'Not specified',
                    workedHours: data['worked_hours'] ??
                        0, // Default to 0 if hours are missing
                    leaves: data['leaves'] ??
                        0, // Default to 0 if leaves are missing
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final String name;
  final String role;
  final int workedHours;
  final int leaves;

  const EmployeeCard({
    Key? key,
    required this.name,
    required this.role,
    required this.workedHours,
    required this.leaves,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.work, color: Colors.blueAccent),
                const SizedBox(width: 6),
                Text('Role: $role'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.green),
                const SizedBox(width: 6),
                Text('Worked Hours: $workedHours'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.event_busy, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text('Leaves Taken: $leaves'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
