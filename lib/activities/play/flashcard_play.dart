// Tipo de actividad: flashcard_question (mirar tarjetas, opcionalmente responder).
//
// `answer` es la opción elegida (String?) o null. Las flashcards puramente
// informativas (sin opciones ni respuesta) siempre dan correcta.

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/activity_media.dart';
import 'package:language_learning_ui/activities/play/activity_play.dart';
import 'package:language_learning_ui/models/question_model.dart';

bool isInformationalFlashcard(Question q) {
  return q.questionType == 'flashcard_question' &&
      q.optionList.isEmpty &&
      q.correctAnswer.isEmpty;
}

dynamic initFlashcardAnswer(Question q) => null;

bool checkFlashcardAnswer(Question q, dynamic answer) {
  return isInformationalFlashcard(q) || answer == q.correctAnswer;
}

void showFlashcardDialog(
    BuildContext context, String questionText, String imageAssetPath) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Pregunta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SafeActivityImage(imageAssetPath, height: 150),
            const SizedBox(height: 20),
            Text(
              questionText,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cerrar"),
          ),
        ],
      );
    },
  );
}

List<Widget> buildFlashcardPlay(BuildContext context, PlayArgs args) {
  final q = args.question;
  final selected = args.answer?.toString();

  final flashcardEntries = q.words
      .map((entry) {
        final parts = entry.split(':');
        if (parts.length < 2) return null;
        return {
          'imagePath':
              resolveImageAsset(args.unity, args.lesson, parts[0]),
          'label': parts.sublist(1).join(':'),
        };
      })
      .whereType<Map<String, String>>()
      .toList();

  if (flashcardEntries.isEmpty && q.imagePath.isNotEmpty) {
    flashcardEntries.add({
      'imagePath':
          resolveImageAsset(args.unity, args.lesson, q.imagePath),
      'label': q.questionKichwa.isNotEmpty
          ? q.questionKichwa
          : q.questionSpanish,
    });
  }

  return [
    const SizedBox(height: 10),
    const Text(
      'Mira las flashcards:',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    ),
    const SizedBox(height: 10),
    Expanded(
      child: ListView.builder(
        itemCount: flashcardEntries.length,
        itemBuilder: (context, index) {
          final imagePath = flashcardEntries[index]['imagePath'] ?? '';
          final label = flashcardEntries[index]['label'] ?? '';
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Column(
                  children: [
                    SafeActivityImage(imagePath, height: 150),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
    const SizedBox(height: 20),
    if (q.questionSpanish.isNotEmpty)
      ElevatedButton(
        onPressed: () {
          showFlashcardDialog(
              context,
              q.questionSpanish,
              resolveImageAsset(
                  args.unity, args.lesson, q.imagePath));
        },
        child: const Text("Mostrar pregunta"),
      ),
    const SizedBox(height: 20),
    if (q.optionList.isNotEmpty)
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: q.optionList.map((option) {
          final isSelected = selected == option;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: isSelected ? Colors.green : Colors.blue,
              ),
              onPressed: () => args.onChanged(option),
              child: Text(option),
            ),
          );
        }).toList(),
      ),
  ];
}
