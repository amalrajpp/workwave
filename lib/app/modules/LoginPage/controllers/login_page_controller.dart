import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_application/app/routes/app_pages.dart';
import 'package:hr_application/utils/app_extension.dart';
import 'package:hr_application/utils/app_images.dart';
import 'package:hr_application/utils/helper_function.dart';
import 'package:hr_application/widgets/app_textfield.dart';

import '../../../../data/controllers/app_storage_service.dart';

class LoginPageController extends GetxController {
  String get appImageLogo => AppImages.appLogo;
  var usernameTC = TextEditingController(
        text: kDebugMode ? "Jeevan@dcompany.com" : null,
      ),
      passTC = TextEditingController(
        text: kDebugMode ? "Pass@123" : null,
      );
  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void gotoSignUpPage() {
    Get.offAllNamed(Routes.SIGN_UP_PAGE);
  }

  Future<void> login() async {
    if (!isLoading.value) {
      isLoading.value = true;
      try {
        // Firebase login with email and password
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: usernameTC.text.trim(),
          password: passTC.text.trim(),
        );

        // Fetch additional user information from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          // Check if the user needs to set a new password
          if (userData['message'] == "Please set new password.") {
            showResetPasswordDialog();
          } else {
            await AppStorageController.to.login(userData);
            showSuccessSnack("User Logged.");
          }
        } else {
          showErrorSnack("User data not found.");
        }
      } on FirebaseAuthException catch (e) {
        showErrorSnack(e.message ?? "An error occurred during login.");
      } finally {
        isLoading.value = false;
      }
    }
  }

  void showResetPasswordDialog() {
    isLoading.value = false;
    String password = "", renterPassword = "";
    Get.defaultDialog(
      title: "Set New Password",
      barrierDismissible: false,
      content: Column(
        children: [
          24.height,
          AppTextField(
            hintText: "Enter new password",
            onChanged: (p) => password = p,
          ),
          24.height,
          AppTextField(
            hintText: "Re-Enter new password",
            onChanged: (p) => renterPassword = p,
          ),
          24.height,
        ],
      ),
      textCancel: "Cancel",
      onCancel: closeDialogs,
      textConfirm: "Update Password",
      onConfirm: () async {
        if (renterPassword.trim().isEmpty || password != renterPassword) {
          showErrorSnack("Please enter correct password");
          return;
        }
        try {
          // Update password in Firebase Authentication
          await _auth.currentUser?.updatePassword(renterPassword.trim());

          // Update password in Firestore if needed
          await _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .update({
            'password': renterPassword.trim(),
          });

          passTC.text = renterPassword;
          closeDialogs();
          login();
        } catch (e) {
          showErrorSnack("Failed to update password: ${e.toString()}");
        }
      },
    );
  }

  @override
  void onClose() {
    usernameTC.dispose();
    passTC.dispose();
    super.onClose();
  }
}
