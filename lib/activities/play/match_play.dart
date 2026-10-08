// Tipo de actividad: drag_and_drop y matching (tablero de arrastre compartido).
//
// Ambas usan el mismo tablero: piezas a la izquierda, casillas a la derecha.
// - drag_and_drop: `answer` son las piezas colocadas; gana si cada casilla
//   tiene su valor de `correctOrder`.
// - matching: gana si cada casilla tiene su valor de `words`
//   (las parejas van por posición con `optionList`).
// `answer` es List<String> del largo de las casillas, "" = vacía.

import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/activity_media.dart';
import 'package:language_learning_ui/activities/play/activity_play.dart';
import 'package:language_learning_ui/models/question_model.dart';

// --- drag_and_drop ---

dynamic initDragAnswer(Question q) =>
    List<String>.filled(q.correctOrder.length, '');

bool checkDragAnswer(Question q, dynamic answer) {
  if (answer is! List) return false;
  final placed = List<dynamic>.from(answer);
  if (placed.length != q.correctOrder.length) return false;
  return activityListEquals(placed, q.correctOrder);
}

List<Widget> buildDragPlay(BuildContext context, PlayArgs args) {
  return buildMatchBoard(context, args,
      words: args.question.words, targets: args.question.correctOrder);
}

// --- matching ---

dynamic initMatchingAnswer(Question q) =>
    List<String>.filled(q.optionList.length, '');

bool checkMatchingAnswer(Question q, dynamic answer) {
  if (answer is! List) return false;
  final placed = List<dynamic>.from(answer);
  if (placed.length != q.optionList.length ||
      q.words.length != q.optionList.length) {
    return false;
  }
  for (int i = 0; i < q.optionList.length; i++) {
    if (placed[i].toString() != q.words[i].toString()) return false;
  }
  return true;
}

List<Widget> buildMatchingPlay(BuildContext context, PlayArgs args) {
  return buildMatchBoard(context, args,
      words: args.question.words, targets: args.question.optionList);
}

// --- Tablero compartido ---

Widget buildMatchItem(
    BuildContext context, String value, int unity, String lesson) {
  final isImage = looksLikeLessonImage(value);
  return Container(
    width: 100,
    height: 100,
    alignment: Alignment.center,
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.blue[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: isImage
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SafeActivityImage(
              resolveImageAsset(unity, lesson, value),
              width: 100,
              height: 100,
            ),
          )
        : Text(value, style: const TextStyle(fontSize: 18)),
  );
}

List<Widget> buildMatchBoard(
  BuildContext context,
  PlayArgs args, {
  required List<String> words,
  required List<String> targets,
}) {
  final raw = args.answer;
  List<String> placed = raw is List
      ? List<String>.from(raw.map((e) => e.toString()))
      : <String>[];
  if (placed.length != targets.length) {
    placed = List<String>.filled(targets.length, '');
  }
  final availableWords = List<String>.from(words);

  void place(int index, String data) {
    final updated = List<String>.from(placed);
    final previousIndex = updated.indexOf(data);
    if (previousIndex != -1) updated[previousIndex] = '';
    updated[index] = data;
    args.onChanged(updated);
  }

  void clear(int index) {
    final updated = List<String>.from(placed);
    updated[index] = '';
    args.onChanged(updated);
  }

  return [
    const SizedBox(height: 20),
    const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.swap_vert, color: Colors.blue),
        SizedBox(width: 8),
        Text('Arrastra cada elemento a su lugar correcto:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    ),
    const SizedBox(height: 20),
    Expanded(
      child: SingleChildScrollView(
        key: args.matchScrollKey,
        controller: args.matchScrollController,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: availableWords.map((word) {
                  if (placed.contains(word)) {
                    return const SizedBox(width: 100, height: 100);
                  }
                  return Draggable<String>(
                    data: word,
                    feedback: Material(
                      color: Colors.transparent,
                      child: buildMatchItem(
                          context, word, args.unity, args.lesson),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: buildMatchItem(
                          context, word, args.unity, args.lesson),
                    ),
                    child: buildMatchItem(
                        context, word, args.unity, args.lesson),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: Column(
                children: targets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final hasValue = index < placed.length &&
                      placed[index].isNotEmpty;
                  const candidateHighlightColor = Colors.green;
                  return DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: hasValue
                                        ? Colors.green[100]
                                        : Colors.grey[200],
                                    border: Border.all(
                                      color: candidateData.isNotEmpty
                                          ? candidateHighlightColor
                                          : Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: hasValue
                                      ? buildMatchItem(context,
                                          placed[index], args.unity, args.lesson)
                                      : const SizedBox.shrink(),
                                ),
                                if (hasValue)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.black.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () => clear(index),
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints:
                                            const BoxConstraints.tightFor(
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              stripExtension(label),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                    onWillAccept: (_) => true,
                    onAccept: (data) => place(index, data),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 20),
  ];
}
