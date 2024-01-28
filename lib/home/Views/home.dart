import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_horizontal_date_picker/persian_horizontal_date_picker.dart';
import 'package:planner/home/Controllers/home_controller.dart';
import 'package:shamsi_date/shamsi_date.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2f2f2f),
      body: SafeArea(
        child: Column(
          children: [
            //BlackSection
            Container(
              padding: EdgeInsets.only(right: 20),
              //height: Get.height / 5*2,
              decoration: BoxDecoration(
                color: Color(0xff2f2f2f),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Obx(() => Text(
                            controller.thismonth.value,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontFamily: 'irancell'),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  PersianHorizontalDatePicker(
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(const Duration(days: 30)),
                    initialSelectedDate: DateTime.now(),
                    onDateSelected: (date) {
                      Jalali j = date!.toJalali();
                      String finaldate = j.year.toString() +
                          '/' +
                          j.month.toString() +
                          '/' +
                          j.day.toString();
                      controller.selectedDate = finaldate;
                      controller.fetch_data(finaldate).then((value) {
                        controller.notes.clear();
                        controller.notes.addAll(value);
                      });
                    },
                  ),
                ],
              ),
            ),
            //RestSection
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Obx(
                  () => ListView.builder(
                      itemCount: controller.notes.length,
                      itemBuilder: (context, index) {
                        Color getRandomColor() {
                          Random random = Random();
                          return controller
                              .colors[random.nextInt(controller.colors.length)];
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      Jalali j = Jalali(
                                        int.parse(controller.selectedDate.substring(0,4)), 
                                        int.parse(controller.selectedDate.substring(5,7)), 
                                        int.parse(controller.selectedDate.substring(8,)),
                                        int.parse(controller.notes[index]['hour'].toString().substring(0,2)), 
                                        int.parse(controller.notes[index]['hour'].toString().substring(3,5)), 
                                        );
                                      Gregorian j2g1 =j.toGregorian();
                                      controller.setAlarm(
                                        j2g1.year.toString(),
                                        j2g1.month.toString(),
                                        j2g1.day.toString(),
                                        j2g1.hour.toString(),
                                        j2g1.minute.toString()
                                      );
                                          
                                    },
                                    child: Image.asset(
                                      'assets/clock.png',
                                      width: 25,
                                      height: 25,
                                    )),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  controller.notes[index]['hour'],
                                  style: TextStyle(
                                      fontSize: 15, color: Color(0xff707070)),
                                ),
                              ],
                            ),
                            Expanded(child: Container()),
                            GestureDetector(
                              onLongPress: () {
                                controller.deleteDialog(
                                    controller.notes[index]['content'],
                                    controller.selectedDate);
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 8),
                                width: Get.width / 4 * 3,
                                decoration: BoxDecoration(
                                    color: getRandomColor(),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20))),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          controller.notes[index]['title'] !=
                                                  null
                                              ? controller.notes[index]['title']
                                              : '',
                                          style: TextStyle(
                                              fontFamily: 'irancell',
                                              fontSize: 20),
                                          textDirection: TextDirection.rtl,
                                          overflow: TextOverflow.fade,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            controller.notes[index]['content'],
                                            style: TextStyle(height: 1.5),
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.addDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
