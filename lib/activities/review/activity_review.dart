// Puerta de entrada del repaso: dado un tipo, devuelve su vista.
//
// Para cambiar cómo se ve UN tipo en el repaso, edita su archivo:
//   multiple_choice / listen_and_translate -> choice_review.dart
//   translate / vertical_sort               -> order_review.dart
//   complete                                -> complete_review.dart
//   matching / drag_and_drop                -> pairs_review.dart
//   flashcard_question                      -> flashcard_review.dart

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/question_type.dart';
import 'package:language_learning_ui/activities/review/choice_review.dart';
import 'package:language_learning_ui/activities/review/complete_review.dart';
import 'package:language_learning_ui/activities/review/flashcard_review.dart';
import 'package:language_learning_ui/activities/review/order_review.dart';
import 'package:language_learning_ui/activities/review/pairs_review.dart';
import 'package:language_learning_ui/activities/review/review_shared.dart';
import 'package:language_learning_ui/classes/question.dart';

Widget buildActivityReview(
    BuildContext context, Question q, int unity, String lesson) {
  switch (ActivityKind.parse(q.questionType)) {
    case ActivityKind.multipleChoice:
    case ActivityKind.listenAndTranslate:
      return buildChoiceReview(context, q, unity, lesson);
    case ActivityKind.translate:
      return buildTranslateReview(context, q, unity, lesson);
    case ActivityKind.verticalSort:
      return buildOrderReview(context, q, unity, lesson);
    case ActivityKind.complete:
      return buildCompleteReview(context, q, unity, lesson);
    case ActivityKind.matching:
      return buildPairsReview(context, q, unity, lesson,
          useCorrectOrder: false);
    case ActivityKind.dragAndDrop:
      return buildPairsReview(context, q, unity, lesson,
          useCorrectOrder: true);
    case ActivityKind.flashcard:
      return buildFlashReview(context, q, unity, lesson);
    default:
      final t = correctValues(q).join(' ');
      return Text(t.isNotEmpty ? t : '—');
  }
}
