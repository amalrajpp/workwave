import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_application/app/modules/HomePage/model/user_activity_model.dart';
import 'package:hr_application/app/modules/HomePage/views/user_activity_view.dart';
import 'package:hr_application/app/routes/app_pages.dart';
import 'package:hr_application/data/app_enums.dart';
import 'package:hr_application/data/controllers/app_storage_service.dart';
import 'package:hr_application/utils/app_extension.dart';
import 'package:hr_application/utils/theme/app_colors.dart';
import 'package:hr_application/utils/theme/app_theme.dart';
import 'package:hr_application/widgets/horizontal_date.dart';
import 'package:hr_application/widgets/swipebutton/swipe_button.dart';
import 'package:intl/intl.dart';

import '../controllers/home_page_controller.dart';
import 'attendance.dart';

class HomePageView extends GetView<HomePageController> {
  const HomePageView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          //? User Profile
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(minRadius: 35),
                16.width,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStorageController.to.currentUser?.fullName ?? '-',
                      style: Get.textTheme.headlineMedium,
                    ),
                    Text(
                      AppStorageController.to.currentUser?.companyName ?? '-',
                      style: Get.textTheme.bodyLarge,
                    ),
                  ],
                ),
                const Spacer(),
                IconButton.outlined(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Get.offAndToNamed(Routes.LOGIN_PAGE);
                  },
                  icon: const Icon(Icons.logout),
                )
              ],
            ),
          ),
          12.height,
          //? Date Picker
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() {
              return HorizontalDate(
                fromDate: DateTime.now(),
                toDate: DateTime.now().subtract(const Duration(days: 10)),
                selectedDate: controller.selectedDate.value,
              );
            }),
          ),
          28.height,
          //? Today Attendence Text
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Text("Today Attendence", style: Get.textTheme.headlineSmall),
                16.width,
                if (AppStorageController.to.currentUser?.roleType ==
                        UserRoleType.admin ||
                    AppStorageController.to.currentUser?.roleType ==
                        UserRoleType.manager ||
                    AppStorageController.to.currentUser?.roleType ==
                        UserRoleType.superAdmin) ...[
                  Spacer(),
                  20.width,
                ],
                Obx(
                  () {
                    return controller.attendenceLoading.value
                        ? const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              color: AppColors.kFoundationPurple700,
                              strokeWidth: 1.5,
                            ),
                          )
                        : const SizedBox();
                  },
                ),
              ],
            ),
          ),
          8.height,
          //? Check In && Check Out

          20.height,
          AttendanceButton(),

          60.height,

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Expanded(child: _buildCheckInOutCard(Icons.free_breakfast_outlined, "Break Time", "00:20 min", "Avg Time 30min")),
                Expanded(
                  child: Obx(
                    () {
                      return _buildCheckInOutCard(
                        Icons.free_breakfast_outlined,
                        "Break Time",
                        controller.calculateTimeDifference(
                                controller.attendenceModel.value?.breakInTime,
                                controller
                                    .attendenceModel.value?.breakOutTime) ??
                            '-',
                        "",
                      );
                    },
                  ),
                ),
                10.width,
                Expanded(
                  child: _buildCheckInOutCard(
                    Icons.calendar_today_outlined,
                    "Total Days",
                    controller.countWorkingDays.toString(),
                    "Working Days/M",
                  ),
                ),
              ],
            ),
          ),
          60.height,
        ],
      ),
    );
  }

  _buildCheckInOutCard(
    IconData iconData,
    String title,
    String time,
    String description,
  ) {
    return DecoratedBox(
      decoration: kBoxDecoration,
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
}
