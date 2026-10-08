// Repaso de: translate y vertical_sort.
//
// - vertical_sort: words desordenadas + correctOrder con el orden correcto.
// - translate: correctOrder es máscara true/false del mismo largo que words
//   (contrato especial de la unidad 2, ver activity_specs.dart).

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/review/review_shared.dart';
import 'package:language_learning_ui/classes/question.dart';

bool isBoolMask(List<String> mask) {
  if (mask.isEmpty) return false;
  return mask.every((e) {
    final v = e.trim().toLowerCase();
    return v == 'true' || v == 'false';
  });
}

Widget buildOrderReview(
    BuildContext context, Question q, int unity, String lesson) {
  final order = (q.correctOrder ?? []).map((e) => e.toString()).toList();
  final bank = (q.words ?? []).map((e) => e.toString()).toList();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Respuesta correcta:',
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Text(
          order.isNotEmpty ? order.join(' ') : correctValues(q).join(' '),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      if (bank.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text('Banco: ${bank.join('  •  ')}',
            style: TextStyle(color: Colors.grey.shade700)),
      ],
    ],
  );
}

Widget buildTranslateReview(
    BuildContext context, Question q, int unity, String lesson) {
  final bank = (q.words ?? []).map((e) => e.toString()).toList();
  final mask = (q.correctOrder ?? []).map((e) => e.toString()).toList();
  if (bank.isNotEmpty && bank.length == mask.length && isBoolMask(mask)) {
    final selected = <String>[];
    for (int i = 0; i < bank.length; i++) {
      if (mask[i].trim().toLowerCase() == 'true') selected.add(bank[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Respuesta correcta (palabras a seleccionar):',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Text(
            selected.isNotEmpty ? selected.join('  •  ') : '—',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          children: List.generate(bank.length, (i) {
            final isOk = mask[i].trim().toLowerCase() == 'true';
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  if (isOk)
                    const Icon(Icons.check, size: 16, color: Colors.green),
                  Text(bank[i]),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
  return buildOrderReview(context, q, unity, lesson);
}
