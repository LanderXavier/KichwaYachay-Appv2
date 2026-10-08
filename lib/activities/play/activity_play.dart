// Contratos de presentación del tipo de actividad + registro.
//
// Para agregar un tipo NUEVO de actividad al catálogo:
//   1. Crea `lib/activities/play/mi_tipo_play.dart` con 3 funciones:
//      `initMiTipoAnswer`, `checkMiTipoAnswer`, `buildMiTipoPlay`
//      (copia `multiple_choice_play.dart`, es el más simple).
//   2. Añade UNA línea en `activityPlayBindings` aquí abajo.
//   3. Añade su spec en `activity_specs.dart`, su vista en `review/` y
//      su ejemplo en `docs/ACTIVIDADES.md`.
// Eso es todo: `quiz_screen.dart` no se toca.

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/play/complete_play.dart';
import 'package:language_learning_ui/activities/play/flashcard_play.dart';
import 'package:language_learning_ui/activities/play/listen_play.dart';
import 'package:language_learning_ui/activities/play/match_play.dart';
import 'package:language_learning_ui/activities/play/multiple_choice_play.dart';
import 'package:language_learning_ui/activities/play/translate_play.dart';
import 'package:language_learning_ui/activities/play/vertical_sort_play.dart';
import 'package:language_learning_ui/activities/question_type.dart';
import 'package:language_learning_ui/models/question_model.dart';

/// Todo lo que la presentación de un tipo de actividad necesita de la pantalla.
/// `quiz_screen.dart` lo arma; el archivo de cada tipo solo lo consume.
class PlayArgs {
  final Question question;
  final int unity;
  final String lesson;

  /// Respuesta actual (forma según tipo: int, List<bool>, List<String>, String?).
  final dynamic answer;

  /// Llamar con la nueva respuesta (la pantalla hace setState).
  final ValueChanged<dynamic> onChanged;

  /// Reproduce `assets/audios/unity_X/lesson_Y/<audioFile>`.
  final Future<void> Function(String audioFile) playAudio;

  /// Solo para tableros de arrastre (drag/matching/complete usan scroll propio).
  final ScrollController matchScrollController;
  final GlobalKey matchScrollKey;

  const PlayArgs({
    required this.question,
    required this.unity,
    required this.lesson,
    required this.answer,
    required this.onChanged,
    required this.playAudio,
    required this.matchScrollController,
    required this.matchScrollKey,
  });
}

/// Respuesta inicial (equivale al "reiniciar" tras fallar).
typedef InitAnswer = dynamic Function(Question q);

/// true si la respuesta gana.
typedef CheckAnswer = bool Function(Question q, dynamic answer);

/// Widgets del cuerpo de la actividad.
typedef BuildPlay = List<Widget> Function(
    BuildContext context, PlayArgs args);

class ActivityBinding {
  final InitAnswer initAnswer;
  final CheckAnswer checkAnswer;
  final BuildPlay build;

  const ActivityBinding({
    required this.initAnswer,
    required this.checkAnswer,
    required this.build,
  });
}

/// Compara elemento a elemento como texto (tolera bool vs "true", etc.).
bool activityListEquals(List<dynamic> a, List<dynamic> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i].toString() != b[i].toString()) return false;
  }
  return true;
}

final Map<ActivityKind, ActivityBinding> activityPlayBindings = {
  ActivityKind.multipleChoice: ActivityBinding(
    initAnswer: initMultipleChoiceAnswer,
    checkAnswer: checkMultipleChoiceAnswer,
    build: buildMultipleChoicePlay,
  ),
  ActivityKind.listenAndTranslate: ActivityBinding(
    initAnswer: initListenAnswer,
    checkAnswer: checkListenAnswer,
    build: buildListenPlay,
  ),
  ActivityKind.translate: ActivityBinding(
    initAnswer: initTranslateAnswer,
    checkAnswer: checkTranslateAnswer,
    build: buildTranslatePlay,
  ),
  ActivityKind.verticalSort: ActivityBinding(
    initAnswer: initVerticalSortAnswer,
    checkAnswer: checkVerticalSortAnswer,
    build: buildVerticalSortPlay,
  ),
  ActivityKind.complete: ActivityBinding(
    initAnswer: initCompleteAnswer,
    checkAnswer: checkCompleteAnswer,
    build: buildCompletePlay,
  ),
  ActivityKind.matching: ActivityBinding(
    initAnswer: initMatchingAnswer,
    checkAnswer: checkMatchingAnswer,
    build: buildMatchingPlay,
  ),
  ActivityKind.dragAndDrop: ActivityBinding(
    initAnswer: initDragAnswer,
    checkAnswer: checkDragAnswer,
    build: buildDragPlay,
  ),
  ActivityKind.flashcard: ActivityBinding(
    initAnswer: initFlashcardAnswer,
    checkAnswer: checkFlashcardAnswer,
    build: buildFlashcardPlay,
  ),
};

/// Binding del tipo, o uno "no soportado" que muestra aviso y deja avanzar
/// (antes los tipos desconocidos trababan al usuario sin salida).
ActivityBinding bindingFor(ActivityKind kind) {
  return activityPlayBindings[kind] ??
      ActivityBinding(
        initAnswer: (_) => null,
        checkAnswer: (_, __) => true,
        build: (context, args) => [
          Text(
            'Tipo "${args.question.questionType}" no soportado todavía.',
            textAlign: TextAlign.center,
          ),
        ],
      );
}
