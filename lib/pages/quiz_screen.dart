import 'package:flutter/material.dart';
  import 'package:language_learning_ui/constants.dart';
  import 'package:language_learning_ui/models/question_model.dart';
  import 'package:language_learning_ui/pages/lesson_screen.dart';
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
    // Scroll controller & key for auto-scroll during drag in match view
    final ScrollController _matchScrollController = ScrollController();
    final GlobalKey _matchScrollKey = GlobalKey();
    // Flashcard Variables
    String? _selectedFlashcardAnswer; 
    // Helper: carga segura de imágenes mostrando un espacio en blanco si no existe el asset
    Widget _safeImage(String path, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
      if (path.isEmpty) return SizedBox(height: height, width: width);
        // Chequeo asíncrono del AssetManifest para evitar que Flutter intente
        // cargar un asset que no existe (lo que lanza FlutterError y hace rethrow).
        return FutureBuilder<String>(
          future: DefaultAssetBundle.of(context).loadString('AssetManifest.json'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // Mientras cargamos el manifiesto, reservamos el espacio.
              return SizedBox(height: height, width: width);
            }
            final manifest = snapshot.data!;
            // El manifiesto contiene rutas en formato JSON, así que buscamos la ruta.
            if (!manifest.contains('"$path"') && !manifest.contains(path)) {
              return SizedBox(height: height, width: width);
            }
            // Si existe en el manifiesto, cargamos la imagen con errorBuilder por seguridad.
            return Image.asset(
              path,
              height: height,
              width: width,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => SizedBox(height: height, width: width),
            );
          },
        );
    }
    Widget _buildMatchItem(String value) {
  bool isImage = value.endsWith('.png') || value.endsWith('.jpg') || value.endsWith('.jpeg');
  return Container(
    width: 100,
    height: 100,
    alignment: Alignment.center,
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.blue[100],
      borderRadius: BorderRadius.circular(8),
    ),
        child: isImage
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _safeImage(
              'assets/database/images/$value',
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
          )
        : Text(value, style: const TextStyle(fontSize: 18)),
  );
}


    @override
    void initState() {
      super.initState();
      _selectedMultipleChoice = -1; // Inicializa el valor al crear la pantalla
      _currentQuestion = widget.questions[_questionIndex];
      _selectedOptions =
          List.generate(_currentQuestion.optionList.length, (index) => false);
    }

    // Opción Múltiple
    List<Widget> _buildMultipleChoice(
        List<String> options, Function(int?) onChanged) {
      // Devuelve una lista con un Column que contiene (opcional) la imagen de la pregunta
      // y una cuadrícula con las opciones (texto o imagen) estilizadas.
      return [
        if (_currentQuestion.imagePath.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _safeImage(
              'assets/images/unity_${widget.unity}/lesson_${widget.lesson}/${_currentQuestion.imagePath}',
              height: 140,
              fit: BoxFit.contain,
            ),
          ),
        Column(
          children: [
            Center(
              child: SizedBox(
                width: double.infinity,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, idx) {
                    final option = options[idx];
                    final isImage = option.endsWith('.png') || option.endsWith('.jpg') || option.endsWith('.jpeg');
                    final selected = _selectedMultipleChoice == idx;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          _selectedMultipleChoice = idx;
                          if (_selectedOptions.length <= idx) {
                            _selectedOptions = List.generate(options.length, (i) => false);
                          }
                          for (int i = 0; i < _selectedOptions.length; i++) _selectedOptions[i] = false;
                          _selectedOptions[idx] = true;
                        });
                        onChanged(idx);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: selected ? Colors.blue[400] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: selected ? Colors.blueAccent : Colors.grey.shade300, width: selected ? 3 : 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: isImage
                              ? _safeImage(
                                  'assets/images/unity_${widget.unity}/lesson_${widget.lesson}/$option',
                                  fit: BoxFit.contain,
                                  height: 80,
                                  width: 80,
                                )
                              : Text(
                                  option,
                                  style: TextStyle(
                                    color: selected ? Colors.white : Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ];
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
            // Imagen superior (de la misma unidad/lección)
            if (_currentQuestion.imagePath.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _safeImage(
                  'assets/images/unity_${widget.unity}/lesson_${widget.lesson}/${_currentQuestion.imagePath}',
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
            // Botón de audio bonito debajo de la imagen
            Center(
              child: InkWell(
                onTap: () async {
                  String audioPath = 'audios/unity_${widget.unity}/lesson_${widget.lesson}/${_currentQuestion.audioPath}';
                  await player.play(AssetSource(audioPath));
                },
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 48,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Opciones en cuadrícula 2x2, grandes y centradas
            Center(
              child: SizedBox(
                width: 400, // ancho fijo para centrar
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 1,
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isImage = option.endsWith('.png') || option.endsWith('.jpg') || option.endsWith('.jpeg');
                    final isSelected = _selectedMultipleChoice == index;
                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        setState(() {
                          _selectedMultipleChoice = index;
                        });
                        onChanged(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[300] : Colors.blue[50],
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isSelected ? Colors.blueAccent : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(16),
                        child: isImage
                            ? _safeImage(
                                'assets/images/unity_${widget.unity}/lesson_${widget.lesson}/$option',
                                fit: BoxFit.contain,
                                height: 90,
                                width: 90,
                              )
                            : Text(
                                option,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.blue[900],
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ];
    }
    // Drag and Drop
  List<String> _draggedWords = [];

List<Widget> _buildMatch(List<String> words, List<String> correctOrder) {
  List<String> availableWords = List.from(words);
  List<String> optionLabels = correctOrder;

  String getImagePath(String fileName) {
    return 'assets/images/unity_${widget.unity}/lesson_${widget.lesson}/$fileName';
  }

  if (_draggedWords.length != optionLabels.length) {
    _draggedWords = List.filled(optionLabels.length, '');
  }

  // Siempre vertical, con imágenes o solo texto
  return [
    const SizedBox(height: 20),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.swap_vert, color: Colors.blue),
        const SizedBox(width: 8),
        const Text('Arrastra cada elemento a su lugar correcto:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    ),
    const SizedBox(height: 20),
    Expanded(
      child: SingleChildScrollView(
        key: _matchScrollKey,
        controller: _matchScrollController,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna de elementos arrastrables (imágenes o texto)
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(availableWords.length, (index) {
                  final word = availableWords[index];
                  final isImage = word.endsWith('.png') || word.endsWith('.jpg') || word.endsWith('.jpeg');
                  if (_draggedWords.contains(word)) return const SizedBox(width: 100, height: 100);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Draggable<String>(
                      data: word,
                        feedback: Material(
                        color: Colors.transparent,
                        child: isImage
                            ? _safeImage(getImagePath(word), width: 100, height: 100, fit: BoxFit.cover)
                            : Container(
                                width: 100,
                                height: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.blue[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  word,
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
                      ),
                          child: isImage
                          ? Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _safeImage(
                                getImagePath(word),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              key: Key(word),
                              width: 100,
                              height: 100,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                word,
                                style: const TextStyle(color: Colors.black, fontSize: 20),
                              ),
                            ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 24),
            // Columna de recuadros de destino
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(optionLabels.length, (index) {
                  final isImage = _draggedWords[index].isNotEmpty &&
                      (_draggedWords[index].endsWith('.png') ||
                          _draggedWords[index].endsWith('.jpg') ||
                          _draggedWords[index].endsWith('.jpeg'));
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DragTarget<String>(
                      onWillAccept: (data) => true,
                      onAccept: (data) {
                        setState(() {
                          int prevIndex = _draggedWords.indexOf(data);
                          if (prevIndex != -1) {
                            _draggedWords[prevIndex] = '';
                          }
                          _draggedWords[index] = data;
                        });
                      },
                      onMove: (details) {
                        // Auto-scroll when dragging near top/bottom edges.
                        // Use the RenderBox local coordinates and jumpTo for immediate effect.
                        try {
                          if (!_matchScrollController.hasClients) return;
                          final box = _matchScrollKey.currentContext?.findRenderObject() as RenderBox?;
                          if (box == null) return;
                          // Pointer relative to the scrollable box
                          final local = box.globalToLocal(details.offset);
                          final height = box.size.height;
                          const edgeMargin = 120.0; // mayor margen para detectar borde
                          const scrollStep = 120.0; // paso más grande para bajar de forma fiable
                          final maxScroll = _matchScrollController.position.maxScrollExtent;
                          double newOffset = _matchScrollController.offset;
                          if (local.dy < edgeMargin) {
                            newOffset = (_matchScrollController.offset - scrollStep).clamp(0.0, maxScroll) as double;
                            _matchScrollController.jumpTo(newOffset);
                          } else if (local.dy > height - edgeMargin) {
                            newOffset = (_matchScrollController.offset + scrollStep).clamp(0.0, maxScroll) as double;
                            _matchScrollController.jumpTo(newOffset);
                          }
                        } catch (e) {
                          // ignore errors if layout not ready
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: candidateData.isNotEmpty ? Colors.green : Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  child: _draggedWords[index].isNotEmpty
                                      ? isImage
                                          ? Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: _safeImage(
                                                    getImagePath(_draggedWords[index]),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 4,
                                                  right: 4,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.7),
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: IconButton(
                                                      icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                      onPressed: () {
                                                        setState(() {
                                                          _draggedWords[index] = '';
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Stack(
                                              children: [
                                                Center(
                                                  child: Text(
                                                    _draggedWords[index],
                                                    style: const TextStyle(color: Colors.black, fontSize: 20),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 4,
                                                  right: 4,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.7),
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: IconButton(
                                                      icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                      onPressed: () {
                                                        setState(() {
                                                          _draggedWords[index] = '';
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                optionLabels[index].replaceAll(RegExp(r'\.(png|jpg|jpeg)?$'), ''),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 20),
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
            _safeImage(
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
  final words = question.words;

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
                    _safeImage(
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
      bool isCorrect = false;
      // Multiple Choice Handler
      if (_currentQuestion.questionType == 'multiple_choice') {
        int correctOptionIndex =
            _currentQuestion.optionList.indexOf(_currentQuestion.correctAnswer);
        isCorrect = _selectedMultipleChoice == correctOptionIndex;
        if (!isCorrect) {
      setState(() {
        _selectedMultipleChoice = -1;
      });
    }
        // Translate Handler
      } else if (_currentQuestion.questionType == 'translate') {
        isCorrect = _listEquals(_selectedTranslate, _currentQuestion.correctOrder);
        if (!isCorrect) {
      setState(() {
        _selectedTranslate = List.generate(_currentQuestion.words.length, (index) => false);
      });
    }
      } else if (_currentQuestion.questionType == 'vertical_sort') {
        isCorrect = _listEquals(_wordsList, _currentQuestion.correctOrder);
        if (!isCorrect) {
      setState(() {
        _wordsList = List.from(_currentQuestion.words);
      });
    }
        // Listen and Translate Handler
      } else if (_currentQuestion.questionType == 'listen_and_translate') {
        int correctOptionIndex =
            _currentQuestion.optionList.indexOf(_currentQuestion.correctAnswer);
        isCorrect = _selectedMultipleChoice == correctOptionIndex;
        if (!isCorrect) {
      setState(() {
        _selectedMultipleChoice = -1;
      });
    }
        // Drag and Drop Handler
      } else if (_currentQuestion.questionType == 'drag_and_drop') {
        isCorrect = _draggedWords.length == _currentQuestion.correctOrder.length &&
            List.generate(_currentQuestion.correctOrder.length, (i) => _draggedWords[i] == _currentQuestion.correctOrder[i])
                .every((element) => element);
        if (!isCorrect) {
      setState(() {
        _draggedWords = List.filled(_currentQuestion.correctOrder.length, '');
      });
    }
        // Flashcard Handler
      } else if (_currentQuestion.questionType == 'flashcard_question') {
        isCorrect = _selectedFlashcardAnswer == _currentQuestion.correctAnswer;
        if (!isCorrect) {
      setState(() {
        _selectedFlashcardAnswer = null;
      });
    }
      } else if (_currentQuestion.questionType == 'complete') {
        isCorrect = _draggedWords.length == _currentQuestion.correctOrder.length &&
            List.generate(_currentQuestion.correctOrder.length, (i) => _draggedWords[i] == _currentQuestion.correctOrder[i])
                .every((element) => element);
        if (!isCorrect) {
      setState(() {
        _draggedWords = List.filled(_currentQuestion.correctOrder.length, '');
      });
    }
      }

      // Mostrar feedback y solo avanzar si es correcto
      if (isCorrect) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¡Correcto!'),
            content: const Text('¡Respuesta correcta!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _nextQuestion();
                },
                child: const Text('Siguiente'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Inténtalo de nuevo'),
            content: const Text('La respuesta no es correcta. Por favor, inténtalo de nuevo.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }

    void _nextQuestion() {
      setState(() {
        _questionIndex++;
        if (_questionIndex < widget.questions.length) {
          _currentQuestion = widget.questions[_questionIndex];
          _selectedOptions =
              List.generate(_currentQuestion.optionList.length, (index) => false);
          _selectedMultipleChoice = -1; // Reinicia si usas selección múltiple
          _draggedWords = List.filled(_currentQuestion.correctOrder.length, '');
          _selectedTranslate = List.generate(_currentQuestion.words.length, (index) => false);
          _wordsList = List.from(_currentQuestion.words);
          _selectedFlashcardAnswer = null;
        } else {
          // Cuando se terminan las preguntas, mostrar diálogo con opciones
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Lección terminada'),
                content: const Text('Has terminado la lección. ¿Qué deseas hacer?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Repetir: reiniciar el quiz desde el inicio
                      setState(() {
                        _questionIndex = 0;
                        _currentQuestion = widget.questions[_questionIndex];
                        _selectedOptions = List.generate(_currentQuestion.optionList.length, (index) => false);
                        _selectedMultipleChoice = -1;
                        _draggedWords = List.filled(_currentQuestion.correctOrder.length, '');
                        _selectedTranslate = List.generate(_currentQuestion.words.length, (index) => false);
                        _wordsList = List.from(_currentQuestion.words);
                        _selectedFlashcardAnswer = null;
                      });
                      Navigator.of(context).pop(); // cerrar diálogo
                    },
                    child: const Text('Repetir'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // cerrar diálogo
                      // Asegurar que volvemos a la pantalla de selección de lección
                      // Primero vaciamos hasta la ruta inicial y luego navegamos a LessonScreen
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LessonScreen(unity: widget.unity),
                      ));
                    },
                    child: const Text('Regresar'),
                  ),
                ],
              ),
            );
          });
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
              // Carga la rutina de Drag and Drop para imágenes o solo texto
              if (_currentQuestion.questionType == 'drag_and_drop')
                ..._buildMatch(
                    _currentQuestion.words, _currentQuestion.correctOrder),
              // Carga la rutina de completar frases
              if (_currentQuestion.questionType == 'complete')
                ..._buildComplete(
                  _currentQuestion.optionList,
                  _currentQuestion.words,
                  _currentQuestion.correctOrder,
                ),
              // Carga la rutina de flashcards
              if (_currentQuestion.questionType == 'flashcard_question') 
                ..._buildFlashcards(_currentQuestion),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: _checkAnswer,
              child: const Icon(Icons.check),
              heroTag: 'check',
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () async {
    final shouldSkip = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Seguro que quieres saltar esta actividad?'),
        content: const Text('No se guardará tu respuesta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Saltar'),
          ),
        ],
      ),
    );
    if (shouldSkip == true) {
      _nextQuestion();
    }
  },
              child: const Icon(Icons.skip_next),
              backgroundColor: Colors.orange,
              heroTag: 'skip',
              tooltip: 'Saltar',
            ),
          ],
        ),
      );
    }
  //  Complete
List<Widget> _buildComplete(List<String> optionList, List<String> words, List<String> correctOrder) {
  List<String> availableWords = List.from(words);
  if (_draggedWords.length != optionList.where((e) => e == '').length) {
    _draggedWords = List.filled(optionList.where((e) => e == '').length, '');
  }
  int blankIndex = 0;
  return [
    // Mostrar imagen si existe
    if (_currentQuestion.imagePath.isNotEmpty)
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _safeImage(
          'assets/images/unity_${widget.unity}/lesson_${widget.lesson}/${_currentQuestion.imagePath}',
          height: 140,
          fit: BoxFit.contain,
        ),
      ),
    const SizedBox(height: 20),
    Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: optionList.map((part) {
        if (part == '') {
          int currentIndex = blankIndex;
          blankIndex++;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: DragTarget<String>(
              onWillAccept: (data) => true,
              onAccept: (data) {
                setState(() {
                  int prevIndex = _draggedWords.indexOf(data);
                  if (prevIndex != -1) {
                    _draggedWords[prevIndex] = '';
                  }
                  if (currentIndex < _draggedWords.length) {
                    _draggedWords[currentIndex] = data;
                  }
                });
              },
              builder: (context, candidateData, rejectedData) {
                final isValid = currentIndex < _draggedWords.length;
                return Container(
                  width: 120, // Aumenta el ancho
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: candidateData.isNotEmpty ? Colors.green : Colors.black,
                      width: 2,
                    ),
                  ),
                  child: isValid && _draggedWords[currentIndex].isNotEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                _draggedWords[currentIndex],
                                style: const TextStyle(color: Colors.black, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8), // Espacio extra a la derecha
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    if (currentIndex < _draggedWords.length) {
                                      _draggedWords[currentIndex] = '';
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              part,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          );
        }
      }).toList(),
    ),
    const SizedBox(height: 20),
    Wrap(
      children: availableWords.where((w) => !_draggedWords.contains(w)).map((word) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Draggable<String>(
            data: word,
            feedback: Material(
              color: Colors.transparent,
              child: Container(
                width: 80,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  word,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            childWhenDragging: Container(
              width: 80,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Container(
              width: 80,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word,
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ),
        );
      }).toList(),
    ),
    const SizedBox(height: 20),
  ];
}
}