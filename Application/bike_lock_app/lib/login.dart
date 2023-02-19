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

  bool promptIncorrectPassword = false;

  bool incorrectUsername = false;
  bool incorrectPassword = false;
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
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: userNameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'email',
                errorText: incorrectUsername ? usernameErrorMSG : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: passwordController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'password',
                errorText: incorrectPassword ? passwordErrorMSG : null,
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
                var username = userNameController.text;
                var passsword = passwordController.text;

                if (validateUsernameAndPassword(username, passsword)) {
                  int statusCode = await checkUsernameAndPassword(
                      username: username, passsword: passsword);

                  if (statusCode == 202) {
                    setState(() {
                      incorrectUsername = false;
                      incorrectPassword = false;
                    });
                    userNameController.clear();
                    passwordController.clear();

                    User currentUser = await getUser(username);

                    navigator.push(
                      MaterialPageRoute(
                          builder: (context) =>
                              HomePage(currentUser: currentUser)),
                    );
                  } else if (statusCode == 401) {
                    setState(() {
                      passwordErrorMSG = "Incorrect password, please try again";
                      incorrectPassword = true;
                    });
                    passwordController.clear();
                  } else {
                    setState(() {
                      usernameErrorMSG = "User does not exist, please sign up!";
                      incorrectUsername = true;
                    });
                    userNameController.clear();
                  }
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

  Future<int> checkUsernameAndPassword(
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
    } else {
      debugPrint("User does not exist!");
      return 500;
    }
  }

  bool validateUsernameAndPassword(String username, String password) {
    if (username == "") {
      setState(() {
        usernameErrorMSG = "Invalid username, cannnot be blank";
        incorrectUsername = true;
      });
    }
    if (password == "") {
      setState(() {
        passwordErrorMSG = "Invalid password, cannnot be blank";
        incorrectPassword = true;
      });
    }

    return !(username == "" || password == "");
  }

  Future<User> getUser(String username) async {
    final ref = FirebaseFirestore.instance
        .collection("Users")
        .doc(username)
        .withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (User user, _) => user.toFirestore(),
        );

    final docSnap = await ref.get();
    final user = docSnap.data();

    return User(
        username: user?.username,
        password: user?.password,
        friends: user?.friends);
  }
}
