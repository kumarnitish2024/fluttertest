import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Models/usermodels.dart';
import 'editpage.dart';
import 'loginpage.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? userDataModel;

  @override
  void initState() {
    super.initState();
    retrieveData().then((value) {
      setState(() {
        userDataModel = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomePage"),

        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: ListView(
        children: [
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircleAvatar(
                    child: SizedBox(
                      width: 150,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(90),
                        child: Image.network(
                          "https://upload.wikimedia.org/wikipedia/commons/b/b6/Image_created_with_a_mobile_phone.png",
                          width: 890,
                          height: 890,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${userDataModel?.name}",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      "${userDataModel?.email}",
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 15),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(),));
                      },
                      child: Text("Edit Profile"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<UserModel?> retrieveData() async {
    var auth = FirebaseAuth.instance.currentUser?.uid;
    var userDoc = await FirebaseFirestore.instance.collection("Users").doc(auth).get();
    if (userDoc.exists) {
      var userModel = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      return userModel;
    }
  }
}