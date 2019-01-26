
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:weight_tracker/models/app_state.dart';
import 'package:weight_tracker/screens/home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future _loading;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _loading = _load();
  }

  Future<void> _load() async {
    await Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
    var user = await FirebaseAuth.instance.currentUser();
    if(user == null) {
      user = await FirebaseAuth.instance.signInAnonymously();
    }
    print('loaded with user: ${user.uid}');
    if(mounted) {
      final appState = ScopedModel.of<AppState>(context);
      appState.user = user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loading,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        else if(snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        else {
          if(!_navigating) {
            _navigating = true;
            scheduleMicrotask(() => Navigator.of(context).pushReplacement(HomeScreen.route()));
          }
          return SizedBox();
        }
      },
    );
  }
}
