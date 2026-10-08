// Repaso de: multiple_choice y listen_and_translate.
//
// Contrato (ver activity_specs.dart): optionList con las opciones y
// correctAnswer con la correcta (String o lista de 1).

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/activity_media.dart';
import 'package:language_learning_ui/activities/review/review_shared.dart';
import 'package:language_learning_ui/classes/question.dart';

Widget buildChoiceReview(
    BuildContext context, Question q, int unity, String lesson) {
  final correct = correctValues(q).map((e) => e.trim()).toSet();
  final options = q.optionList.map((e) => e.toString()).toList();
  return Wrap(
    children: options.map((op) {
      final isOk = correct.contains(op.trim());
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isOk ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isOk ? Colors.green : Colors.grey.shade300,
              width: isOk ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOk) const Icon(Icons.check, size: 16, color: Colors.green),
            Flexible(
                child: TextOrImage(op, unity: unity, lesson: lesson)),
          ],
        ),
      );
    }).toList(),
  );
}
