// Piezas compartidas de las vistas de repaso.

import 'package:flutter/material.dart';
import 'package:language_learning_ui/classes/question.dart';

/// Respuesta(s) correcta(s) como texto, venga como String o List.
List<String> correctValues(Question q) {
  final ca = q.correctAnswer;
  if (ca is List) return ca.map((e) => e.toString()).toList();
  if (ca.toString().isEmpty) return <String>[];
  return <String>[ca.toString()];
}

class ReviewChip extends StatelessWidget {
  final String text;
  final Color? bg;
  final Color? fg;

  const ReviewChip(this.text, {Key? key, this.bg, this.fg})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text,
          style: TextStyle(color: fg ?? Colors.black87, fontSize: 14)),
    );
  }
}
