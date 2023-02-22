import 'package:flutter/material.dart';

class UnlockPage extends StatefulWidget {
  const UnlockPage({super.key});

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  TextStyle mainText = const TextStyle(fontSize: 32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const UnlockInfo(),
          ElevatedButton(
            onPressed: () {},
            style: ButtonStyle(
              shape: MaterialStateProperty.all(const CircleBorder()),
              padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.blueGrey;
                }
                return null;
              }),
            ),
            child: const Icon(Icons.lock_open_outlined),
          )
        ]),
      ),
    );
  }
}

class UnlockInfo extends StatefulWidget {
  const UnlockInfo({super.key});

  @override
  State<UnlockInfo> createState() => _UnlockInfoState();
}

class _UnlockInfoState extends State<UnlockInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          "Unlock Page",
          style: TextStyle(fontSize: 32),
        ),
        Text("Bike Lock Location: "),
        Text("Bike Lock Owner: ")
      ],
    );
  }
}
