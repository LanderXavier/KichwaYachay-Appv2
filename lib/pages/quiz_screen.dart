// Pantalla de ACTIVIDAD (resolución).
//
// Esta pantalla es SOLO repartidora: muestra el enunciado, pide al binding
// del tipo que presente su interacción, y al pulsar ✔ le pide que corrija.
// El CÓMO se presenta cada tipo vive en `lib/activities/play/` (un archivo
// por actividad). Ver `lib/activities/play/activity_play.dart` para
// agregar un tipo nuevo sin tocar este archivo.

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/play/activity_play.dart';
import 'package:language_learning_ui/activities/question_type.dart';
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

  /// Respuesta actual; su forma depende del tipo (ver cada play/*.dart).
  dynamic _answer;

  // Audio Player
  final player = AudioPlayer();
  // Scroll controller & key for auto-scroll during drag in match view
  final ScrollController _matchScrollController = ScrollController();
  final GlobalKey _matchScrollKey = GlobalKey();

  ActivityBinding get _binding =>
      bindingFor(ActivityKind.parse(_currentQuestion.questionType));

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.questions[_questionIndex];
    _answer = _binding.initAnswer(_currentQuestion);
  }

  @override
  void dispose() {
    player.dispose();
    _matchScrollController.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String audioFile) async {
    if (audioFile.isEmpty) return;
    final path =
        'audios/unity_${widget.unity}/lesson_${widget.lesson}/$audioFile';
    await player.play(AssetSource(path));
  }

  PlayArgs _playArgs() {
    return PlayArgs(
      question: _currentQuestion,
      unity: widget.unity,
      lesson: widget.lesson,
      answer: _answer,
      onChanged: (value) => setState(() => _answer = value),
      playAudio: _playAudio,
      matchScrollController: _matchScrollController,
      matchScrollKey: _matchScrollKey,
    );
  }

  // Muestra feedback y solo avanza si es correcto.
  void _checkAnswer() {
    final bool isCorrect = _binding.checkAnswer(_currentQuestion, _answer);
    if (!isCorrect) {
      setState(() {
        _answer = _binding.initAnswer(_currentQuestion);
      });
    }

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
          content: const Text(
              'La respuesta no es correcta. Por favor, inténtalo de nuevo.'),
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
        _answer = _binding.initAnswer(_currentQuestion);
      } else {
        // Cuando se terminan las preguntas, mostrar diálogo con opciones
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Lección terminada'),
              content:
                  const Text('Has terminado la lección. ¿Qué deseas hacer?'),
              actions: [
                TextButton(
                  onPressed: () {
                    // Repetir: reiniciar el quiz desde el inicio
                    setState(() {
                      _questionIndex = 0;
                      _currentQuestion = widget.questions[_questionIndex];
                      _answer = _binding.initAnswer(_currentQuestion);
                    });
                    Navigator.of(context).pop(); // cerrar diálogo
                  },
                  child: const Text('Repetir'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // cerrar diálogo
                    // Volver a Mis lecciones sin romper la pila (Dashboard sigue detrás)
                    Navigator.of(context).pop(); // sale de QuizScreen -> QuizHome
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop(); // sale de QuizHome -> LessonScreen
                    }
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
            const SizedBox(height: 30),
            Text(
              _currentQuestion.questionSpanish,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            if (_currentQuestion.questionKichwa.isNotEmpty)
              Text(
                _currentQuestion.questionKichwa,
                style: const TextStyle(color: Colors.black, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            // Cuerpo según el tipo (ver lib/activities/play/).
            ..._binding.build(context, _playArgs()),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _checkAnswer,
            heroTag: 'check',
            child: const Icon(Icons.check),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () async {
              final shouldSkip = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title:
                      const Text('¿Seguro que quieres saltar esta actividad?'),
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
            backgroundColor: Colors.orange,
            heroTag: 'skip',
            tooltip: 'Saltar',
            child: const Icon(Icons.skip_next),
          ),
        ],
      ),
    );
  }
}
