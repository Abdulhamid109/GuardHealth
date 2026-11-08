import 'package:flutter/material.dart';

class BLESetupScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<BLESetupScreen> createState() => _BLESetupScreenState();
}

class _BLESetupScreenState extends State<BLESetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //developement purpose
              ElevatedButton(onPressed: (){}, child: Text("start ble device connection")),
              
            ],
          ),
        ),
      ),
    );
  }
}