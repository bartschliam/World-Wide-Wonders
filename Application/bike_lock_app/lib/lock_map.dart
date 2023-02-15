import 'package:flutter/material.dart';

class LockMap extends StatefulWidget {
  const LockMap({super.key});

  @override
  State<LockMap> createState() => _LockMapState();
}

class _LockMapState extends State<LockMap> {
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/ui_map.JPG');
  }
}
