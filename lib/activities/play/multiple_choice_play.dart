// Tipo de actividad: multiple_choice (elegir una opción).
//
// `answer` es el índice elegido (int), -1 = nada elegido.

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/activity_media.dart';
import 'package:language_learning_ui/activities/play/activity_play.dart';
import 'package:language_learning_ui/models/question_model.dart';

dynamic initMultipleChoiceAnswer(Question q) => -1;

bool checkMultipleChoiceAnswer(Question q, dynamic answer) {
  final correctOptionIndex = q.optionList.indexOf(q.correctAnswer);
  return answer == correctOptionIndex;
}

List<Widget> buildMultipleChoicePlay(BuildContext context, PlayArgs args) {
  final q = args.question;
  final options = q.optionList;
  final selected = (args.answer as int? ?? -1);
  return [
    if (q.imagePath.isNotEmpty)
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SafeActivityImage(
          resolveImageAsset(args.unity, args.lesson, q.imagePath),
          height: 140,
        ),
      ),
    Column(
      children: [
        Center(
          child: SizedBox(
            width: double.infinity,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.6,
              ),
              itemCount: options.length,
              itemBuilder: (context, idx) {
                final option = options[idx];
                final isImage = looksLikeLessonImage(option);
                final isSelected = selected == idx;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => args.onChanged(idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[400] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                          width: isSelected ? 3 : 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: isImage
                          ? SafeActivityImage(
                              resolveImageAsset(
                                  args.unity, args.lesson, option),
                              fit: BoxFit.contain,
                              height: 80,
                              width: 80,
                            )
                          : Text(
                              option,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
  ];
}
