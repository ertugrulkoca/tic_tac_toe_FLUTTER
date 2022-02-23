import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../helper/shared_manager.dart';

class GoogleSignHepler {
  static final GoogleSignHepler _instance = GoogleSignHepler._private();
  GoogleSignHepler._private();
  static GoogleSignHepler get instance => _instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<GoogleSignInAccount?> singIn() async {
    final user = await _googleSignIn.signIn();
    if (user != null) {
      return user;
    }
    return null;
  }

  Future<GoogleSignInAuthentication?> googleAuthentication() async {
    if (await _googleSignIn.isSignedIn()) {
      final user = _googleSignIn.currentUser;
      final userData = await user!.authentication;
      return userData;
    }
    return null;
  }

  Future<GoogleSignInAccount?> sigOut() async {
    final user = await _googleSignIn.signOut();
    if (user != null) {
      return user;
    }
    return null;
  }

  Future<UserCredential> firebaseSignin() async {
    GoogleSignInAuthentication? googleAuth = await googleAuthentication();
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth!.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential user =
        await FirebaseAuth.instance.signInWithCredential(credential);

    var token = await user.user!.getIdToken();
    var userId = user.user!.uid;
    await SharedManager.instance.saveString(SharedKeys.TOKEN, token.toString());
    await SharedManager.instance.saveString(SharedKeys.USERID, userId);
    return user;
  }
}
