import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:language_learning_ui/models/question_model.dart';
import 'package:language_learning_ui/constants.dart';
import 'package:language_learning_ui/pages/quiz_screen.dart';
import 'package:language_learning_ui/pages/review_quiz_page.dart';

class QuizHomePage extends StatelessWidget {
  final int unity;
  final String lesson;
  const QuizHomePage({Key? key, required this.unity, required this.lesson})
      : super(key: key);

  Future<List<Question>> _loadQuestions(int unity, String lesson) async {
    final jsonString = await rootBundle
        .loadString('assets/database/unity_${unity}_lesson_$lesson.json');
    final jsonData = json.decode(jsonString) as List<dynamic>;

    final List<Question> questions = jsonData.map((question) {
      final caRaw = question['correctAnswer'];
      final String correctAnswer = caRaw is List
          ? (caRaw as List).map((e) => e.toString()).join(' ')
          : (caRaw?.toString() ?? '');

      return Question(
        questionSpanish: question['questionSpanish']?.toString() ?? '',
        questionKichwa: question['questionKichwa']?.toString() ?? '',
        correctAnswer: correctAnswer,
        audioPath: question['audioPath']?.toString() ?? '',
        imagePath: question['imagePath']?.toString() ?? '',
        questionType: question['questionType']?.toString() ?? '',
        optionList: question['optionList'] != null
            ? (question['optionList'] as List<dynamic>)
                .map((option) => option.toString())
                .toList()
            : <String>[],
        words: question['words'] != null
            ? (question['words'] as List<dynamic>)
                .map((option) => option.toString())
                .toList()
            : <String>[],
        correctOrder: question['correctOrder'] != null
            ? (question['correctOrder'] as List<dynamic>)
                .map((option) => option.toString())
                .toList()
            : <String>[],
      );
    }).toList();

    return questions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Constants.redKY,
      ),
      body: Center(
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 60, bottom: 40),
                child: Image.asset("assets/images/logo_kichwa_yachay.png")),
            Card(
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Constants.redKY,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(10),
                children: [
                  Container(
                    height: 50,
                    margin: const EdgeInsets.only(
                        top: 10, bottom: 25, left: 30, right: 30),
                    decoration: BoxDecoration(
                        border: Border.all(color: Constants.redKY),
                        color: Constants.redKY,
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: Text(
                        'LECCIÓN $lesson',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Constants.grayKY,
                            fontFamily: 'Roboto-Regular.ttf'),
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final questions = await _loadQuestions(unity, lesson);
                      // print(questions);
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(
                              unity: unity,
                              lesson: lesson,
                              questions: questions,
                            ),
                          ));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Constants.orangeLisKY,
                      backgroundColor: Constants.orangeLisKY,
                      disabledBackgroundColor: Constants.orangeLisKY,
                      disabledForegroundColor: Constants.orangeLisKY,
                      elevation: 5,
                      side: const BorderSide(
                          width: 1, color: Constants.orangeLisKY),
                    ),
                    child: const Text(
                      'Iniciar Quiz',
                      style: TextStyle(color: Constants.grayKY),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReviewQuizPage(
                                    unity: unity,
                                    lesson: lesson,
                                  )));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Constants.orangeLisKY,
                      backgroundColor: Constants.orangeLisKY,
                      disabledBackgroundColor: Constants.orangeLisKY,
                      disabledForegroundColor: Constants.orangeLisKY,
                      elevation: 5,
                      side: const BorderSide(
                          width: 1, color: Constants.orangeLisKY),
                    ),
                    child: const Text(
                      'Repasar Quiz',
                      style: TextStyle(color: Constants.grayKY),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
