// Tipo de actividad: listen_and_translate (escuchar audio y elegir).
//
// `answer` es el índice elegido (int), -1 = nada elegido.

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/activity_media.dart';
import 'package:language_learning_ui/activities/play/activity_play.dart';
import 'package:language_learning_ui/models/question_model.dart';

dynamic initListenAnswer(Question q) => -1;

bool checkListenAnswer(Question q, dynamic answer) {
  final correctOptionIndex = q.optionList.indexOf(q.correctAnswer);
  return answer == correctOptionIndex;
}

List<Widget> buildListenPlay(BuildContext context, PlayArgs args) {
  final q = args.question;
  final options = q.optionList;
  final selected = (args.answer as int? ?? -1);
  return [
    Column(
      children: [
        if (q.imagePath.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SafeActivityImage(
              resolveImageAsset(args.unity, args.lesson, q.imagePath),
              height: 140,
            ),
          ),
        Center(
          child: InkWell(
            onTap: () => args.playAudio(q.audioPath),
            borderRadius: BorderRadius.circular(40),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 48,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: SizedBox(
            width: 400,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isImage = looksLikeLessonImage(option);
                final isSelected = selected == index;
                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => args.onChanged(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[300] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    child: isImage
                        ? SafeActivityImage(
                            resolveImageAsset(
                                args.unity, args.lesson, option),
                            fit: BoxFit.contain,
                            height: 90,
                            width: 90,
                          )
                        : Text(
                            option,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.blue[900],
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  ];
}
