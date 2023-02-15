import 'package:bike_lock_app/signup_page.dart';
import 'package:bike_lock_app/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Bike Lock Login Page'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Center(
              child: SizedBox(
                width: 200,
                height: 150,
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: userNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Forgot Password',
              style: TextStyle(color: Colors.blue, fontSize: 15),
            ),
          ),
          Container(
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(20)),
            child: TextButton(
              child: const Text(
                "Login",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              onPressed: () async {
                debugPrint("login");
                var username = userNameController.text;
                var passsword = passwordController.text;

                int statusCode = await validUsernameAndPassword(
                    username: username, passsword: passsword);

                if (statusCode == 202) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }
              },
            ),
          ),
          const SizedBox(
            height: 130,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            },
            child: const Text('New User? Create Account'),
          ),
        ],
      )),
    );
  }

  Future<int> validUsernameAndPassword(
      {required String username, required String passsword}) async {
    final ref = FirebaseFirestore.instance
        .collection("Users")
        .doc(username)
        .withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (User user, _) => user.toFirestore(),
        );

    final docSnap = await ref.get();
    final user = docSnap.data();

    if (user != null) {
      if (user.password == passsword) {
        debugPrint("User does exist and password IS CORRECT!");
        return 202;
      } else {
        debugPrint("User does exist but WRONG PASSWORD!");
        return 401;
      }
    }
    debugPrint("User does not exist!");
    return 500;
  }
}
