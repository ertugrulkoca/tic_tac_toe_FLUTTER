import 'dart:collection';
import 'package:firebase_database/firebase_database.dart';
import '../model/user_model.dart';

class FirebaseHelper {
  static final FirebaseHelper _instance = FirebaseHelper._private();
  FirebaseHelper._private();
  static FirebaseHelper get instance => _instance;
  final _refScores = FirebaseDatabase.instance.ref().child("Scores");

  DatabaseReference get getReference => _refScores;

  Future<void> scoreEkle({required UserModel user}) async {
    var values = HashMap<String, dynamic>();
    values["computer_score"] = user.computerScore;
    values["user_score"] = user.userScore;
    await _refScores.child(user.userId!).set(values);
  }

  Future<void> scoreSifirla({required String userId}) async {
    var values = HashMap<String, dynamic>();
    values["user_score"] = 0;
    values["computer_score"] = 0;
    await _refScores.child(userId).update(values);
  }
}
