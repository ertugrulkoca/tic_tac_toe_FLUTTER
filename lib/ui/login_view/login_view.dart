import 'package:flutter/material.dart';
import 'package:tic_tac_toe/core/service/google_signin.dart';
import 'package:tic_tac_toe/ui/game_view/game_view.dart';
import '../../core/helper/shared_manager.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((val) {
      if (SharedManager.instance.getStringValue(SharedKeys.TOKEN).isEmpty) {
        String userId =
            SharedManager.instance.getStringValue(SharedKeys.USERID);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameView(
                      userId: userId,
                    )));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/background.png"),
                  fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              headerText(),
              container(context),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      floatingActionButton: signOutFAB(),
    );
  }

  Container container(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
      ),
      height: 200,
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "Signin with Google",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          signButton(context),
        ],
      ),
    );
  }

  ElevatedButton signButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Colors.blue.shade400,
          padding:
              const EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15)),
      onPressed: () async {
        var data = await GoogleSignHepler.instance.singIn();
        if (data != null) {
          var userData = await GoogleSignHepler.instance.firebaseSignin();
          // print(userData.user?.uid);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GameView(
                        userId: userData.user!.uid,
                      )));
        }
      },
      child: const Text(
        "Sign In",
        style: TextStyle(fontSize: 26),
      ),
    );
  }

  Text headerText() {
    return const Text("Tic-Tac-Toe",
        style: TextStyle(fontSize: 30, color: Colors.white));
  }

  FloatingActionButton signOutFAB() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      child: const Icon(
        Icons.logout,
        color: Colors.blue,
        size: 30,
      ),
      onPressed: () {
        GoogleSignHepler.instance.sigOut();
      },
    );
  }
}
