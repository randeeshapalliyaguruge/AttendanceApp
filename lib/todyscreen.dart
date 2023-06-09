import 'dart:async';

import 'package:attendance_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gradient_slide_to_act/gradient_slide_to_act.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/themes/theme_provider.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight =  0;
  double screenWidth =  0;

  String checkIn = "--/--";
  String checkOut = "--/--";
  String location = " ";

  Color primary = const Color(0xffeef444c);

  @override
  void initState() {
    super.initState();
    _getRecord();
  }

  void _getLocation() async {
    List<Placemark> placemark = await placemarkFromCoordinates(User.lat, User.long);

    setState(() {
      location = "${placemark[0].street}, ${placemark[0].administrativeArea}, ${placemark[0].postalCode}, ${placemark[0].country}";
    });
  }

  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: User.employeeId)
          .get();

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      setState(() {
        checkIn = snap2['checkIn'];
        checkOut = snap2['checkOut'];
      });
    } catch (e) {
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    final themeProvider = Provider.of<ThemeProvider>(context);

    return  Scaffold(
      backgroundColor: themeProvider.getTheme().colorScheme.tertiary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 32),
              child: Row(
                children: [
                  Text(
                    "Welcome, ",
                    style: TextStyle(
                      color: themeProvider.getTheme().colorScheme.primaryContainer,
                      fontFamily: "NexaRegular",
                      fontSize: screenWidth / 20,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.light_mode),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Employee " + User.employeeId,
                style: TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 32),
              child: Text(
                "Today's Status",
                style: TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12 , bottom: 32),
              height: 150,
              decoration: BoxDecoration(
                color: themeProvider.getTheme().colorScheme.background,
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.getTheme().colorScheme.secondaryContainer,
                    blurRadius: 10,
                    offset: Offset(2 ,2),
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              "Check In",
                            style: TextStyle(
                              fontFamily: "NexaRegular",
                              fontSize: screenWidth / 20,
                              color: themeProvider.getTheme().colorScheme.primaryContainer,
                            ),
                          ),
                          Text(
                            checkIn,
                            style: TextStyle(
                              fontFamily: "NexaBold",
                              fontSize: screenWidth / 18,
                            ),
                          ),
                        ],
                      ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Check Out",
                          style: TextStyle(
                            fontFamily: "NexaRegular",
                            fontSize: screenWidth / 20,
                            color: themeProvider.getTheme().colorScheme.primaryContainer,
                          ),
                        ),
                        Text(
                          checkOut,
                          style: TextStyle(
                            fontFamily: "NexaBold",
                            fontSize: screenWidth / 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  text: DateTime.now().day.toString(),
                  style: TextStyle(
                    color: primary,
                    fontSize: screenWidth / 18,
                    fontFamily: "NexaBold",
                  ),
                  children: [
                    TextSpan(
                      text: DateFormat(' MMMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                        color: themeProvider.getTheme().colorScheme.secondary,
                        fontSize: screenWidth / 20,
                        fontFamily: "NexaBold",
                      )
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat('hh:mm:ss a').format(DateTime.now()),
                    style: TextStyle(
                      fontFamily: "NexaRegular",
                      fontSize: screenWidth / 20,
                      color: themeProvider.getTheme().colorScheme.primaryContainer,
                    ),
                  ),
                );
              }
            ),
            checkOut == "--/--" ? Container(
              margin: const EdgeInsets.only(top: 24, bottom: 12),
              height: 65,
              decoration: BoxDecoration(
                color: themeProvider.getTheme().colorScheme.background,
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.getTheme().colorScheme.primaryContainer,
                    blurRadius: 10,
                    offset: const Offset(2 ,2),
                  )
                ],
                borderRadius: const BorderRadius.all(Radius.circular(30)),
              ),
              child: Builder(
                  builder: (context) {
                    return GradientSlideToAct(
                      key: UniqueKey(), // Assigning a unique key using UniqueKey()
                      width: screenWidth ,
                      dragableIcon: Icons.arrow_forward,
                      text: checkIn == "--/--" ? "Slide to Check In" : "Slide to Check Out",
                      textStyle: TextStyle(
                        color: themeProvider.getTheme().colorScheme.primaryContainer,
                        fontSize: screenWidth/20,
                        fontFamily: "NexaRegular",
                      ),
                      backgroundColor: themeProvider.getTheme().colorScheme.background,

                      gradient:const LinearGradient(
                          begin: Alignment.centerLeft,
                          colors: [
                            Colors.red,
                            Colors.purple,
                          ],
                      ),

                      onSubmit: () async {
                        if(User.lat !=0 ){
                          _getLocation();

                          QuerySnapshot snap = await FirebaseFirestore.instance
                              .collection("Employee")
                              .where('id', isEqualTo: User.employeeId)
                              .get();

                          DocumentSnapshot snap2 = await FirebaseFirestore.instance
                              .collection("Employee")
                              .doc(snap.docs[0].id)
                              .collection("Record")
                              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                              .get();

                          try {
                            String checkIn = snap2['checkIn'];

                            setState(() {
                              checkOut = DateFormat('hh:mm').format(DateTime.now());
                            });

                            await FirebaseFirestore.instance
                                .collection("Employee")
                                .doc(snap.docs[0].id)
                                .collection("Record")
                                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                .update({
                              'date': Timestamp.now(),
                              'checkIn': checkIn,
                              'checkOut' : DateFormat('hh:mm').format(DateTime.now()),
                              'location' : location,
                            });
                          } catch (e) {
                            setState(() {
                              checkIn = DateFormat('hh:mm').format(DateTime.now());
                            });
                            await FirebaseFirestore.instance
                                .collection("Employee")
                                .doc(snap.docs[0].id)
                                .collection("Record")
                                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                .set({
                              'date': Timestamp.now(),
                              'checkIn': DateFormat('hh:mm').format(DateTime.now()),
                              'checkOut' : "--/--",
                              'location' : location,
                            });
                          }

                          var key;
                          key.currentState!.reset();
                        } else {
                          Timer(const Duration(seconds: 3), () async {
                            _getLocation();

                            QuerySnapshot snap = await FirebaseFirestore.instance
                                .collection("Employee")
                                .where('id', isEqualTo: User.employeeId)
                                .get();

                            DocumentSnapshot snap2 = await FirebaseFirestore.instance
                                .collection("Employee")
                                .doc(snap.docs[0].id)
                                .collection("Record")
                                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                .get();

                            try {
                              String checkIn = snap2['checkIn'];

                              setState(() {
                                checkOut = DateFormat('hh:mm').format(DateTime.now());
                              });

                              await FirebaseFirestore.instance
                                  .collection("Employee")
                                  .doc(snap.docs[0].id)
                                  .collection("Record")
                                  .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                  .update({
                                'date': Timestamp.now(),
                                'checkIn': checkIn,
                                'checkOut' : DateFormat('hh:mm').format(DateTime.now()),
                                'location' : location,
                              });
                            } catch (e) {
                              setState(() {
                                checkIn = DateFormat('hh:mm').format(DateTime.now());
                              });
                              await FirebaseFirestore.instance
                                  .collection("Employee")
                                  .doc(snap.docs[0].id)
                                  .collection("Record")
                                  .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                  .set({
                                'date': Timestamp.now(),
                                'checkIn': DateFormat('hh:mm').format(DateTime.now()),
                                'checkOut' : "--/--",
                                'location' : location,
                              });
                            }

                            var key;
                            key.currentState!.reset();
                          });
                        }

                      }, //onSubmit
                    );
                  }
              ),
            ) : Container(
              margin: const EdgeInsets.only(top: 32, bottom: 32),
              child: Text(
                  "You have completed this day!",
                style: TextStyle(
                  fontFamily: "NexaRegular",
                  fontSize: screenWidth / 20,
                  color: themeProvider.getTheme().colorScheme.primaryContainer,
                ),
              ),
            ),
            location != " " ? Text(
              "Location: " + location,
            ) : const SizedBox(),
          ],
        ),
      )
    );
  }
}
