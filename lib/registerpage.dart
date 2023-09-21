import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:testflutter/homepage.dart';

import 'loginpage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _Entername = TextEditingController();
  TextEditingController _Enteremail = TextEditingController();
  TextEditingController _Enterpassword = TextEditingController();

  validate() {
    if (_Entername.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill in your name');
    }
    else if(_Entername.text.length < 3) {
      Fluttertoast.showToast(msg: 'Name must be at least 3 characters');
    } else if (!_Enteremail.text.contains("@gmail.com")) {
      Fluttertoast.showToast(msg: "Please fill email");
    }else if (!_Enteremail.text.contains(RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$'))) {
      Fluttertoast.showToast(msg: 'Please enter valid  email contains @gmail.com');
    }
    else if (_Enterpassword.text.length <= 6) {
      Fluttertoast.showToast(msg: "password must be at least 6 characters");
    } else {
      emailAuth();
    }
  }

  emailAuth() {
    FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _Enteremail.text, password: _Enterpassword.text)
        .then((value){
      UserDate();
      Fluttertoast.showToast(msg: "EmailAuth success");
    });
  }

  UserDate(){
    var Auth = FirebaseAuth.instance.currentUser?.uid;
    FirebaseFirestore.instance.collection("Users").doc(Auth).set({
      "name": _Entername.text,
      "email": _Enteremail.text,
      "password": _Enterpassword.text,
    }).then((value) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(),));
      Fluttertoast.showToast(msg: "successfuly",);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.only(top: 110, left: 130, right: 130),
          child: Text(
            'Sing Up Now',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 80, left: 30, right: 40),
          child: TextField(
              keyboardType: TextInputType.text,
              controller: _Entername,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                  hintText: "Enter Name")),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, left: 30, right: 40),
          child: TextField(
              keyboardType: TextInputType.emailAddress,
              controller: _Enteremail,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                  hintText: "Enter Email")),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, left: 30, right: 40),
          child: TextField(
              keyboardType: TextInputType.visiblePassword,
              controller: _Enterpassword,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                  hintText: "Enter Password")),
        ),


        Padding(
          padding: const EdgeInsets.only(left: 60, right: 60, top: 70),
          child: ElevatedButton(
            onPressed: () {
              validate();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              shape: StadiumBorder(),
            ),

            child: const Text(
              "Sing Up",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an Account?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),

              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ));
                },
                child: const Text(
                  " Sing In",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}



