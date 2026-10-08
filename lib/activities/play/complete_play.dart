// Tipo de actividad: complete (frase con huecos + banco de palabras).
//
// `answer` es List<String> del largo de huecos ("" en optionList),
// "" = hueco vacío.

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/activity_media.dart';
import 'package:language_learning_ui/activities/play/activity_play.dart';
import 'package:language_learning_ui/models/question_model.dart';

int _blankCount(Question q) =>
    q.optionList.where((entry) => entry.isEmpty).length;

dynamic initCompleteAnswer(Question q) =>
    List<String>.filled(_blankCount(q), '');

bool checkCompleteAnswer(Question q, dynamic answer) {
  if (answer is! List) return false;
  final placed = List<dynamic>.from(answer);
  if (placed.length != q.correctOrder.length) return false;
  return activityListEquals(placed, q.correctOrder);
}

List<Widget> buildCompletePlay(BuildContext context, PlayArgs args) {
  final q = args.question;
  final optionList = q.optionList;
  final availableWords = List<String>.from(q.words);
  final raw = args.answer;
  List<String> placed = raw is List
      ? List<String>.from(raw.map((e) => e.toString()))
      : <String>[];
  if (placed.length != _blankCount(q)) {
    placed = List<String>.filled(_blankCount(q), '');
  }

  int blankIndex = 0;
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
    Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: optionList.map((part) {
        if (part == '') {
          final int currentIndex = blankIndex;
          blankIndex++;
          final value =
              currentIndex < placed.length ? placed[currentIndex] : '';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: DragTarget<String>(
              onWillAccept: (_) => true,
              onAccept: (data) {
                final updated = List<String>.from(placed);
                updated[currentIndex] = data;
                args.onChanged(updated);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 80,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value.isEmpty
                        ? Colors.grey[300]
                        : Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              part,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          );
        }
      }).toList(),
    ),
    const SizedBox(height: 20),
    Wrap(
      children:
          availableWords.where((w) => !placed.contains(w)).map((word) {
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
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  word,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            childWhenDragging: Container(
              width: 80,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Container(
              width: 80,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      }).toList(),
    ),
    const SizedBox(height: 20),
  ];
}
