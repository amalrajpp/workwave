import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hr_application/utils/app_extension.dart';
import 'package:intl/intl.dart';

import '../../../../utils/theme/app_colors.dart';

class AttendanceButton extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceButton> {
  bool isCheckedIn = false;
  Timestamp? checkInTime;
  String totalHoursDisplay = "0 hrs 0 min 0 sec";
  String checkInTimeDisplay = "-- --";
  String checkOutTimeDisplay = "-- --";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadTotalHoursForToday();
  }

  Future<void> _loadTotalHoursForToday() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final now = DateTime.now();
    final startOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

    try {
      // Fetch all attendance records for the current day
      final recordsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendanceRecords')
          .where('checkIn', isGreaterThanOrEqualTo: startOfDay)
          .where('checkIn', isLessThanOrEqualTo: endOfDay)
          .get();

      // Sum the total hours for all records of the day
      double totalSeconds = 0.0;
      for (var record in recordsSnapshot.docs) {
        final sessionHours =
            (record['totalHours'] ?? 0.0) * 3600; // Convert hours to seconds
        totalSeconds += sessionHours;
      }

      setState(() {
        totalHoursDisplay = _formatDuration(totalSeconds);
      });
    } catch (e) {
      print('Error loading total hours for today: $e');
    }
  }

  String _formatDuration(double? totalSeconds) {
    if (totalSeconds == null || totalSeconds == 0.0) return "0 hrs 0 min 0 sec";

    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = (totalSeconds % 60).toInt();

    return "$hours hrs $minutes min $seconds sec";
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "N/A";
    final date = timestamp.toDate();
    return DateFormat('hh:mm:ss a').format(date);
  }

  void toggleCheckInOut() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final now = Timestamp.now();

    try {
      if (!isCheckedIn) {
        // Check-In
        setState(() {
          isCheckedIn = true;
          checkInTime = now;
          checkInTimeDisplay = _formatTimestamp(now);
        });

        // Add a new check-in record to Firestore
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('attendanceRecords')
            .add({
          'checkIn': now,
          'checkOut': null,
          'totalHours': null,
        });
      } else {
        // Check-Out
        final checkOutTime = now;
        setState(() {
          isCheckedIn = false;
          checkOutTimeDisplay = _formatTimestamp(now);
        });

        // Calculate total hours for this session in seconds
        final hoursWorked = checkOutTime.seconds - (checkInTime?.seconds ?? 0);
        final sessionHours = hoursWorked / 3600;

        // Update the last record with check-out time and session hours
        final recordSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('attendanceRecords')
            .orderBy('checkIn', descending: true)
            .limit(1)
            .get();

        if (recordSnapshot.docs.isNotEmpty) {
          final docId = recordSnapshot.docs.first.id;
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('attendanceRecords')
              .doc(docId)
              .update({
            'checkOut': checkOutTime,
            'totalHours': sessionHours,
          });

          // Reload total hours for today to include the new session
          _loadTotalHoursForToday();
        }
      }
    } catch (e) {
      print('Error during check-in/check-out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: toggleCheckInOut,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.kFoundationPurple100,
                border: Border.all(
                  color: AppColors.kFoundationPurple200,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              width: double.infinity,
              height: 60,
              child: Center(
                  child: Text(
                isCheckedIn ? 'Check Out' : 'Check In',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
            ),
          ),
        ),
        SizedBox(height: 20),
        _buildCheckInOutCard(
          Icons.work_history_outlined,
          "Total Working Hours",
          totalHoursDisplay,
          '-',
        ),
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildCheckInOutCard(
                    Icons.input_rounded, "Check In", checkInTimeDisplay, ""),
              ),
              10.width,
              Expanded(
                child: _buildCheckInOutCard(
                  Icons.input_rounded,
                  "Check Out",
                  checkOutTimeDisplay,
                  '',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

_buildCheckInOutCard(
  IconData iconData,
  String title,
  String time,
  String description,
) {
  return DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: AppColors.kWhite,
      boxShadow: [
        BoxShadow(
          color: AppColors.kGrey300.withOpacity(.2),
          offset: const Offset(0, 4),
          blurRadius: 6,
          spreadRadius: 2,
        )
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.kFoundationPurple100,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    iconData,
                    size: 20,
                  ),
                ),
              ),
              10.width,
              Text(
                title,
                style: Get.textTheme.bodyLarge,
              )
            ],
          ),
          8.height,
          Text(
            time,
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            description,
            style: Get.textTheme.bodyLarge,
          )
        ],
      ),
    ),
  );
}
