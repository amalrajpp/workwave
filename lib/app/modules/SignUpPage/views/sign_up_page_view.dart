import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hr_application/utils/app_extension.dart';
import 'package:hr_application/utils/helper_function.dart';
import 'package:hr_application/utils/theme/app_colors.dart';
import 'package:hr_application/utils/theme/app_theme.dart';
import 'package:hr_application/widgets/app_button.dart';
import 'package:hr_application/widgets/app_textfield.dart';

import '../controllers/sign_up_page_controller.dart';

class SignUpPageView extends GetView<SignUpPageController> {
  const SignUpPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              24.height,
              Text(
                "Register Account",
                style: Get.textTheme.headlineLarge,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "to",
                      style: Get.textTheme.headlineLarge,
                    ),
                    TextSpan(
                      text: " WorkWave",
                      style: Get.textTheme.headlineLarge?.copyWith(
                        color: AppColors.kBlue900,
                      ),
                    ),
                  ],
                ),
              ),
              16.height,
              Text(
                "Hello there, signup to continue",
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.kGrey300,
                ),
              ),
              16.height,
              AppTextField(
                hintText: "Full Name",
                controller: controller.fullNameTC,
                validator: (val) {
                  if (val?.isEmpty ?? true) {
                    return "This field can't be empty";
                  } else {
                    return null;
                  }
                },
              ),
              16.height,
              AppTextField(
                hintText: "Email",
                controller: controller.usernameTC,
                validator: (val) {
                  if (val?.isEmpty ?? true) {
                    return "This field can't be empty";
                  } else {
                    return null;
                  }
                },
              ),
              16.height,
              AppTextField(
                hintText: "Password",
                isPassword: true,
                controller: controller.passTC,
                validator: (val) {
                  if (val?.isEmpty ?? true) {
                    return "This field can't be empty";
                  } else {
                    return null;
                  }
                },
              ),
              16.height,
              Column(
                children: [
                  title("Organization Details", Icons.people_alt_outlined),
                  16.height,
                  AppTextField(
                    hintText: "Organization Name",
                    controller: controller.organizationTC,
                    validator: (val) {
                      if (val?.isEmpty ?? true) {
                        return "This field can't be empty";
                      } else {
                        return null;
                      }
                    },
                  ),
                  35.height,
                  title("Working time", Icons.lock_clock),
                  16.height,
                  Obx(() {
                    return AppButton.appOulineButtonRow(
                      onPressed: () => openTimePickerdialog(true, context),
                      label: controller.startTime.value == null
                          ? "Select start time"
                          : formatTimeOfDay(controller.startTime.value!),
                      suffixIcon: const Icon(
                        Icons.access_time_outlined,
                        color: AppColors.kBlue600,
                      ),
                    );
                  }),
                  16.height,
                  Obx(() {
                    return AppButton.appOulineButtonRow(
                      onPressed: () => openTimePickerdialog(false, context),
                      label: controller.endTime.value == null
                          ? "Select end time"
                          : formatTimeOfDay(controller.endTime.value!),
                      suffixIcon: const Icon(
                        Icons.access_time_outlined,
                        color: AppColors.kBlue600,
                      ),
                    );
                  }),
                  16.height,
                  title("Working days", Icons.calendar_month),
                  10.height,
                  DecoratedBox(
                    decoration: kBoxDecoration,
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Obx(() {
                          return Wrap(
                            spacing: 10,
                            runSpacing: 15,
                            children: List.generate(
                              controller.workingDays.value.length,
                              (index) => ChoiceChip(
                                label: Text(
                                  controller.workingDays[index].label,
                                  style: Get.textTheme.bodySmall?.copyWith(
                                    color:
                                        controller.workingDays[index].isSelected
                                            ? AppColors.kWhite
                                            : AppColors.black,
                                  ),
                                ),
                                selected:
                                    controller.workingDays[index].isSelected,
                                onSelected: (value) =>
                                    controller.onWorkingDaysChange(index),
                              ),
                            ).toList(),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              30.height,
              // Role Dropdown
              Obx(() {
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Role",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "manager",
                      child: Text("Manager"),
                    ),
                    DropdownMenuItem(
                      value: "developer",
                      child: Text("Employee"),
                    ),
                  ],
                  value: controller.selectedRole.value,
                  onChanged: (value) {
                    controller.selectedRole.value = value!;
                  },
                  validator: (value) =>
                      value == null ? "Please select a role" : null,
                );
              }),
              40.height,
              Obx(() {
                return AppButton.appButton(
                  onPressed: controller.signUp,
                  label: "Signup",
                  child: controller.isSaveLoading.value
                      ? const Center(
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              color: AppColors.kWhite,
                              strokeWidth: 1.5,
                            ),
                          ),
                        )
                      : null,
                );
              }),
              20.height,
              Align(
                alignment: Alignment.topCenter,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Already have an account? ",
                        style: Get.textTheme.bodySmall,
                      ),
                      TextSpan(
                        text: " Login",
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.kBlue900,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = controller.goToLoginPage,
                      ),
                    ],
                  ),
                ),
              ),
              20.height,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openTimePickerdialog(
      bool isStartTime, BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      if (isStartTime) {
        controller.startTime.value = selectedTime;
      } else {
        controller.endTime.value = selectedTime;
      }
    }
  }

  Widget title(String name, IconData iconData) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            style: Get.textTheme.titleLarge,
          ),
          const SizedBox(width: 10),
          Icon(
            iconData,
            size: 20,
            color: AppColors.kBlue600,
          )
        ],
      ),
    );
  }
}
