// Repaso de: complete.
//
// Contrato (ver activity_specs.dart): optionList es la plantilla donde cada
// "" es un hueco; words el banco; correctOrder las palabras en orden.
// Se muestra RESUELTA: cada hueco rellenado con su palabra.

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/activity_media.dart';
import 'package:language_learning_ui/activities/review/order_review.dart';
import 'package:language_learning_ui/classes/question.dart';

Widget buildCompleteReview(
    BuildContext context, Question q, int unity, String lesson) {
  final template = q.optionList.map((e) => e.toString()).toList();
  final order = (q.correctOrder ?? []).map((e) => e.toString()).toList();
  final bank = (q.words ?? []).map((e) => e.toString()).toList();
  final hasBlanks = template.any((e) => e.isEmpty);
  int blankIdx = 0;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (hasBlanks)
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: template.map((part) {
            if (part.isEmpty) {
              final filled =
                  blankIdx < order.length ? order[blankIdx] : '___';
              blankIdx++;
              final inBank = bank.contains(filled);
              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        child: TextOrImage(filled,
                            unity: unity, lesson: lesson, imgSize: 32)),
                    if (!inBank)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child:
                            Icon(Icons.check, size: 14, color: Colors.green),
                      ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(part,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            );
          }).toList(),
        ),
      const SizedBox(height: 6),
      buildOrderReview(context, q, unity, lesson),
    ],
  );
}
