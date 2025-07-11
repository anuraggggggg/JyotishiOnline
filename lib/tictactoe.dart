import 'package:flutter/material.dart';

// void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  final String player1Name;
  final String player2Name;

  MyApp({required this.player1Name, required this.player2Name, Key? key})
      : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  List ofXO = List.generate(9, (index) => "");
  bool turn = true;

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TicTacToe',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Text('TicTacToe'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: turn ? Colors.green : Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text("X",
                            style: TextStyle(
                              fontSize: 25,
                            ))),
                  ),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: turn ? Colors.black : Colors.green),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text(
                      "Y",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    )),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  children: [
                    for (int i = 0; i < ofXO.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {});

                            if (ofXO[i] == "") {
                              if (turn) {
                                ofXO[i] = "X";
                                turn = false;
                              } else {
                                ofXO[i] = "O";
                                turn = true;
                              }
                            }
// For Horizontal
                            if (ofXO[0] == 'X' &&
                                ofXO[1] == 'X' &&
                                ofXO[2] == "X") {
                              print("X WON");
                              ofXO = List.generate(9, (index) => "");
                              turn = true;
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Game Over X won"),
                                    );
                                  });
                            }
                            ;

                            if (ofXO[6] == 'X' &&
                                ofXO[7] == 'X' &&
                                ofXO[8] == "X") {
                              print("X WON");
                              ofXO = List.generate(9, (index) => "");
                              turn = true;
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Game Over X won"),
                                    );
                                  });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Text(
                                ofXO[i],
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      )
                    ]
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  child: Text("Restart Game",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                      )),
                ),
              )
            ],
          )),
    );
  }
}
