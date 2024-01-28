import 'dart:math';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner/Utils/sqlite_service.dart';
import 'package:planner/home/Widgets/text_field.dart';
import 'package:shamsi_date/shamsi_date.dart';

class HomeController extends GetxController {
  String selectedDate = '';
  RxString thismonth = ''.obs;
  RxList<Map<String, dynamic>> notes = <Map<String, dynamic>>[].obs;
  DatabaseHelper dbHelper = DatabaseHelper();
  void getThisMonth() {
    DateTime dt = DateTime.now();
    Jalali j = dt.toJalali();
    final f = j.formatter;
    thismonth.value = f.mN;
  }

  Future<List<Map<String, dynamic>>> fetch_data(String date) async {
    List<Map<String, dynamic>> data = await dbHelper.getDataByDate(date);
    return data;
  }

  void add_note(String date, String note, String title, String hour) async {
    await dbHelper.insertData(note, date, title, hour);
    fetch_data(date).then((value) {
      notes.clear();
      notes.addAll(value);
    });
    Navigator.of(Get.context!, rootNavigator: true).pop('dialog');
  }

  String get_now() {
    DateTime dt = DateTime.now();
    Jalali j = dt.toJalali();
    String today =
        j.year.toString() + '/' + j.month.toString() + '/' + j.day.toString();
    selectedDate = today;
    return today;
  }

  String formatTime(String inputTime) {
    List<String> timeParts = inputTime.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    String formattedHour = hour < 10 ? '0$hour' : hour.toString();
    String formattedMinute = minute < 10 ? '0$minute' : minute.toString();
    String formattedTime = '$formattedHour:$formattedMinute';

    return formattedTime;
  }

  void addDialog() {
    TextEditingController content_controller = TextEditingController();
    TextEditingController hour_controller = TextEditingController();
    TextEditingController title_controller = TextEditingController();
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoundedInput(
            label: 'عنوان یادداشت',
            max_len: 40,
            controller: title_controller,
            is_active: true,
          ),
          SizedBox(
            height: 10,
          ),
          GestureDetector(
              onTap: () async {
                showTimePicker(
                        confirmText: 'تایید',
                        cancelText: 'لغو',
                        hourLabelText: 'ساعت',
                        minuteLabelText: 'دقیقه',
                        helpText: 'ساعت شروع را انتخاب کنید',
                        context: Get.context!,
                        initialTime: TimeOfDay.now())
                    .then((value) {
                  if (value != null) {
                    hour_controller.text = formatTime(
                        value.hour.toString() + ':' + value.minute.toString());
                  }
                });
              },
              child: RoundedInput(
                label: 'ساعت شروع',
                max_len: 10,
                controller: hour_controller,
                is_active: false,
              )),
          SizedBox(
            height: 10,
          ),
          RoundedInput(
            label: 'متن یادداشت',
            max_len: 1000,
            controller: content_controller,
            is_active: true,
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 30,
          ),
          SizedBox(
            width: Get.width / 2,
            height: 50,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: StadiumBorder(),
                ),
                onPressed: () {
                  if (title_controller.text.isNotEmpty &&
                      content_controller.text.isNotEmpty &&
                      hour_controller.text.isNotEmpty) {
                    add_note(
                        selectedDate,
                        content_controller.text,
                        title_controller.text.toString(),
                        hour_controller.text.toString());
                  } else {
                    Get.snackbar('خطا', 'همه بخش ها را باید پر کنید',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white);
                  }
                },
                child: Text(
                  'ثبت',
                  style: TextStyle(fontSize: 18),
                )),
          )
        ],
      ),
    ));
  }

  void deleteDialog(String note, String date) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'آیا از حذف این یادداشت مطمئن هستید؟',
            textDirection: TextDirection.rtl,
          ),
          SizedBox(
            height: 35,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: Get.width / 4,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: StadiumBorder(),
                  ),
                  onPressed: () {
                    dbHelper
                        .deleteNoteByDateAndContent(date, note)
                        .then((value) {
                      fetch_data(date).then((value) {
                        notes.clear();
                        notes.addAll(value);
                      });
                      Navigator.of(Get.context!, rootNavigator: true)
                          .pop('dialog');
                    });
                  },
                  child: Text(
                    'بله',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                width: Get.width / 4,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: StadiumBorder(),
                  ),
                  onPressed: () {
                    Navigator.of(Get.context!, rootNavigator: true)
                        .pop('dialog');
                  },
                  child: Text(
                    'خیر',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }

  Future<void> setAlarm(
      String year, String month, String day, String hour, String min) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(int.parse(year), int.parse(month),
        int.parse(day), int.parse(hour), int.parse(min));

    if (scheduledTime.isAfter(now)) {
      final alarmSettings = AlarmSettings(
        id: Random().nextInt(999999999),
        dateTime: scheduledTime,
        assetAudioPath: 'assets/notif.mp3',
        loopAudio: false,
        vibrate: true,
        volume: 0.5,
        fadeDuration: 3.0,
        notificationTitle: 'Planner New plan riched',
        notificationBody: 'Dont forget yout today plan',
        enableNotificationOnKill: true,
      );
      await Alarm.set(alarmSettings: alarmSettings);
      Get.snackbar('', 'آلارم هشدار با موفقیت ثبت شد');
    } else {
      Get.snackbar('خطا', 'فقط برای زمان آینده میتوان هشدار تعیین کرد',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  List<Color> colors = [
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.yellow.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.cyan.shade100,
  ];

  @override
  void onInit() {
    getThisMonth();
    fetch_data(get_now()).then((value) {
      notes.clear();
      notes.addAll(value);
    });
    super.onInit();
  }
}
