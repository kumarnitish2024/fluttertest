import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testflutter/homepage.dart';
import 'package:testflutter/registerpage.dart';

import 'authservice.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  validate() {
    if(!_usernameController.text.contains(RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$'))){
      Fluttertoast.showToast(msg: 'Please enter valid  email contains @gmail.com');
    }
     else if (!_passwordController.text.contains(RegExp(r'[A-Za-z]'))){
      Fluttertoast.showToast(msg: 'Please Enter name');
    }
    else {
      _login();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRememberMeStatus();
  }

  _loadRememberMeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _usernameController.text = prefs.getString('username') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  _login() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );


      print('Logged in: ${userCredential.user?.email}');
    } catch (e) {
      // Handle authentication errors
      print('Error logging in: $e');

      // You can display an error message to the user or handle the error as needed.
    }
  }


  _saveRememberMeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      await prefs.remove('username');
      await prefs.remove('password');
    }
  }


  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    return Scaffold(
      body: ListView(
        children: [
          Padding(padding: EdgeInsets.only(top: 40, left: 32, right: 32),
            child: Padding(
              padding: const EdgeInsets.only(top: 90, left: 32, right: 32),
              child: Center(child: Text("Login",style: TextStyle(fontSize: 40,),)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 60, left: 32, right: 32),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange),
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: "Email Id",
                labelText: "Enter Your Email",
                hintStyle: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                labelStyle: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 30, left: 32, right: 32),
            child: TextField(
              obscureText: true,
              controller: _passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: "Password",
                labelText: "Enter your password",
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 32, top: 10),
            child: Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value!;
                    });
                  },
                ),
                Text('Remember Me'),
              ],
            ),
          ),

          SizedBox(
            width: screenWidth > 600 ? 60 : 30,
            height: 85,
            child: Padding(
              padding: const EdgeInsets.only(top: 38, left: 60, right: 60),
              child: ElevatedButton(
                onPressed: () {
                  _saveRememberMeStatus();
                  validate();
                },
                child: Text('Login'),
              ),
            ),
          ),

          SizedBox(
            height: 150,
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    // Call AuthService method to sign in with Google
                    final User? user = await AuthService().signInWithGoogle();
                    if (user != null) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(),));
                    } else {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(),));
                    }
                  },
                  child: Image.asset(
                    "assets/images/google.png",
                    width: screenWidth > 600 ? 90 : 70, // Adjust based on screen width
                    height: screenWidth > 600 ? 90 : 70, // Adjust based on screen width
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Image.asset(
                    "assets/images/Facebook.png",
                    width: screenWidth > 600 ? 70 : 50, // Adjust based on screen width
                    height: screenWidth > 600 ? 70 : 50, // Adjust based on screen width
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                const Text(
                  'New User?',
                  style: TextStyle(fontSize: 15),
                ),
                InkWell(
                  onTap: () {
                    Get.to(RegisterPage());
                  },
                  child: const Text(
                    ' SignUp',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
