import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:weight_tracker/models/app_state.dart';
import 'package:weight_tracker/screens/splash.dart';

class WeightTrackerApp extends StatefulWidget {
  @override
  WeightTrackerAppState createState() => WeightTrackerAppState();
}

class WeightTrackerAppState extends State<WeightTrackerApp> {

  final _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppState>(
      model: _appState,
      child: MaterialApp(
        title: 'Weight Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
