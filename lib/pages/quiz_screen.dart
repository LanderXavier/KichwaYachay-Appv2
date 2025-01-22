  import 'package:flutter/material.dart';
  import 'package:language_learning_ui/constants.dart';
  import 'package:language_learning_ui/models/question_model.dart';
  import 'package:audioplayers/audioplayers.dart';

  class QuizScreen extends StatefulWidget {
    final int unity;
    final String lesson;
    final List<Question> questions;

    const QuizScreen({
      Key? key,
      required this.unity,
      required this.lesson,
      required this.questions,
    }) : super(key: key);

    @override
    // ignore: library_private_types_in_public_api
    _QuizScreenState createState() => _QuizScreenState();
  }

  class _QuizScreenState extends State<QuizScreen> {
    late int _questionIndex = 0;
    late Question _currentQuestion;
    List<bool> _selectedOptions = [];
    // Multiple Option Variables
    int _selectedMultipleChoice = -1;
    // Trasnlate Variables
    List<bool> _selectedTranslate = [];
    // Vertical Sort Variables
    List<String> _wordsList = [];
    // Audio Player
    final player = AudioPlayer();
    // Flashcard Variables
    String? _selectedFlashcardAnswer; 

    @override
    void initState() {
      super.initState();
      _selectedMultipleChoice = -1; // Inicializa el valor al crear la pantalla
      _currentQuestion = widget.questions[_questionIndex];
      _selectedOptions =
          List.generate(_currentQuestion.optionList.length, (index) => false);
    }

    // Opción Múltiple
    List<Column> _buildMultipleChoice(
        List<String> options, Function(int?) onChanged) {
      return options.asMap().entries.map((entry) {
        return Column(
          children: [
            RadioListTile<int>(
              title: Text(
                options[entry.key],
                style: const TextStyle(color: Colors.black, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              value: entry.key,
              groupValue: _selectedMultipleChoice,
              // Imágen, activar cuando se tengan todas las imágenes sobre las opciones.
              // Alternativamente, se puede ingresar una sola imágen fuera del RadioListTile
              // La imágen que se usaría sería la que está en el Json
              // secondary: Image(
              //     image: AssetImage(
              //         'assets/images/unity_${widget.unity}/lesson_${widget.lesson}/${options[entry.key]}.png')),
              onChanged: (int? value) {
                setState(() {
                  _selectedMultipleChoice = value!;
                });
                onChanged(value);
              },
            ),
            const Divider(height: 50),
          ],
        );
      }).toList();
    }

    // Seleccionar
    List<Widget> _buildSelectAndSort(
        List<String> shuffledWords, List<String> correctWords) {
      // Initialize _selectedWords with all false values if it's not initialized yet
      if (_selectedTranslate.length != shuffledWords.length) {
        _selectedTranslate =
            List.generate(shuffledWords.length, (index) => false);
      }
      return [
        const SizedBox(
          height: 10,
        ),
        const Text(
          'Selecciona las palabras correctas:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(
          height: 10,
        ),
        ...shuffledWords.asMap().entries.map((entry) {
          return CheckboxListTile(
            title: Text(shuffledWords[entry.key]),
            value: _selectedTranslate[entry.key],
            // secondary: Image.asset(
            //   'images/unity_${widget.unity}/lesson_${widget.lesson}/${shuffledWords[entry.key]}.png',
            //   height: 10.0,
            //   width: 10.0,
            // ),
            onChanged: (value) {
              setState(() {
                _selectedTranslate[entry.key] = value!;
              });
            },
          );
        }).toList(),
      ];
    }

    // Escuchar y Traducir
    List<Widget> _buildListenAndTranslate(
        String question, List<String> options, Function(int?) onChanged) {
      return [
        Column(
          children: [
            // Text(
            //   _currentQuestion.questionSpanish,
            //   style: const TextStyle(color: Colors.black, fontSize: 20),
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 0),
            InkWell(
              onTap: () async {
                await player.play(AssetSource(
                    'assets/audios/unity_${widget.unity}/lesson_${widget.lesson}/${_currentQuestion.audioPath}'));
              },
              child: const Icon(
                Icons.play_circle_fill_outlined,
                size: 60,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ...options.asMap().entries.map((entry) {
              return Column(
                children: [
                  RadioListTile<int>(
                    title: Text(
                      options[entry.key],
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                      textAlign: TextAlign.left,
                    ),
                    value: entry.key,
                    groupValue: _selectedMultipleChoice,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedMultipleChoice = value!;
                      });
                      onChanged(value);
                    },
                  ),
                  const Divider(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ];
    }

  // Drag and drop
  List<Widget> _buildMatch(List<String> words, List<String> correctOrder) {
    List<String> availableWords = List.from(words); // Lista para las palabras disponibles
    List<String> draggedWords = []; // Lista para las palabras arrastradas
    List<String> correctOrde = List.from(correctOrder); // Lista para las palabras arrastradas

    return [
      const SizedBox(height: 20),
      const Text(
        'Une las palabras correctamente:',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 20),

      // Lista de palabras que se pueden arrastrar
      Wrap(
        children: List<Widget>.generate(availableWords.length, (index) {
          return Draggable<String>(
            data: availableWords[index],
            feedback: Material(
              color: Colors.transparent,
              child: Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  availableWords[index],
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ),
            childWhenDragging: Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                availableWords[index],
                style: const TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            child: Container(
              key: Key(availableWords[index]),
              width: 100,
              height: 100,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                availableWords[index],
                style: const TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),

      // Área de destino donde se arrastran las palabras
      Wrap(
        children: List<Widget>.generate(words.length, (index) {
          return DragTarget<String>(
            onAccept: (receivedWord) {
              if (!draggedWords.contains(receivedWord)) {
                draggedWords.add(receivedWord);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: candidateData.isNotEmpty ? Colors.green : Colors.black,
                    width: 2,
                  ),
                ),
                child: Text(
                  index < draggedWords.length ? draggedWords[index] : '',
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              );
            },
          );
        }).toList(),
      ),

      const SizedBox(height: 20),
//BOTON DE VERIFICAR
      ElevatedButton(
  onPressed: () {
    bool isCorrect = draggedWords.length == correctOrder.length &&
        List.generate(correctOrder.length, (i) => draggedWords[i] == correctOrder[i])
            .every((element) => element);
    print("Palabras arrastradas: $draggedWords");
    print("Orden correcto: $correctOrde");

    // Muestra el resultado
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? '¡Correcto!' : 'Inténtalo de nuevo'),
        content: Text(isCorrect
            ? '¡Has ordenado correctamente las palabras!'
            : 'El orden no es correcto. Por favor, inténtalo de nuevo.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (!isCorrect) {
                setState(() {
                  draggedWords.clear(); // Limpia las palabras arrastradas
                });
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  },
  child: const Text('Verificar'),
),

    ];
  }


    // Ordenar verticalmente arrastrando
    List<Widget> _buildVerticalSort(
        List<String> words, List<String> correctOrder) {
      return [
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Ordena las palabras para formar la frase correcta:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 20,
        ),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: words.asMap().entries.map((entry) {
            return ListTile(
              key: Key(entry.key.toString()),
              title: Text(
                words[entry.key],
                style: const TextStyle(color: Colors.black, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              trailing: ReorderableDragStartListener(
                index: entry.key,
                child: const Icon(Icons.drag_handle),
              ),
            );
          }).toList(),
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final String item = words.removeAt(oldIndex);
              words.insert(newIndex, item);
              _wordsList = words;
            });
          },
        ),
      ];
    }

    bool _listEquals(List list1, List list2) {
      int count = 0;
      for (int i = 0; i < list1.length; i++) {
        if (list1[i].toString() == list2[i].toString() &&
            list1.length == list2.length) {
          count++;
        }
      }
      if (count == list2.length) {
        return true;
      } else {
        return false;
      }
    }

// FLASHCARDS

void _showQuestionDialog(BuildContext context, String questionText, String imagePath) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Pregunta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mostrar la imagen
            Image.asset(
              imagePath, // Ruta de la imagen
              height: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            // Mostrar la pregunta
            Text(
              questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
            },
            child: const Text("Cerrar"),
          ),
        ],
      );
    },
  );
}

// Construcción del contenido para las preguntas con botón adicional
List<Widget> _buildFlashcards(Question question) {
  final words = question.words ?? [];

  return [
    const SizedBox(height: 10),
    const Text(
      'Mira las flashcards:',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    ),
    const SizedBox(height: 10),
    Expanded(
      child: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          final parts = words[index].split(':');
          final imagePath = parts[0];
          final label = parts[1];

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      imagePath,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),

    const SizedBox(height: 20),
        // Botón dinámico basado en "questionSpanish"
    ElevatedButton(
      onPressed: () {
        _showQuestionDialog(context, question.questionSpanish, question.imagePath); // Mostrar imagen y pregunta
      },
      child: const Text("Mostrar pregunta"), // Texto del botón
    ),

    
    const SizedBox(height: 20),

    // Opciones de respuesta
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: question.optionList.map((option) {
        final isSelected = _selectedFlashcardAnswer == option; // Verificar si esta opción está seleccionada
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: isSelected ? Colors.green : Colors.blue, // Cambia el color si está seleccionada
              onPrimary: Colors.white, // Color del texto
            ),
            onPressed: () {
              setState(() {
                _selectedFlashcardAnswer = option; // Guardar la respuesta seleccionada
              });
              print("Seleccionado: $option");
            },
            child: Text(option),
          ),
        );
      }).toList(),
    ),
  ];
}


    // Function to check weather the answer is correct or not
    // Points will be added according to the number of correct answers
    // NOTE: Replace the print statements to another function which can take count of the punctuation
    void _checkAnswer() {
      // Multiple Choice Handler
      if (_currentQuestion.questionType == 'multiple_choice') {
        int correctOptionIndex =
            _currentQuestion.optionList.indexOf(_currentQuestion.correctAnswer);
        if (_selectedMultipleChoice == correctOptionIndex) {
          print('Respuesta correcta');
        } else {
          print('Respuesta incorrecta');
        }
        // Translate Handler
      } else if (_currentQuestion.questionType == 'translate') {
        bool isCorrect = false;
        // print("Selected: $_selectedTranslate");
        // print("Correct: ${_currentQuestion.correctOrder}");
        if (_listEquals(_selectedTranslate, _currentQuestion.correctOrder)) {
          isCorrect = true;
        }
        if (isCorrect) {
          print('Respuesta correcta');
        } else {
          print('Respuesta incorrecta');
        }
      } else if (_currentQuestion.questionType == 'vertical_sort') {
        bool isCorrect = false;
        // print("Selected: $_wordsList");
        // print("Correct: ${_currentQuestion.correctOrder}");
        if (_listEquals(_wordsList, _currentQuestion.correctOrder)) {
          isCorrect = true;
        }
        if (isCorrect) {
          print('Respuesta correcta');
        } else {
          print('Respuesta incorrecta');
        }
        // Listen and Translate Handler
      } else if (_currentQuestion.questionType == 'listen_and_translate') {
        int correctOptionIndex =
            _currentQuestion.optionList.indexOf(_currentQuestion.correctAnswer);
        if (_selectedMultipleChoice == correctOptionIndex) {
          print('Respuesta correcta');
        } else {
          print('Respuesta incorrecta');
        }
        // Drag and Drop Handler
      } else if (_currentQuestion.questionType == 'drag_and_drop') {
        int correctOptionIndex =
            _currentQuestion.optionList.indexOf(_currentQuestion.correctAnswer);
        if (_selectedMultipleChoice == correctOptionIndex) {
          print('Respuesta correcta');
        } else {
          print('Respuesta incorrecta');
        }
      
      // Flashcard Handler (Asegúrate de que este es el tipo de pregunta adecuado)

      }  else if (_currentQuestion.questionType == 'flashcard_question') {
      if (_selectedFlashcardAnswer == _currentQuestion.correctAnswer) {
        print('Respuesta correcta');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Respuesta correcta')),
        );
      } else {
        print('Respuesta incorrecta');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Respuesta Incorrecta')),
        );
      }
    }

      _nextQuestion();
    }

    void _nextQuestion() {
      setState(() {
        _questionIndex++;
        if (_questionIndex < widget.questions.length) {
          _currentQuestion = widget.questions[_questionIndex];
          _selectedOptions =
              List.generate(_currentQuestion.optionList.length, (index) => false);
              _selectedMultipleChoice = -1; // Reinicia si usas selección múltiple
        } else {
          // Agregar alguna lógica adicional cuando se han recorrido todas las preguntas
          print('Se han recorrido todas las preguntas');
        }
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Lección ${widget.lesson}'),
          backgroundColor: Constants.redKY,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(
                _currentQuestion.questionSpanish,
                style: const TextStyle(color: Colors.black, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 50,
              ),
              // Asegurarse de que la pregunta no esté vacía
              if (_currentQuestion.questionKichwa.isNotEmpty)
                Text(
                  _currentQuestion.questionKichwa,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              // Carga la rutina de opción multiple
              if (_currentQuestion.questionType == 'multiple_choice')
                ..._buildMultipleChoice(_currentQuestion.optionList, (value) {
                  setState(() {
                    _selectedOptions[_selectedMultipleChoice] =
                        value == _currentQuestion.correctAnswer;
                  });
                }),
              // Carga la rutina de traducir
              if (_currentQuestion.questionType == 'translate')
                ..._buildSelectAndSort(
                    _currentQuestion.words, _currentQuestion.correctOrder),
              // Carga la rutina de ordenar verticalmente
              if (_currentQuestion.questionType == 'vertical_sort')
                ..._buildVerticalSort(
                    _currentQuestion.words, _currentQuestion.correctOrder),
              // Carga la rutina de escuchar y traducir
              if (_currentQuestion.questionType == 'listen_and_translate')
                ..._buildListenAndTranslate(
                    _currentQuestion.questionSpanish, _currentQuestion.optionList,
                    (value) {
                  setState(() {
                    _selectedOptions[_selectedMultipleChoice] =
                        // ignore: unrelated_type_equality_checks
                        value == _currentQuestion.correctAnswer;
                  });
                }),
              // Carga la rutina de Drag and Drop
              if (_currentQuestion.questionType == 'drag_and_drop')
                ..._buildMatch(
                    _currentQuestion.words,_currentQuestion.correctOrder),
              // Carga la rutina de flashcards
              if (_currentQuestion.questionType == 'flashcard_question') 
                ..._buildFlashcards(_currentQuestion),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _checkAnswer,
          child: const Icon(Icons.check),
        ),
      );
    }
  }
