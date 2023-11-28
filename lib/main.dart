import 'package:flutter/material.dart';
import 'package:health/health.dart';

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
    fetchStepData();
  }
  int _getSteps = 0;
  HealthFactory health = HealthFactory();

  Future fetchStepData() async {
    int? steps; // initialize necessary health variables

    var types = [
      HealthDataType.STEPS,
    ];

    // get steps for today (since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    var permissions = [
      HealthDataAccess.READ,
    ];

    bool requested = await health.requestAuthorization(types, permissions: permissions);

    if (requested) {
      try {
        // get the number of steps for today

        // get other health values from health - assign it to health values previously constructed
        steps = await health.getTotalStepsInInterval(midnight, now);
        print("Total number of steps: $steps");
      } catch (error) {
        print ("Caught exception in getTotalStepsInInterval: $error");
      }


      setState(() {
        _getSteps = (steps == null) ? 0 : steps;
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
        child: Text(
          'Total step   {$_getSteps}',
        ),
      ),
    );
  }
}
