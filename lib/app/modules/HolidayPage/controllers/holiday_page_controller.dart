import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_application/app/modules/HolidayPage/model/holiday_model.dart';
import 'package:hr_application/utils/helper_function.dart';

class HolidayPageController extends GetxController {
  var allHolidays = <HolidayModel>[].obs;
  var isLloading = true.obs; // Using your original variable name

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    getAllHoliday();
  }

  void getAllHoliday() {
    isLloading.value = true;

    // Simulating a delay and dummy data
    Future.delayed(Duration(seconds: 2), () {
      allHolidays.value = [
        HolidayModel(
            id: "1", holidayDate: "2023-12-25T00:00:00", label: "Christmas"),
        HolidayModel(
            id: "2", holidayDate: "2024-01-01T00:00:00", label: "New Year"),
        HolidayModel(
            id: "3",
            holidayDate: "2024-07-04T00:00:00",
            label: "Independence Day"),
      ];
      isLloading.value = false;
    });
  }

  Future<void> addHoliday(DateTime? selectedDate, String? label) async {
    if (label == null || selectedDate == null) {
      showErrorSnack("Please provide a label and select a date.");
      return;
    }

    // Adding dummy holiday data
    allHolidays.add(
      HolidayModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        holidayDate: selectedDate.toIso8601String(),
        label: label,
      ),
    );
    closeDialogs();
  }

  void deleteHoliday(HolidayModel holiday) {
    allHolidays.remove(holiday);
    //showInfoSnack("Holiday '${holiday.label}' has been deleted.");
  }
}
