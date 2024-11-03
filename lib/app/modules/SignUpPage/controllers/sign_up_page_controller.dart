import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hr_application/app/modules/SignUpPage/model/working_days_model.dart';
import 'package:hr_application/app/routes/app_pages.dart';
import 'package:hr_application/data/app_enums.dart';
import 'package:hr_application/utils/app_images.dart';
import 'package:hr_application/utils/helper_function.dart';

class SignUpPageController extends GetxController {
  String get appImageLogo => AppImages.appLogo;
  var usernameTC = TextEditingController(
        text: kDebugMode ? "jeevan@dcompany.com" : null,
      ),
      passTC = TextEditingController(
        text: kDebugMode ? "Pass@123" : null,
      ),
      fullNameTC = TextEditingController(
        text: kDebugMode ? "Jeevan" : null,
      ),
      paidLeaveTC = TextEditingController(
        text: kDebugMode ? "2" : null,
      ),
      casualSickTC = TextEditingController(
        text: kDebugMode ? "2" : null,
      ),
      wfhTC = TextEditingController(
        text: kDebugMode ? "2" : null,
      ),
      organizationTC = TextEditingController(
        text: kDebugMode ? "Dcompany" : null,
      );
  var workingDays = <WorkingDaysModel>[].obs;
  var startTime = Rxn<TimeOfDay?>(null), endTime = Rxn<TimeOfDay?>(null);

  var formKey = GlobalKey<FormState>();
  var isSaveLoading = false.obs;
  var selectedRole = RxnString();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    workingDays.value = <String>[
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ]
        .map(
          (e) => WorkingDaysModel(
            label: e,
            code: e.toUpperCase(),
            isSelected: kDebugMode,
          ),
        )
        .toList();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  onWorkingDaysChange(int index) {
    workingDays[index].isSelected = !workingDays[index].isSelected;
    workingDays.refresh();
  }

  void goToLoginPage() {
    Get.offAllNamed(Routes.LOGIN_PAGE);
  }

  Future<void> signUp() async {
    if ((formKey.currentState?.validate() ?? false) && !isSaveLoading.value) {
      if (startTime.value == null ||
          endTime.value == null ||
          workingDays.value.where((element) => element.isSelected).isEmpty) {
        showErrorSnack("Select Start and End Time and working days");
        return;
      }

      isSaveLoading.value = true;
      try {
        // Firebase Authentication - Create user with email and password
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: usernameTC.text.trim(),
          password: passTC.text,
        );

        // Prepare user data to be stored in Firestore
        List<WorkingDaysModel> tempWorkingDays = List.from(workingDays.value);
        tempWorkingDays.removeWhere((element) => !element.isSelected);

        Map<String, dynamic> payload = {
          "username": usernameTC.text.trim(),
          "fullName": fullNameTC.text,
          "roleType": selectedRole.value,
          "companyName": organizationTC.text,
          "inTime":
              startTime.value != null ? formatTimeOfDay(startTime.value!) : '',
          "outTime":
              endTime.value != null ? formatTimeOfDay(endTime.value!) : '',
          "workingDays": tempWorkingDays.map((e) => e.code).toList(),
          "perMonthPL": num.tryParse(paidLeaveTC.text.trim()),
          "perMonthSLCL": num.tryParse(casualSickTC.text.trim()),
          "perMonthWFH": num.tryParse(wfhTC.text.trim()),
        };

        // Store additional user data in Firestore
        await _firestore
            .collection("users")
            .doc(userCredential.user?.uid)
            .set(payload);

        showSuccessSnack("User signed up and logged in.");
        Get.toNamed(Routes.LOGIN_PAGE);
      } on FirebaseAuthException catch (e) {
        showErrorSnack(e.message ?? "An error occurred during sign-up.");
      } catch (e) {
        showErrorSnack("An unexpected error occurred.");
      } finally {
        isSaveLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    usernameTC.dispose();
    passTC.dispose();
    fullNameTC.dispose();
    organizationTC.dispose();
    paidLeaveTC.dispose();
    casualSickTC.dispose();
    wfhTC.dispose();
    super.onClose();
  }
}
