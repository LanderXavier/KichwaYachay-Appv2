// Tipo de actividad: vertical_sort (reordenar palabras arrastrando).
//
// `answer` es la lista actual de palabras en el orden del usuario.

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/activity_media.dart';
import 'package:language_learning_ui/activities/play/activity_play.dart';
import 'package:language_learning_ui/models/question_model.dart';

dynamic initVerticalSortAnswer(Question q) => List<String>.from(q.words);

bool checkVerticalSortAnswer(Question q, dynamic answer) {
  if (answer is! List) return false;
  return activityListEquals(
      List<dynamic>.from(answer), q.correctOrder);
}

List<Widget> buildVerticalSortPlay(BuildContext context, PlayArgs args) {
  final q = args.question;
  final raw = args.answer;
  final words = raw is List
      ? List<String>.from(raw.map((e) => e.toString()))
      : <String>[];
  return [
    if (q.imagePath.isNotEmpty)
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SafeActivityImage(
          resolveImageAsset(args.unity, args.lesson, q.imagePath),
          height: 140,
        ),
      ),
    const SizedBox(height: 20),
    const Text(
      'Ordena las palabras para formar la frase correcta:',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
    ),
    const SizedBox(height: 20),
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
        if (newIndex > oldIndex) newIndex -= 1;
        final updated = List<String>.from(words);
        final String item = updated.removeAt(oldIndex);
        updated.insert(newIndex, item);
        args.onChanged(updated);
      },
    ),
  ];
}
