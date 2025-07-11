import 'package:AstrowayCustomer/tictactoe.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: PlayerDetailPage()));

class PlayerDetailPage extends StatefulWidget {
  const PlayerDetailPage({super.key});

  @override
  State<PlayerDetailPage> createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Player Details'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Enter Player One Name")),
                TextField(
                  controller: player1Controller,
                  decoration: InputDecoration(
                    labelText: 'Player 1 Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Enter Player two Name")),
                TextField(
                  controller: player2Controller,
                  decoration: InputDecoration(
                    labelText: 'Player 2 Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {});

                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MyApp(
                        player1Name: player1Controller.text,
                        player2Name: player2Controller.text,
                      );
                    }));
                  },
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Text(
                      "Enter",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  player1Controller.text + " vs " + player2Controller.text,
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
