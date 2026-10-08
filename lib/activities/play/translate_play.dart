// Tipo de actividad: translate (marcar las palabras correctas).
//
// `answer` es List<bool> paralelo a `words` (misma convención que el
// correctOrder del JSON: true = marcada).

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/play/activity_play.dart';
import 'package:language_learning_ui/models/question_model.dart';

dynamic initTranslateAnswer(Question q) =>
    List<bool>.generate(q.words.length, (_) => false);

bool checkTranslateAnswer(Question q, dynamic answer) {
  if (answer is! List) return false;
  return activityListEquals(
      List<dynamic>.from(answer), q.correctOrder);
}

List<Widget> buildTranslatePlay(BuildContext context, PlayArgs args) {
  final q = args.question;
  final shuffledWords = q.words;
  final raw = args.answer;
  final selected = raw is List
      ? List<bool>.from(
          raw.map((e) => e == true || e.toString() == 'true'))
      : List<bool>.generate(shuffledWords.length, (_) => false);
  return [
    const SizedBox(height: 10),
    const Text(
      'Selecciona las palabras correctas:',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    ),
    const SizedBox(height: 10),
    ...shuffledWords.asMap().entries.map((entry) {
      final i = entry.key;
      final current = List<bool>.from(selected);
      return CheckboxListTile(
        title: Text(shuffledWords[i]),
        value: i < current.length ? current[i] : false,
        onChanged: (value) {
          final updated = List<bool>.from(selected);
          while (updated.length < shuffledWords.length) {
            updated.add(false);
          }
          updated[i] = value ?? false;
          args.onChanged(updated);
        },
      );
    }).toList(),
  ];
}
