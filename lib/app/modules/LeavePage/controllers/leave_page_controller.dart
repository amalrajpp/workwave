import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_application/app/models/teams_model.dart';
import 'package:hr_application/app/modules/LeavePage/model/leave_activity_model.dart';

class LeavePageController extends GetxController {
  var tabSelected = Rxn(LeaveActivityState.pending);
  var leaveActivities = <LeaveActivityModel>[].obs;
  var mainList = <LeaveActivityModel>[];
  var leavereasonTC = TextEditingController();
  var leaveStartDate = Rxn<DateTime?>(), leaveEndDate = Rxn<DateTime?>();
  var totalCount = {}.obs;
  var myData = false.obs;
  var isTeamLoading = true.obs;
  var teams = <TeamsModel>[];
  TeamsModel? selectedTeam;

  @override
  void onReady() {
    super.onReady();
    getAllLeaves();
    fetchAllTeams();
  }

  void onTabChange(LeaveActivityState newState) {
    leaveActivities.clear();
    leaveActivities
        .addAll(mainList.where((element) => element.leaveStatus == newState));
    tabSelected.value = newState;
  }

  void fetchAllTeams() {
    isTeamLoading.value = true;
    teams.clear();
    teams.addAll([
      TeamsModel(id: '1', teamName: 'Team A', createdAt: '2023-01-01'),
      TeamsModel(id: '2', teamName: 'Team B', createdAt: '2023-01-02'),
    ]);
    if (teams.isNotEmpty) {
      selectedTeam = teams.first;
    }
    isTeamLoading.value = false;
  }

  void getAllLeaves() {
    leaveActivities.clear();
    mainList.clear();

    // Dummy Data
    totalCount.value = {
      "paidLeaveBalance": 10,
      "totalWFHbalance": 5,
      "casualAndSickLeaveBalance": 8,
    };

    mainList.addAll([
      LeaveActivityModel(
          id: '1', leaveStatus: LeaveActivityState.pending, user: null),
      LeaveActivityModel(
          id: '2', leaveStatus: LeaveActivityState.approved, user: null),
      LeaveActivityModel(
          id: '3', leaveStatus: LeaveActivityState.rejected, user: null),
    ]);

    onTabChange(LeaveActivityState.pending);
  }

  @override
  void onClose() {
    leavereasonTC.dispose();
    super.onClose();
  }

  void myDataChanged(bool value) {
    myData.value = value;
    getAllLeaves();
  }

  Future<void> handleApproveRejectTap(
    LeaveActivityState status,
    LeaveActivityModel item,
  ) async {
    if (status == LeaveActivityState.rejected) {
      String rejectReason = "";
      Get.defaultDialog<void>(
        title: "Reject",
        content: TextField(
          decoration: InputDecoration(hintText: "Enter reject reason"),
          onChanged: (a) => rejectReason = a,
        ),
        textCancel: "Cancel",
        textConfirm: "Update",
        onCancel: Get.back,
        onConfirm: () {
          if (rejectReason.trim().isEmpty) {
            Get.snackbar("Error", "Enter reject reason");
            return;
          }
          Get.back();
          updateLeave(status: status, item: item, rejectReason: rejectReason);
        },
      );
    } else {
      updateLeave(status: status, item: item);
    }
  }

  void updateLeave({
    required LeaveActivityState status,
    required LeaveActivityModel item,
    String? rejectReason,
  }) {
    // Update dummy data here, no API call
    mainList = mainList.map((leave) {
      if (leave.id == item.id) {
        leave.leaveStatus = status;
      }
      return leave;
    }).toList();
    onTabChange(tabSelected.value!);
  }
}
