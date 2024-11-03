import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_application/app/modules/DashboardPage/bindings/dashboard_page_binding.dart';
import 'package:hr_application/app/modules/DashboardPage/views/dashboard_page_view.dart';
import 'package:hr_application/app/modules/HolidayPage/bindings/holiday_page_binding.dart';
import 'package:hr_application/app/modules/HolidayPage/views/holiday_page_view.dart';
import 'package:hr_application/app/modules/HomePage/bindings/home_page_binding.dart';
import 'package:hr_application/app/modules/HomePage/views/home_page_view.dart';
import 'package:hr_application/app/modules/LeavePage/bindings/leave_page_binding.dart';
import 'package:hr_application/app/modules/LeavePage/views/leave_page_view.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  var currentIndex = 0.obs;

  final pages = <String>[
    '/home-page',
    '/leave-page',
    '/dashboard-page',
    '/holiday-page'
  ];

  void changePage(int index) {
    currentIndex.value = index;
    Get.toNamed(pages[index], id: 1);
  }

  Route onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/home-page')
      return GetPageRoute(
        settings: settings,
        page: () => HomePageView(),
        binding: HomePageBinding(),
      );

    if (settings.name == '/leave-page')
      return GetPageRoute(
        settings: settings,
        page: () => LeavePageView(),
        binding: LeavePageBinding(),
      );

    if (settings.name == '/dashboard-page')
      return GetPageRoute(
        settings: settings,
        page: () => DashboardPageView(),
        binding: DashboardPageBinding(),
      );
    if (settings.name == '/holiday-page')
      return GetPageRoute(
        settings: settings,
        page: () => HolidayPageView(),
        binding: HolidayPageBinding(),
      );
    return GetPageRoute(
      settings: settings,
      page: () => HomePageView(),
      binding: HomeBinding(),
    );
  }
}

class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: Get.nestedKey(1),
        initialRoute: '/home-page',
        onGenerateRoute: controller.onGenerateRoute,
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Leave',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.security),
              label: 'Admin',
            ),
          ],
          currentIndex: controller.currentIndex.value,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.white,
          backgroundColor: Colors.blue,
          onTap: controller.changePage,
        ),
      ),
    );
  }
}
