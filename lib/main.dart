import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' show pi;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Matching Game')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 16,
        itemBuilder: (context, index) => CardWidget(index: index),
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final int index;

  const CardWidget({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return GestureDetector(
          onTap: () => gameState.flipCard(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(gameState.cards[index].isFaceUp ? pi : 0),
              child: Card(
                color: gameState.cards[index].isFaceUp ? Colors.white : Colors.blue,
                child: Center(
                  child: gameState.cards[index].isFaceUp
                      ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                    child: Text(
                          gameState.cards[index].value.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        )
                      )
                      : Image.asset(
                          'Acecard.png',
                          fit: BoxFit.cover, 
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class GameState with ChangeNotifier {
  List<CardModel> cards = [];
  int? firstCardIndex;

  GameState() {
    _initializeCards();
  }

  void _initializeCards() {
    List<int> values = List.generate(8, (index) => index + 1)..addAll(List.generate(8, (index) => index + 1));
    values.shuffle();
    cards = List.generate(16, (index) => CardModel(value: values[index]));
  }

  void flipCard(int index) {
    if (cards[index].isFaceUp) return;

    cards[index].isFaceUp = true;
    notifyListeners();

    if (firstCardIndex == null) {
      firstCardIndex = index;
    } else {
      _checkMatch(firstCardIndex!, index);
    }
  }

  void _checkMatch(int index1, int index2) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (cards[index1].value != cards[index2].value) {
        cards[index1].isFaceUp = false;
        cards[index2].isFaceUp = false;
      }
      firstCardIndex = null;
      notifyListeners();
    });
  }
}

class CardModel {
  final int value;
  bool isFaceUp = false;

  CardModel({required this.value});
}