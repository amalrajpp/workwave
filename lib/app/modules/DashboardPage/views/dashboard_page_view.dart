import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:hr_application/app/routes/app_pages.dart';
import 'package:hr_application/data/controllers/app_storage_service.dart';
import 'package:hr_application/utils/theme/app_colors.dart';

class DashboardPageView extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  DashboardPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        controller: _scrollController,
        children: [
          _buildProjectSummary(size),
          _buildSectionTitle(context, 'Project Members'),
          _buildMembersList(),
        ],
      ),
    );
  }

  Widget _buildProjectSummary(Size size) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard('Tasks', 12, 'To Do', AppColors.kFoundationPurple700),
          _buildStatCard(
            'Progress',
            8,
            'In Progress',
            AppColors.kFoundationPurple700,
          ),
          _buildStatCard(
              'Completed', 5, 'Done', AppColors.kFoundationPurple700),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, String desc, Color color) {
    return Card(
      color: Color.fromARGB(255, 218, 227, 232),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 100,
        height: 130,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 18, color: color)),
            const SizedBox(height: 8),
            Text('$count',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(desc, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      padding: const EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMembersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('projects')
          .doc('0')
          .collection('members')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final members = snapshot.data?.docs ?? [];
        if (members.isEmpty) {
          return const Center(child: Text('No members found'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final memberData = members[index].data() as Map<String, dynamic>;
            return _buildMemberCard(memberData);
          },
        );
      },
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0.5,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, color: AppColors.kBlue900),
          ),
          title: Text(member['name'] ?? 'Unknown',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              '${member['role'] ?? 'Role'} - ${member['contribution'] ?? 'Contribution'}'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {
            // Navigate to member details if needed
          },
        ),
      ),
    );
  }
}
