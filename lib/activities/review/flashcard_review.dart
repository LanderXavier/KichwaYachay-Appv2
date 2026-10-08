// Repaso de: flashcard_question.
//
// Contrato (ver activity_specs.dart): tarjeta informativa con imagen.
// Puede traer imagePath como texto o lista de 1 (se usa el primero),
// y opcionalmente optionList con opciones.

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/activity_media.dart';
import 'package:language_learning_ui/activities/review/review_shared.dart';
import 'package:language_learning_ui/classes/question.dart';

Widget buildFlashReview(
    BuildContext context, Question q, int unity, String lesson) {
  final words = (q.words ?? []).map((e) => e.toString()).toList();
  final entries = words
      .map((entry) {
        final parts = entry.split(':');
        if (parts.length < 2) return null;
        return {
          'img': resolveImageAsset(unity, lesson, parts[0].trim()),
          'label': parts.sublist(1).join(':').trim(),
        };
      })
      .whereType<Map<String, String>>()
      .toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (entries.isNotEmpty)
        ...entries.map((e) => Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  SafeActivityImage(e['img']!, height: 48, width: 48),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e['label']!)),
                ],
              ),
            )),
      if (q.optionList.isNotEmpty)
        Wrap(
          children: q.optionList.map((op) {
            final isOk =
                correctValues(q).contains(op.toString());
            return ReviewChip(op.toString(),
                bg: isOk ? Colors.green.shade100 : Colors.white);
          }).toList(),
        ),
      if (entries.isEmpty && q.optionList.isEmpty)
        Text(
          correctValues(q).isNotEmpty
              ? correctValues(q).join(' ')
              : 'Contenido informativo',
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
    ],
  );
}
