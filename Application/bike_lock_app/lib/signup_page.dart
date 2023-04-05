import 'package:bike_lock_app/login.dart';
import 'package:bike_lock_app/user.dart';
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

  bool invalidUsername = false;
  bool invalidPassword = false;
  String usernameErrorMSG = "";
  String passwordErrorMSG = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
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
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Email',
                errorText: invalidUsername ? usernameErrorMSG : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: passwordController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Password',
                errorText: invalidPassword ? passwordErrorMSG : null,
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
              onPressed: () async {
                final username = userNameController.text;
                final password = passwordController.text;

                if (validateUsernameAndPassword(username, password)) {
                  if (await checkUserExists(username)) {
                    setState(() {
                      invalidUsername = true;
                      usernameErrorMSG = "User already exists, please log in";
                    });
                  } else {
                    await createUser(username: username, password: password);
                    navigator.push(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  }
                }
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

    final userData = {
      "Credentials": {"username": username, "password": password},
      "Friends": {"friends": {}, "request_in": {}, "request_out": {}}
    };
    await docUser.set(userData);
  }

  Future<bool> checkUserExists(String username) async {
    final ref = FirebaseFirestore.instance
        .collection("Users")
        .doc(username)
        .withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (User user, _) => user.toFirestore(),
        );

    final docSnap = await ref.get();
    final user = docSnap.data();

    return user != null;
  }

  bool validateUsernameAndPassword(String username, String password) {
    if (username == "") {
      setState(() {
        usernameErrorMSG = "Invalid username, cannnot be blank";
        invalidUsername = true;
      });
    }
    if (password == "") {
      setState(() {
        passwordErrorMSG = "Invalid password, cannnot be blank";
        invalidPassword = true;
      });
    }

    return !(username == "" || password == "");
  }
}
