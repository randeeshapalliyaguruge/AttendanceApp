import 'package:attendance_app/calenderscreen.dart';
import 'package:attendance_app/model/user.dart';
import 'package:attendance_app/profilescreen.dart';
import 'package:attendance_app/services/location_service.dart';
import 'package:attendance_app/todyscreen.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/themes/theme_provider.dart';
CameraController? _cameraController;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenHeight =  0;
  double screenWidth =  0;

  Color primary = const Color(0xffeef444c);

  int currentIndex = 1;    //Todo change this to 1 I personally changed it

  List<IconData> navigationIcons = [
    FontAwesomeIcons.calendarAlt,
    FontAwesomeIcons.check,
    FontAwesomeIcons.user,
  ];

  @override
  void initState() {
    super.initState();
    initializeCamera();
   //_startLocationService();
    getId().then((value) {
      _getCredentials();
      _getProfilePic();
    });
  }

  void _getCredentials() async {
    try{
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Employee").doc(User.id).get();
      setState(() {
        User.canEdit = doc['canEdit'];
        User.firstName = doc['firstName'];
        User.lastName = doc['lastName'];
        User.birthDate = doc['birthDate'];
        User.address = doc['address'];
      });
    } catch(e) {
      return;
    }
  }

  void _getProfilePic() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Employee").doc(User.id).get();
    setState(() {
      User.profilePicLink = doc['profilePic'];
    });
  }

  // void _startLocationService() async {
  //   LocationService().initialize();
  //
  //   LocationService().getLongitude().then((value) {
  //     setState(() {
  //       User.long = value!;
  //     });
  //
  //     LocationService().getLatitude().then((value) {
  //       setState(() {
  //         User.lat  = value!;
  //       });
  //     });
  //   });
  // }

  List<CameraDescription> cameras = [];

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    // Select the first camera in the list
    CameraController controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller.initialize();
    setState(() {
      // Assign the initialized camera controller to a variable
      _cameraController = controller;
    });
  }

  Future<void> getId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Employee")
        .where('id' , isEqualTo: User.employeeId)
        .get();

    setState(() {
      User.id = snap.docs[0].id;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      // backgroundColor: themeProvider.getTheme().colorScheme.tertiary,
      body: IndexedStack(
        index: currentIndex,
        children: [
          new CalenderScreen(),
          new TodayScreen(),
          new ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 24,
        ),
        decoration: BoxDecoration(
          color: themeProvider.getTheme().colorScheme.primary,
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: themeProvider.getTheme().colorScheme.secondaryContainer,
              blurRadius: 10,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child:  ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for(int i =0; i < navigationIcons.length; i++)...<Expanded>{
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = i;
                      });
                    },
                    child: Container(
                      height: screenHeight,
                      width: screenWidth,
                      color: themeProvider.getTheme().colorScheme.background,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                navigationIcons[i],
                                color: i == currentIndex ?  primary : themeProvider.getTheme().colorScheme.primaryContainer,
                                size: i == currentIndex ? 30 : 26,
                            ),
                            i == currentIndex ? Container(
                              margin: EdgeInsets.only(top: 6),
                              height: 3,
                              width: 22,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                color: primary,
                              ),
                            ) : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              }
            ],
          ),
        ),
      ),
    );
  }
}
