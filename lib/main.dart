import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const batteryChannel = MethodChannel('samples.flutter.dev/battery');
  static const machineLearningChannel =
      MethodChannel('samples.neuron.face/tools');

  String _batteryLevel = 'Unknown battery level';
  String _machineVersion = "Machine init...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
                onPressed: _getBatteryLevel,
                child: const Text('Get Battery Level')),
            Text(
              _batteryLevel,
              style: const TextStyle(fontSize: 16.0),
            ),
            ElevatedButton(
                onPressed: _getMachineVersion,
                child: const Text('Get Machine')),
            Text(
              _machineVersion,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await batteryChannel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _getMachineVersion() async {
    String mV;
    try {
      final String result =
          await machineLearningChannel.invokeMethod('getMachineVersion');
      mV = result;
    } catch (e) {
      mV = "Machine not found";
    }
    setState(() {
      _machineVersion = mV;
    });
  }
}
