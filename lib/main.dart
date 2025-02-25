import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hr_application/app/routes/app_pages.dart';
import 'package:hr_application/data/controllers/app_storage_service.dart';
import 'package:hr_application/data/intial_binding.dart';
import 'package:hr_application/utils/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/modules/home.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  await Get.put(AppStorageController()).asyncCurrentUser;
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
      initialRoute: AppPages.INITIAL,
      theme: appTheme,
      initialBinding: IntialBinding(),
    ),
  );
}
