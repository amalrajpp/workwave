import 'dart:async';
import 'package:get/get.dart';
import 'package:hr_application/app/modules/HomePage/model/attendence_model.dart';
import 'package:hr_application/app/modules/HomePage/model/user_activity_model.dart';
import 'package:hr_application/data/controllers/api_conntroller.dart';
import 'package:hr_application/data/controllers/api_url_service.dart';
import 'package:hr_application/data/controllers/app_storage_service.dart';
import 'package:hr_application/utils/app_extension.dart';
import 'package:hr_application/utils/helper_function.dart';
import 'package:intl/intl.dart';

class HomePageController extends GetxController {
  var selectedDate = DateTime.now().obs;
  var attendenceLoading = true.obs, activityLoading = true.obs;
  var attendenceModel = Rxn<AttendenceModel?>(null);
  var userActivityModel = Rxn<UserActivityModel?>(null);
  var userPerformActivty = UserPerformActivty.IN.obs;
  var now = DateTime.now();
  var workingTime = "".obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _initializeDummyData();
  }

  void _initializeDummyData() {
    // Sample dummy attendance data
    attendenceModel.value = AttendenceModel(
      inTime: "09:00:00",
      outTime: "18:00:00",
      breakInTime: ["12:30:00"],
      breakOutTime: ["13:00:00"],
    );

    // Sample dummy user activity data
    userActivityModel.value = UserActivityModel(
      activityID: "1",
      checkIn: CheckIn("09:00 AM", "in"),
      breakInTime: ["12:30 PM"],
      breakOutTime: ["01:00 PM"],
      outTime: OutTime("out", "06:00 PM"),
    );

    startTimer();
  }

  @override
  void onReady() {
    super.onReady();
    getTodatyAttendenceData();
    getActivityData();
  }

  void startTimer() {
    _timer?.cancel();
    if (attendenceModel.value?.inTime == null) {
      print("Timer cannot start, no check-in time.");
      return;
    } else if (attendenceModel.value?.inTime != null &&
        attendenceModel.value?.outTime != null) {
      workingTime.value = DateFormat("hh:mm:ss")
          .parse(attendenceModel.value!.outTime!)
          .difference(
              DateFormat("hh:mm:ss").parse(attendenceModel.value!.inTime!))
          .toString()
          .split(".")[0];
    } else {
      var inTime = DateFormat("hh:mm:ss").parse(attendenceModel.value!.inTime!);
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          inTime = inTime.add(const Duration(seconds: 1));
          workingTime.value = DateFormat("hh:mm:ss").format(inTime);
        },
      );
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void onDateChnged(DateTime newDate) {
    selectedDate.value = newDate;
    getTodatyAttendenceData();
    getActivityData();
  }

  void getTodatyAttendenceData() {
    var url = APIUrlsService.to.getDataByIDAndCompanyIdAndDate(
      AppStorageController.to.currentUser?.userID ?? '123',
      AppStorageController.to.currentUser?.companyID ?? '456',
      selectedDate.value.toYYYMMDD,
    );
    ApiController.to.callGETAPI(url: url).catchError((e) {
      showErrorSnack(e.toString());
      attendenceLoading.value = false;
    }).then((resp) {
      attendenceLoading.value = false;
      if (resp != null &&
          resp is Map<String, dynamic> &&
          (resp['status'] as bool)) {
        attendenceModel.value = AttendenceModel.fromJson(resp['data']);
        startTimer();
      } else {
        attendenceModel.value = null;
      }
    });
  }

  String get calculateTotalWorkingHours {
    return DateFormat("hh:mm:ss")
        .parse(attendenceModel.value!.outTime!)
        .difference(
            DateFormat("hh:mm:ss").parse(attendenceModel.value!.inTime!))
        .toString();
  }

  void getActivityData() {
    ApiController.to
        .callGETAPI(
      url: APIUrlsService.to.getActivityList(
        AppStorageController.to.currentUser?.userID ?? '123',
        AppStorageController.to.currentUser?.companyID ?? '456',
        selectedDate.value.toYYYMMDD,
      ),
    )
        .catchError((e) {
      showErrorSnack(e.toString());
      activityLoading.value = false;
    }).then((resp) {
      activityLoading.value = false;
      if (resp != null &&
          resp is Map<String, dynamic> &&
          resp['data'] != null) {
        userActivityModel.value = UserActivityModel.fromJson(resp['data']);
        if (userActivityModel.value?.checkIn == null) {
          userPerformActivty.value = UserPerformActivty.IN;
        } else if (userActivityModel.value?.breakInTime == null ||
            (userActivityModel.value?.breakInTime?.isEmpty ?? true)) {
          userPerformActivty.value = UserPerformActivty.BREAKIN;
        } else if (userActivityModel.value?.breakOutTime == null ||
            ((userActivityModel.value?.breakInTime?.length ?? 0) >
                ((userActivityModel.value?.breakOutTime?.length ?? 0)))) {
          userPerformActivty.value = UserPerformActivty.BREAKOUT;
        } else if (userActivityModel.value?.outTime == null) {
          userPerformActivty.value = UserPerformActivty.BREAKIN;
        }
      } else {
        userActivityModel.value = null;
      }
    });
  }

  void performInOut() {
    if (activityLoading.value) return;
    activityLoading.value = true;
    var payload = {
      "activityID": userActivityModel.value?.activityID,
      "userID": AppStorageController.to.currentUser?.userID ?? '123',
      "companyID": AppStorageController.to.currentUser?.companyID ?? '456',
      "activityType": userPerformActivty.value.name,
    };
    if (userPerformActivty.value == UserPerformActivty.IN) {
      payload.putIfAbsent("inTime", () => DateTime.now().toHOUR24MINUTESECOND);
    } else if (userPerformActivty.value == UserPerformActivty.BREAKIN) {
      payload.putIfAbsent(
          "breakInTime", () => DateTime.now().toHOUR24MINUTESECOND);
    } else if (userPerformActivty.value == UserPerformActivty.BREAKOUT) {
      payload.putIfAbsent(
          "breakOutTime", () => DateTime.now().toHOUR24MINUTESECOND);
    } else if (userPerformActivty.value == UserPerformActivty.OUT) {
      payload.putIfAbsent("outTime", () => DateTime.now().toHOUR24MINUTESECOND);
    }
    ApiController.to
        .callPOSTAPI(
      url: APIUrlsService.to.dailyInOut,
      body: payload,
    )
        .catchError((e) {
      activityLoading.value = false;
    }).then((resp) {
      activityLoading.value = false;
      if (resp != null && resp is Map<String, dynamic> && resp['status']) {
        getTodatyAttendenceData();
        getActivityData();
        showSuccessSnack("User has been: ${userPerformActivty.value.name}");
      }
    });
  }

  Duration calculateTotalBreakTime(
      List<String> inTimes, List<String> outTimes) {
    Duration totalBreakTime = Duration.zero;
    DateFormat format = DateFormat("HH:mm:ss");

    for (int i = 0; i < inTimes.length && i < outTimes.length; i++) {
      DateTime inTime = format.parse(inTimes[i]);
      DateTime outTime = format.parse(outTimes[i]);
      totalBreakTime += outTime.difference(inTime);
    }

    return totalBreakTime;
  }

  String? calculateTimeDifference(
      List<String>? inTimes, List<String>? outTimes) {
    if ((inTimes?.isEmpty ?? true) || (outTimes?.isEmpty ?? true)) {
      return null;
    }

    var times = mergeBreakInBreakOutTimes(inTimes!, outTimes!);

    Duration totalDuration = Duration.zero;
    if (times.length < 2) {
      return secondsToTime(totalDuration.inSeconds);
    }
    DateFormat format = DateFormat("HH:mm:ss");
    for (int i = 0; i < times.length - 1; i += 2) {
      if (i >= times.length) break;
      DateTime currentTime = format.parse(times[i]);
      DateTime nextTime = format.parse(times[i + 1]);
      totalDuration += nextTime.difference(currentTime);
    }
    return secondsToTime(totalDuration.inSeconds);
  }

  @override
  void onClose() {
    stopTimer();
    super.onClose();
  }

  int get countWorkingDays {
    int count = 0;
    int currentYear = DateTime.now().year;
    int currentMonth = DateTime.now().month;
    int totalDaysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;

    for (int i = 1; i <= totalDaysInMonth; i++) {
      DateTime date = DateTime(currentYear, currentMonth, i);
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        count++;
      }
    }
    return count;
  }
}
