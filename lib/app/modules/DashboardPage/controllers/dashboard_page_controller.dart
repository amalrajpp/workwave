import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DashboardPageController extends GetxController {
  var projectData = {}.obs;
  var isLoading = true.obs;

  void fetchProjectDetails(String projectId) async {
    isLoading(true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .get();
      projectData.value = doc.data() ?? {};
    } finally {
      isLoading(false);
    }
  }
}
