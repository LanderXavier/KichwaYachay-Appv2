// Repaso de: matching y drag_and_drop.
//
// - matching: parejas por posición words[i] <-> optionList[i].
// - drag_and_drop: parejas por posición words[i] <-> correctOrder[i].
// Si los largos no coinciden, muestra las listas separadas sin romperse.

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/activity_media.dart';
import 'package:language_learning_ui/activities/review/review_shared.dart';
import 'package:language_learning_ui/classes/question.dart';

Widget buildPairsReview(BuildContext context, Question q, int unity,
    String lesson,
    {required bool useCorrectOrder}) {
  final left = (q.words ?? []).map((e) => e.toString()).toList();
  final right = useCorrectOrder
      ? (q.correctOrder ?? []).map((e) => e.toString()).toList()
      : q.optionList.map((e) => e.toString()).toList();

  if (left.isNotEmpty && right.isNotEmpty && left.length == right.length) {
    return Column(
      children: List.generate(left.length, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                  child: TextOrImage(left[i],
                      unity: unity, lesson: lesson)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 18),
              ),
              Expanded(
                  child: TextOrImage(right[i],
                      unity: unity, lesson: lesson)),
            ],
          ),
        );
      }),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (left.isNotEmpty) ...[
        const Text('Piezas:', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(children: left.map((w) => ReviewChip(w)).toList()),
      ],
      if (right.isNotEmpty) ...[
        const SizedBox(height: 4),
        const Text('Relación / orden correcto:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(children: right.map((w) => ReviewChip(w)).toList()),
      ],
      if (left.isEmpty && right.isEmpty) Text(correctValues(q).join(' ')),
    ],
  );
}
