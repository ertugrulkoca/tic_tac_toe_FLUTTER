import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../core/model/user_model.dart';
import '../../core/service/firebase_crud.dart';
import '../../core/service/google_signin.dart';

// ignore: must_be_immutable
class GameView extends StatefulWidget {
  String userId;
  GameView({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late UserModel user;
  @override
  void initState() {
    super.initState();
    user = UserModel();
    activateListeners();
  }

  void activateListeners() {
    FirebaseHelper.instance.getReference
        .child(widget.userId)
        .onValue
        .listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as dynamic);
      setState(() {
        data.forEach((key, value) {
          if (key == "computer_score") {
            computerScore = value;
          } else {
            playerScore = value;
          }
          user.userId = widget.userId;
          user.computerScore = computerScore;
          user.userScore = playerScore;
        });
      });
    });
  }

  final _random = Random();
  List<String> boxes = [
    "square",
    "square",
    "square",
    "square",
    "square",
    "square",
    "square",
    "square",
    "square"
  ];
  bool isFinish = false;
  int playerScore = 0, computerScore = 0;
  String lastValue = "o";
  List<int> playerChoice = [];
  List<int> computerChoice = [];
  List<int> emptyBox = [0, 1, 2, 3, 4, 5, 6, 7, 8];
  List correctLines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ];

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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    scores(),
                    closeIcon(context),
                  ],
                ),
                const SizedBox(height: 100),
                gridViewBuilder(screenSize)
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: signOutFAB(context),
    );
  }

  FloatingActionButton signOutFAB(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      child: const Icon(
        Icons.logout,
        color: Colors.blue,
        size: 30,
      ),
      onPressed: () {
        GoogleSignHepler.instance.sigOut();
        Navigator.pop(context);
      },
    );
  }

  Column scores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Scores:",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("Player: ${user.userScore}", style: const TextStyle(fontSize: 20)),
        Text("Computer: ${user.computerScore}",
            style: const TextStyle(fontSize: 20)),
      ],
    );
  }

  IconButton closeIcon(BuildContext context) {
    return IconButton(
      iconSize: 40,
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(
        Icons.cancel,
        color: Colors.white,
      ),
    );
  }

  SizedBox gridViewBuilder(Size screenSize) {
    return SizedBox(
      width: screenSize.width * 0.8,
      height: screenSize.height * 0.5,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemBuilder: (context, index) {
          return gridViewCard(index, context);
        },
      ),
    );
  }

  Widget gridViewCard(int index, BuildContext context) {
    return InkWell(
      onTap: () async {
        if (boxes[index] == "square" && isFinish == false) {
          playerPlays(index);
          if (!isPlayerWon()) {
            if (playerChoice.length + computerChoice.length == 9) {
              _whoIsTheWinner(context, "noWinner");
            } else {
              await Future.delayed(const Duration(milliseconds: 500));
              computerPlays();
              isComputerWon();
            }
          }
        }
      },
      child: Container(
        color: Colors.white,
        child: Image.asset("assets/${boxes[index]}.png"),
      ),
    );
  }
}

extension _GameController on _GameViewState {
  void playerPlays(int index) {
    playerChoice.add(index);
    emptyBox.remove(index);
    // ignore: invalid_use_of_protected_member
    setState(() {
      if (lastValue == "x") {
        boxes[index] = "o";
        lastValue = "o";
      } else {
        boxes[index] = "x";
        lastValue = "x";
      }
    });
  }

  void computerPlays() {
    if (emptyBox.isNotEmpty) {
      int cmpIndex = emptyBox[_random.nextInt(emptyBox.length)];
      computerChoice.add(cmpIndex);
      emptyBox.remove(cmpIndex);
      // ignore: invalid_use_of_protected_member
      setState(() {
        if (lastValue == "x") {
          boxes[cmpIndex] = "o";
          lastValue = "o";
        } else {
          boxes[cmpIndex] = "x";
          lastValue = "x";
        }
      });
    }
  }

  bool isPlayerWon() {
    for (var item in correctLines) {
      if (playerChoice.contains(item[0]) &&
          playerChoice.contains(item[1]) &&
          playerChoice.contains(item[2])) {
        user.userScore = user.userScore! + 1;
        FirebaseHelper.instance.scoreEkle(user: user);
        _whoIsTheWinner(context, "player");
        return true;
      }
    }
    return false;
  }

  bool isComputerWon() {
    for (var item in correctLines) {
      if (computerChoice.contains(item[0]) &&
          computerChoice.contains(item[1]) &&
          computerChoice.contains(item[2])) {
        user.computerScore = user.computerScore! + 1;
        FirebaseHelper.instance.scoreEkle(user: user);
        _whoIsTheWinner(context, "computer");
        return true;
      }
    }
    return false;
  }

  _whoIsTheWinner(context, String who) {
    String title, image;
    if (who == "player") {
      title = "";
      image = "win";
    } else if (who == "computer") {
      title = "";
      image = "lose";
    } else {
      title = "NO WINNER!";
      image = "handshake";
    }

    Alert(
      buttons: [
        DialogButton(
          onPressed: () {
            // ignore: invalid_use_of_protected_member
            setState(() {
              isFinish = false;
              lastValue = "o";
              boxes = [
                "square",
                "square",
                "square",
                "square",
                "square",
                "square",
                "square",
                "square",
                "square"
              ];

              playerChoice = [];
              emptyBox = [0, 1, 2, 3, 4, 5, 6, 7, 8];
              computerChoice = [];
              Navigator.pop(context);
            });
          },
          child: const Text(
            "PLAY AGAIN",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
      title: title,
      context: context,
      image: Image.asset("assets/$image.png"),
    ).show();
  }
}
