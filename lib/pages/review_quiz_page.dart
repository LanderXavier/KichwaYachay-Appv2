// Pantalla "Repasar Quiz".
//
// Esta página es SOLO cáscara: carga el JSON y pinta una tarjeta por
// pregunta. El contenido de cada tarjeta vive en
// `lib/activities/review/` (un archivo por actividad).
//
// Para cambiar cómo se repasa un tipo, NO edites este archivo:
// ve a `lib/activities/review/activity_review.dart` que te dice qué
// archivo toca. Contrato de datos en `lib/activities/activity_specs.dart`.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_learning_ui/activities/activity_media.dart';
import 'package:language_learning_ui/activities/question_type.dart';
import 'package:language_learning_ui/activities/review/activity_review.dart';
import 'package:language_learning_ui/classes/question.dart';
import 'package:language_learning_ui/classes/quiz.dart';
import 'package:language_learning_ui/constants.dart';

class ReviewQuizPage extends StatefulWidget {
  final int unity;
  final String lesson;
  const ReviewQuizPage({Key? key, required this.unity, required this.lesson})
      : super(key: key);

  @override
  State<ReviewQuizPage> createState() => _ReviewQuizPageState();
}

class _ReviewQuizPageState extends State<ReviewQuizPage> {
  Quiz quiz = Quiz(name: 'Quiz', questions: []);

  Future<void> readJson() async {
    final String response = await rootBundle.loadString(
        'assets/database/unity_${widget.unity}_lesson_${widget.lesson}.json');
    final List<dynamic> data = await json.decode(response);
    for (var item in data) {
      // Salta bloques que no son pregunta (ej: hoja de conversación en unidad 6)
      if (item is! Map) continue;
      try {
        Question question =
            Question.fromJson(Map<String, dynamic>.from(item));
        quiz.questions.add(question);
      } catch (_) {
        continue;
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Constants.redKY,
          elevation: 0,
          title: Text('Repaso lección ${widget.lesson}'),
        ),
        body: quiz.questions.isNotEmpty
            ? Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(
                        left: 8, right: 8, top: 8, bottom: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: Constants.greenKY, width: 2),
                        color: Constants.greenaguitaKY),
                    child: Center(
                      child: Text(
                        "Preguntas: ${quiz.questions.length}",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: quiz.questions.length,
                        itemBuilder: (_, index) {
                          final q = quiz.questions[index];
                          final kind =
                              ActivityKind.parse(q.questionType);
                          final title = q.questionSpanish.isNotEmpty
                              ? q.questionSpanish
                              : q.questionKichwa;
                          return Card(
                            color: Constants.yellowaguitaKY,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        child: Text('${index + 1}',
                                            style:
                                                const TextStyle(fontSize: 13)),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          title.isNotEmpty
                                              ? title
                                              : 'Actividad ${index + 1}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black12,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          kind.label,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (q.questionSpanish.isNotEmpty &&
                                      q.questionKichwa.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(q.questionKichwa,
                                        style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 14)),
                                  ],
                                  if (q.imagePath.isNotEmpty &&
                                      looksLikeLessonImage(q.imagePath)) ...[
                                    const SizedBox(height: 8),
                                    Center(
                                      child: SafeActivityImage(
                                          resolveImageAsset(
                                              widget.unity,
                                              widget.lesson,
                                              q.imagePath),
                                          height: 110),
                                    ),
                                  ],
                                  if (q.audioPath.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.audiotrack, size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                              'Audio: ${q.audioPath}',
                                              style: TextStyle(
                                                  color:
                                                      Colors.grey.shade700,
                                                  fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  buildActivityReview(
                                      context, q, widget.unity, widget.lesson),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator()));
  }
}
