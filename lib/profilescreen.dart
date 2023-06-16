import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'model/user.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/themes/theme_provider.dart';
CameraController? _cameraController;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();

}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xffeef444c);
  String birth = "Date of birth";

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  bool showRemoveButton = false;

  void pickUploadProfilePic() async {
    final imageSource = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image Source"),
          actions: <Widget>[
            TextButton(
              child: Text("Camera"),
              onPressed: () {
                Navigator.pop(context, ImageSource.camera);
              },
            ),
            TextButton(
              child: Text("Gallery"),
              onPressed: () {
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );

    if (imageSource != null) {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: imageSource,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 90,
      );

      if (image != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child("${User.employeeId.toLowerCase()}_profilepic.jpg");

        await ref.putFile(File(image.path));

        ref.getDownloadURL().then((value) async {
          setState(() {
            User.profilePicLink = value;
            showRemoveButton = true;
          });

          await FirebaseFirestore.instance
              .collection("Employee")
              .doc(User.id)
              .update({
            'profilePic': value,
          });
        });
      }
    }
  }

  void removeProfilePic() async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${User.employeeId.toLowerCase()}_profilepic.jpg");

    await ref.delete();

    setState(() {
      User.profilePicLink = "";
      showRemoveButton = false;
    });

    await FirebaseFirestore.instance
        .collection("Employee")
        .doc(User.id)
        .update({
      'profilePic': '',
    });
  }


  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.getTheme().colorScheme.tertiary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _cameraController != null
                      ? CameraPreview(_cameraController!)
                      : Container(),
                ),
                InkWell(
                  onTap: () {
                    pickUploadProfilePic();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 80, bottom: 24),
                    height: 120,
                    width: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: primary,
                    ),
                    child: Center(
                      child: User.profilePicLink.isEmpty
                          ?  Icon(
                        Icons.person,
                        color: themeProvider.getTheme().colorScheme.background,
                        size: 80,
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                            User.profilePicLink,
                                height : 200,
                                width: 200,
                                fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                if (showRemoveButton)
                  Positioned(
                    top: 160,
                    right: 70,
                    child: IconButton(
                      icon: const Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                        size: 30,
                      ),
                      onPressed: removeProfilePic,
                    ),
                  ),
              ],
            ),

            Align(
              alignment: Alignment.center,
              child: Text(
                "Employee ${User.employeeId}",
                style: const TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 24,),
            User.canEdit ? textField("First Name", "First name", firstNameController) : field("First Name", User.firstName),
            User.canEdit ? textField("Last Name", "Last name", lastNameController) : field("Last Name", User.lastName),
            User.canEdit ? GestureDetector(
              onTap: () {
                showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: primary,
                            secondary: primary,
                            onSecondary: themeProvider.getTheme().colorScheme.background,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              primary: primary,
                            ),
                          ),
                          textTheme: const TextTheme(
                            headline4: TextStyle(
                              fontFamily: "NexaBold",
                            ),
                            overline: TextStyle(
                              fontFamily: "NexaBold",
                            ),
                            button: TextStyle(
                              fontFamily: "NexaBold",
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    }
                ).then((value) {
                  setState(() {
                    birth = DateFormat("MM/dd/yyyy").format(value!);
                  });
                });
              },
              child: field("Date of Birth", birth),
            ) : field("Date of Birth", User.birthDate),
            User.canEdit ? textField("Address", "Address", addressController) : field("Address", User.address),
            User.canEdit ? GestureDetector(
              onTap: () async {
                String firstName = firstNameController.text;
                String lastName = lastNameController.text;
                String birthDate = birth;
                String address = addressController.text;

                if(User.canEdit) {
                  if(firstName.isEmpty) {
                    showSnackBar("Please enter your first name!");
                  } else if(lastName.isEmpty) {
                    showSnackBar("Please enter your last name!");
                  } else if(birthDate.isEmpty) {
                    showSnackBar("Please enter your birth date!");
                  } else if(address.isEmpty) {
                    showSnackBar("Please enter your address!");
                  } else {
                    await FirebaseFirestore.instance.collection("Employee").doc(User.id).update({
                      'firstName': firstName,
                      'lastName': lastName,
                      'birthDate': birthDate,
                      'address': address,
                      'canEdit': false,
                    }).then((value) {
                      setState(() {
                        User.canEdit = false;
                        User.firstName = firstName;
                        User.lastName = lastName;
                        User.birthDate = birthDate;
                        User.address = address;
                      });
                    });
                  }
                } else {
                  showSnackBar("You can't edit anymore, please contact support team.");
                }
              },
              child: Container(
                height: kToolbarHeight,
                width: screenWidth,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: primary,
                ),
                child: Center(
                  child: Text(
                    "SAVE",
                    style: TextStyle(
                      color: themeProvider.getTheme().colorScheme.background,
                      fontFamily: "NexaBold",
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget field(String title, String text) {

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: "NexaBold",
              color: themeProvider.getTheme().colorScheme.secondary,
            ),
          ),
        ),
        Container(
          height: kToolbarHeight,
          width: screenWidth,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(left: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: themeProvider.getTheme().colorScheme.primaryContainer,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle(
                color: themeProvider.getTheme().colorScheme.primaryContainer,
                fontFamily: "NexaBold",
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget textField(String title, String hint, TextEditingController controller) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style:  TextStyle(
              fontFamily: "NexaBold",
              color: themeProvider.getTheme().colorScheme.secondary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            cursorColor: themeProvider.getTheme().colorScheme.primaryContainer,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: themeProvider.getTheme().colorScheme.primaryContainer,
                fontFamily: "NexaBold",
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: themeProvider.getTheme().colorScheme.primaryContainer,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: themeProvider.getTheme().colorScheme.primaryContainer,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          text,
        ),
      ),
    );
  }

}