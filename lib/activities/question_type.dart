// Tipos de actividad de la app.
//
// Fuente única de verdad para los `questionType` de los JSON.
// Si agregas un tipo nuevo, añádelo aquí y en `activity_specs.dart`.
//
// Uso:
//   final kind = ActivityKind.parse(json['questionType']);
//   Text(kind.label) // "Opción múltiple", etc.
//
// Nota: clase con constantes (no enum mejorado) para seguir siendo
// compatible con la restricción `sdk: '>=2.12.0 <3.0.0'` del pubspec
// y que `dart run tool/validate_activities.dart` funcione.

class ActivityKind {
  final String id;
  final String label;

  const ActivityKind._(this.id, this.label);

  static const multipleChoice =
      ActivityKind._('multiple_choice', 'Opción múltiple');
  static const listenAndTranslate =
      ActivityKind._('listen_and_translate', 'Escuchar y traducir');
  static const translate =
      ActivityKind._('translate', 'Traducir (elegir palabras)');
  static const verticalSort =
      ActivityKind._('vertical_sort', 'Ordenar');
  static const complete = ActivityKind._('complete', 'Completar');
  static const matching = ActivityKind._('matching', 'Relacionar');
  static const dragAndDrop =
      ActivityKind._('drag_and_drop', 'Arrastrar');
  static const flashcard =
      ActivityKind._('flashcard_question', 'Flashcard');
  static const conversation =
      ActivityKind._('conversation', 'Conversación');
  static const unknown = ActivityKind._('', 'Actividad');

  static const List<ActivityKind> values = [
    multipleChoice,
    listenAndTranslate,
    translate,
    verticalSort,
    complete,
    matching,
    dragAndDrop,
    flashcard,
    conversation,
    unknown,
  ];

  static ActivityKind parse(String? raw) {
    final v = (raw ?? '').trim();
    for (final k in values) {
      if (k != unknown && k.id == v) return k;
    }
    return unknown;
  }

  bool get isKnown => this != unknown;
}
