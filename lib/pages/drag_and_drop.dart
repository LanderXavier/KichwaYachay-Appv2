import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() => runApp(const WordOrderingGame());

class WordOrderingGame extends StatelessWidget {
  const WordOrderingGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Ordene las palabras correctamente",
      home: WordOrderingHomePage(),
    );
  }
}

class WordOrderingHomePage extends StatefulWidget {
  const WordOrderingHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WordOrderingHomePageState createState() => _WordOrderingHomePageState();
}

class _WordOrderingHomePageState extends State<WordOrderingHomePage> {
  List<String> targetWords = [];
  List<String> scrambledWords = [];
  List<String> userOrder = [];
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _loadQuestionData();
  }

  // Cargar los datos JSON desde el archivo
  Future<void> _loadQuestionData() async {
    final String response = await rootBundle.loadString('assets/database/your_questions.json');
    final List<dynamic> data = json.decode(response);

    // Aquí tomamos solo el primer objeto del JSON como ejemplo
    var questionData = data[0]; // Suponiendo que quieres cargar la primera pregunta
    
    setState(() {
      targetWords = List<String>.from(questionData['correctOrder']);
      scrambledWords = List<String>.from(targetWords)..shuffle();
      userOrder = [];
      gameOver = false; // Aseguramos que el estado del juego se reinicia
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!gameOver) ...[
              const Text(
                '',
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: scrambledWords.map((word) {
                  return Draggable<String>(  // Hacer que cada palabra sea arrastrable
                    data: word,
                    childWhenDragging: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey,
                      ),
                      child: Text(
                        word,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                    feedback: Material(
                      color: Colors.transparent,
                      child: Text(
                        word,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.teal,
                      ),
                      child: Text(
                        word,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              DragTarget<String>(  // Área de destino para las palabras ordenadas
                onAccept: (word) {
                  setState(() {
                    userOrder.add(word);
                    scrambledWords.remove(word);

                    if (userOrder.length == targetWords.length) {
                      gameOver = true;
                    }
                  });
                },
                builder: (context, acceptedData, rejectedData) {
                  return Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                    child: Row(
                      children: userOrder.map((word) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            word,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ] else ...[
              Text(
                userOrder.join(" ") == targetWords.join(" ")
                    ? "Well done! You ordered the words correctly."
                    : "Oops! Try again!",
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loadQuestionData();
                  });
                },
                child: const Text("Play Again"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
