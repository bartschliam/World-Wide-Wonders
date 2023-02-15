import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
        title: const Text('IoT Bike Lock Signup Page'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 60.0),
            child: Center(
                child: Text("Welcome, we're glad to have you on board!")),
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
          Container(
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(20)),
            child: TextButton(
              child: const Text(
                "Sign Up",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              onPressed: () {
                final username = userNameController.text;
                final password = passwordController.text;

                createUser(username: username, password: password);
              },
            ),
          ),
          const SizedBox(
            height: 130,
          ),
        ],
      )),
    );
  }

  Future createUser(
      {required String username, required String password}) async {
    final docUser =
        FirebaseFirestore.instance.collection("Users").doc(username);

    final userData = {"username": username, "password": password};
    await docUser.set(userData);
  }
}
