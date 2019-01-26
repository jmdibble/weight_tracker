import 'package:firebase_auth/firebase_auth.dart';
import 'package:scoped_model/scoped_model.dart';

class AppState extends Model {
  FirebaseUser _user;

  set user(FirebaseUser value) {
    _user = value;
    notifyListeners();
  }

  String get uid => _user?.uid;
}