// ignore_for_file: missing_return

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermission = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermission = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            if (_hasPermission) {
              return _buildCompass();
            } else {
              return _buildPermissionSheet();
            }
          },
        ),
      ),
    );
  }

  //compass widget
  Widget _buildCompass() {
    return StreamBuilder(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        //error
        if (snapshot.hasError) {
          return Text("Error reading heading: ${snapshot.error}");
        }

        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double direction = snapshot.data.heading;

        if (direction == null) {
          return Center(
            child: Text("device does not support sensors"),
          );
        }

        //return compass
        return Center(
          child: Container(
            padding: EdgeInsets.all(25),
            child: Transform.rotate(
              angle: direction * (math.pi / 180) * -1,
              child: Image.asset(
                "assets/compass.png",
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  //permission
  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: const Text("Request Permission"),
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            _fetchPermissionStatus();
          });
        },
      ),
    );
  }
}
