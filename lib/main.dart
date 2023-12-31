import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  //const MyHomePage({Key? key, required this.title}) : super(key: key);
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  initState() {
    super.initState();
    fetchHealthData();
  }
  int _getSteps = 0;
  List<HealthDataPoint> _healthDataList = [];
  HealthFactory health = HealthFactory();

  Future sendRequest() async{
    String jsonData = jsonEncode(_healthDataList.map((data) => data.toJson()).toList());
    await http.post(
      Uri.parse('http://localhost:5000/health'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );
  }

  Future fetchHealthData() async {
    int? steps; // initialize necessary health variables
    List<HealthDataPoint>? healthDataList;

    var types = [
      HealthDataType.HEART_RATE,
      HealthDataType.ELECTRODERMAL_ACTIVITY,
      HealthDataType.RESTING_HEART_RATE,
      HealthDataType.WALKING_HEART_RATE,
      HealthDataType.HEADACHE_NOT_PRESENT,
      HealthDataType.HEADACHE_MILD,
      HealthDataType.HEADACHE_SEVERE,
      HealthDataType.AUDIOGRAM,
    ];

    // get steps for today (since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    var permissions = types.map((e) => HealthDataAccess.READ).toList(); // dynamically getting permissions

    bool requested = await health.requestAuthorization(types, permissions: permissions);

    if (requested) {
      try {
        // get the number of steps for today
        healthDataList = await health.getHealthDataFromTypes(midnight, now, types);
        print("Health Data List: $healthDataList");

        // get other health values from health - assign it to health values previously constructed
        steps = await health.getTotalStepsInInterval(midnight, now);
        print("Total number of steps: $steps");
      } catch (error) {
        print ("Caught exception in getTotalStepsInInterval: $error");
      }


      setState(() {
        _getSteps = (steps == null) ? 0 : steps;
        _healthDataList = (healthDataList == null) ? []: healthDataList;
      });
    } else {
      print("Authorization not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      body: Center(
        //child: Text(
        //  'Total step   {$_getSteps}',
        //),
        child: ElevatedButton(
          onPressed:  () async{
            await sendRequest();
          },
          child: const Text('Send Request'),
        ),
      ),
    );
  }
}
