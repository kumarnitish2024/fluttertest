import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'homepage.dart';

class EditProfile extends StatefulWidget {
  EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();

  XFile? imageFile;
  final picker = ImagePicker();
  String? backImageUrl;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // Load user data into the form fields
  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          name.text = userDoc.get("name");
          email.text = user.email ?? "email";
          backImageUrl = userDoc.get("backGroundImage");
        });
      }
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      imageFile = pickedFile;
    });
  }

  Future<void> uploadImageToFirebase() async {
    final auth = FirebaseAuth.instance.currentUser?.uid;
    if (imageFile != null) {
      File file = File(imageFile!.path);
      var ref = FirebaseStorage.instance
          .ref()
          .child('backgroundImage')
          .child("$auth.background");
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      setState(() async {
        backImageUrl = await snapshot.ref.getDownloadURL();
        // Update only the background image URL in Firestore
        await FirebaseFirestore.instance.collection("Users").doc(auth).update({
          "images": backImageUrl,
        });
        // Optionally, you can notify the user that the image has been updated.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully.'),
          ),
        );
      });
    }
  }

  Future<void> userUpdateProfile() async {
    var auth = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance.collection("Users").doc(auth).update({
      "name": name.text,
      "email": email.text,
      // Remove "backGroundImage" from this update
    }).then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    }).catchError((error) {
      print('Error updating profile: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Edit Profile",
            style: TextStyle(color: Colors.black),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipOval(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: backImageUrl != null
                            ? NetworkImage(backImageUrl!)
                            : null,
                        child: imageFile != null
                            ? Image.file(
                          File(imageFile!.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Wrap(
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        Icons.camera_alt,
                                        color: Colors.black,
                                      ),
                                      title: Text('Camera'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        pickImage(ImageSource.camera);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.image,
                                        color: Colors.black,
                                      ),
                                      title: Text('Gallery'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        pickImage(ImageSource.gallery);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, right: 230),
                child: Text(
                  "Your Information",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(27),
                child: TextField(
                  controller: name,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "First name",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 26, right: 26, top: 29),
                child: TextField(
                  controller: email,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Email Id",
                  ),
                ),
              ),
              SizedBox(
                height: 90,
                width: 180,
                child: Padding(
                  padding: const EdgeInsets.only(top: 36),
                  child: ElevatedButton(
                    onPressed: () {
                      userUpdateProfile(); // Enable this line to update the profile and navigate to HomePage.
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Update",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 19,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}