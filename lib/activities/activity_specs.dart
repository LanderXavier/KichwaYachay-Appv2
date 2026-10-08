// Fichas de cada actividad + validador del JSON.
//
// Este archivo es Dart PURO (sin Flutter) para que la herramienta
// `tool/validate_activities.dart` pueda usarlo con `dart run`.
//
// Si cambias el contrato de un tipo (qué campos usa), actualiza aquí
// su ficha Y su función `validate*`, y documenta en `docs/ACTIVIDADES.md`.

import 'question_type.dart';

/// Un problema encontrado en un JSON.
class ActivityIssue {
  /// 'error' (rompe la app), 'aviso' (se ve mal o es sospechoso), 'info'.
  final String level;
  final String file;
  final int index;
  final String message;

  const ActivityIssue(this.level, this.file, this.index, this.message);

  @override
  String toString() => '[$level] $file #$index: $message';
}

// ---------------------------------------------------------------------------
// Fichas (para humanos)
// ---------------------------------------------------------------------------

class ActivitySpec {
  final ActivityKind kind;

  /// Qué hace la actividad, en lenguaje no técnico.
  final String whatItDoes;

  /// Qué campos del JSON usa y para qué.
  final String fields;

  /// Ejemplo mínimo copiable.
  final String exampleJson;

  const ActivitySpec({
    required this.kind,
    required this.whatItDoes,
    required this.fields,
    required this.exampleJson,
  });
}

const List<ActivitySpec> activitySpecs = [
  ActivitySpec(
    kind: ActivityKind.multipleChoice,
    whatItDoes:
        'Muestra una pregunta con 2-4 opciones (texto o imagen). El usuario elige una.',
    fields:
        'questionSpanish/questionKichwa: pregunta. imagePath: imagen grande opcional. '
        'optionList: opciones (mínimo 2). correctAnswer: la opción correcta, DEBE existir en optionList. '
        'words y correctOrder siempre vacíos [].',
    exampleJson: '''
{
  "questionSpanish": "¿Cuál es negro?",
  "questionKichwa": "",
  "correctAnswer": "U1_L1_Q1_2.png",
  "audioPath": "",
  "imagePath": "",
  "questionType": "multiple_choice",
  "optionList": ["U1_L1_Q1_2.png", "U1_L1_Q1_1.png"],
  "words": [],
  "correctOrder": []
}''',
  ),
  ActivitySpec(
    kind: ActivityKind.listenAndTranslate,
    whatItDoes:
        'Reproduce un audio y el usuario elige la opción correcta.',
    fields:
        'audioPath: archivo .mp3 OBLIGATORIO (ej: "U1_L1_Q1.mp3", vive en assets/audios/unity_X/lesson_Y/). '
        'optionList: opciones (mínimo 2). correctAnswer: debe existir en optionList. '
        'imagePath: imagen opcional.',
    exampleJson: '''
{
  "questionSpanish": "Escuchar y Traducir",
  "questionKichwa": "",
  "correctAnswer": ["es negro"],
  "audioPath": "U1_L1_Q1.mp3",
  "imagePath": "",
  "questionType": "listen_and_translate",
  "optionList": ["es blanco", "es negro", "es rojo"],
  "words": [],
  "correctOrder": []
}''',
  ),
  ActivitySpec(
    kind: ActivityKind.translate,
    whatItDoes:
        'Muestra una frase en kichwa y varias palabras en español con casillas: el usuario marca las correctas.',
    fields:
        '¡OJO! correctOrder aquí NO es orden: es una lista de true/false del MISMO largo que words. '
        'true = esa palabra SÍ se marca. words: palabras a mostrar. correctAnswer: déjalo vacío "".',
    exampleJson: '''
{
  "questionSpanish": "Traducir:",
  "questionKichwa": "Payka yakutami upyan",
  "correctAnswer": "",
  "audioPath": "",
  "imagePath": "",
  "questionType": "translate",
  "optionList": [],
  "words": ["ella", "bebe", "agua"],
  "correctOrder": [true, true, true]
}''',
  ),
  ActivitySpec(
    kind: ActivityKind.verticalSort,
    whatItDoes:
        'Muestra palabras desordenadas para reordenarlas arrastrando hasta formar la frase.',
    fields:
        'words: palabras DESORDENADAS. correctOrder: palabras en el ORDEN correcto. '
        'Ambas listas del mismo largo y con las MISMAS palabras (pueden cambiar mayúsculas). '
        'imagePath: imagen de ayuda opcional.',
    exampleJson: '''
{
  "questionSpanish": "Ordena Correctamente",
  "questionKichwa": "",
  "correctAnswer": "",
  "audioPath": "",
  "imagePath": "",
  "questionType": "vertical_sort",
  "optionList": [],
  "words": ["killuta", "wiwa"],
  "correctOrder": ["wiwa", "killuta"]
}''',
  ),
  ActivitySpec(
    kind: ActivityKind.complete,
    whatItDoes:
        'Frase con huecos + banco de palabras. El usuario arrastra cada palabra a su hueco. '
        'En el repaso se muestra ya resuelta.',
    fields:
        'optionList: plantilla; cada "" es UN hueco. words: banco de palabras. correctOrder: palabras en orden. '
        'REGLA: nº de "" == largo de correctOrder == largo de words. imagePath: imagen opcional.',
    exampleJson: '''
{
  "questionSpanish": "Ordena Correctamente: El perro es negro",
  "questionKichwa": "",
  "correctAnswer": ["Allkuka yana kan"],
  "audioPath": "",
  "imagePath": "U1_L2_Q2_1.png",
  "questionType": "complete",
  "optionList": ["", "", ""],
  "words": ["kan", "yana", "Allkuka"],
  "correctOrder": ["Allkuka", "yana", "kan"]
}''',
  ),
  ActivitySpec(
    kind: ActivityKind.matching,
    whatItDoes:
        'Dos columnas para emparejar: arrastra cada elemento de la izquierda a su pareja de la derecha.',
    fields:
        'words: columna izquierda. optionList: columna derecha. MISMO largo (mínimo 2). '
        'La pareja correcta es por POSICIÓN: words[0] con optionList[0], etc. correctAnswer: vacío.',
    exampleJson: '''
{
  "questionSpanish": "Relaciona los números en kichwa con su valor",
  "questionKichwa": "Yupaykuna: paktachiy",
  "correctAnswer": "",
  "audioPath": "",
  "imagePath": "",
  "questionType": "matching",
  "words": ["shuk", "ishkay"],
  "optionList": ["1", "2"],
  "correctOrder": []
}''',
  ),
  ActivitySpec(
    kind: ActivityKind.dragAndDrop,
    whatItDoes:
        'Arrastra piezas a sus casillas. Dos modos: REORDENAR (las piezas y el orden son el mismo conjunto) '
        'o RELACIONAR (piezas en un idioma, casillas en otro).',
    fields:
        'words: piezas arrastrables. correctOrder: casillas destino. MISMO largo. '
        'Si words y correctOrder tienen lo mismo (desordenado) = reordenar. '
        'Si son distintos (ej: español vs kichwa) = relacionar por posición. optionList: vacío [].',
    exampleJson: '''
{
  "questionSpanish": "Relacione",
  "questionKichwa": "",
  "correctAnswer": "",
  "audioPath": "",
  "imagePath": "",
  "questionType": "drag_and_drop",
  "optionList": [],
  "words": ["perro", "gato"],
  "correctOrder": ["allku", "misi"]
}''',
  ),
  ActivitySpec(
    kind: ActivityKind.flashcard,
    whatItDoes:
        'Tarjeta informativa con imagen: solo se mira, no se responde. Avanza sola como correcta.',
    fields:
        'imagePath: imagen a mostrar (TEXTO, no lista). questionKichwa: palabra opcional bajo la imagen. '
        'Todo lo demás vacío. Si lleva optionList con opciones, se vuelve pregunta con respuesta.',
    exampleJson: '''
{
  "questionSpanish": "",
  "questionKichwa": "Kuyaylla",
  "correctAnswer": "",
  "audioPath": "",
  "imagePath": "U6_L3_Q17.png",
  "questionType": "flashcard_question",
  "optionList": [],
  "words": [],
  "correctOrder": []
}''',
  ),
];

// ---------------------------------------------------------------------------
// Validador
// ---------------------------------------------------------------------------

List<String> _strList(dynamic v) {
  if (v == null) return [];
  if (v is List) return v.map((e) => e.toString()).toList();
  return [v.toString()];
}

bool _isBoolMask(List<dynamic> v) {
  if (v is! List || v.isEmpty) return false;
  return v.every((e) => e is bool);
}

bool _sameSetCI(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  final sa = a.map((e) => e.trim().toLowerCase()).toList()..sort();
  final sb = b.map((e) => e.trim().toLowerCase()).toList()..sort();
  for (int i = 0; i < sa.length; i++) {
    if (sa[i] != sb[i]) return false;
  }
  return true;
}

void _warnIfListPath(
    Map<String, dynamic> q, String file, int i, List<ActivityIssue> out) {
  for (final k in ['imagePath', 'audioPath']) {
    if (q[k] is List) {
      out.add(ActivityIssue('aviso', file, i,
          '$k viene como lista; se usará solo el primer elemento. Escríbelo como texto.'));
    }
  }
  final audio = q['audioPath'];
  final audioStr = audio is List && audio.isNotEmpty
      ? audio.first.toString()
      : (audio?.toString() ?? '');
  if (audioStr.isNotEmpty &&
      !audioStr.toLowerCase().endsWith('.mp3')) {
    out.add(ActivityIssue('aviso', file, i,
        'audioPath "$audioStr" no termina en .mp3; el reproductor no lo encontrará.'));
  }
}

void _checkQuestion(Map<String, dynamic> q, String file, int index,
    List<ActivityIssue> out) {
  _warnIfListPath(q, file, index, out);

  final rawType = q['questionType']?.toString() ?? '';
  final kind = ActivityKind.parse(rawType);
  if (!kind.isKnown) {
    out.add(ActivityIssue('error', file, index,
        'questionType "$rawType" desconocido. Usa uno de: ${ActivityKind.values.where((k) => k.isKnown).map((k) => k.id).join(', ')}.'));
    return;
  }

  final es = q['questionSpanish']?.toString() ?? '';
  final kq = q['questionKichwa']?.toString() ?? '';
  if (es.isEmpty && kq.isEmpty && kind != ActivityKind.flashcard) {
    out.add(ActivityIssue('aviso', file, index,
        'sin pregunta: questionSpanish y questionKichwa vacíos.'));
  }

  final options = _strList(q['optionList']);
  final words = _strList(q['words']);
  final orderRaw = q['correctOrder'];
  final order = _strList(orderRaw);
  final ca = q['correctAnswer'];
  final caList = ca is List ? ca.map((e) => e.toString()).toList() : <String>[];
  final caStr = ca is List ? '' : (ca?.toString() ?? '');

  switch (kind) {
    case ActivityKind.multipleChoice:
      if (options.length < 2) {
        out.add(ActivityIssue('error', file, index,
            'multiple_choice necesita optionList con mínimo 2 opciones (tiene ${options.length}).'));
      }
      final okValues = ca is List ? caList : (caStr.isEmpty ? <String>[] : [caStr]);
      if (okValues.isEmpty) {
        out.add(ActivityIssue('error', file, index,
            'multiple_choice sin correctAnswer.'));
      } else {
        for (final v in okValues) {
          if (!options.contains(v)) {
            out.add(ActivityIssue('aviso', file, index,
                'correctAnswer "$v" no está en optionList; nunca se podrá acertar.'));
          }
        }
      }
      if (words.isNotEmpty || order.isNotEmpty) {
        out.add(ActivityIssue('aviso', file, index,
            'multiple_choice con words/correctOrder no vacíos; esos campos se ignoran en este tipo.'));
      }
      break;

    case ActivityKind.listenAndTranslate:
      if ((q['audioPath']?.toString() ?? '').isEmpty &&
          !(q['audioPath'] is List && (q['audioPath'] as List).isNotEmpty)) {
        out.add(ActivityIssue('error', file, index,
            'listen_and_translate sin audioPath. Sin audio no se puede resolver.'));
      }
      if (options.length < 2) {
        out.add(ActivityIssue('error', file, index,
            'listen_and_translate necesita optionList con mínimo 2 opciones.'));
      }
      if (caStr.isNotEmpty && !options.contains(caStr)) {
        out.add(ActivityIssue('aviso', file, index,
            'correctAnswer "$caStr" no está en optionList.'));
      }
      break;

    case ActivityKind.translate:
      if (words.isEmpty) {
        out.add(ActivityIssue(
            'error', file, index, 'translate sin words: no hay nada que mostrar.'));
      }
      if (!_isBoolMask(orderRaw)) {
        out.add(ActivityIssue('error', file, index,
            'translate con correctOrder que NO es lista de true/false. Aquí correctOrder marca con true/false qué palabras de words son correctas, del mismo largo.'));
      } else if ((orderRaw as List).length != words.length) {
        out.add(ActivityIssue('error', file, index,
            'translate con ${words.length} words pero ${(orderRaw as List).length} marcas true/false: deben ser iguales.'));
      }
      break;

    case ActivityKind.verticalSort:
      if (words.length < 2 || order.length < 2) {
        out.add(ActivityIssue('error', file, index,
            'vertical_sort necesita words y correctOrder con mínimo 2 palabras.'));
      } else {
        if (words.length != order.length) {
          out.add(ActivityIssue('error', file, index,
              'vertical_sort con ${words.length} words y ${order.length} en correctOrder: deben ser iguales.'));
        } else if (!_sameSetCI(words, order)) {
          out.add(ActivityIssue('aviso', file, index,
              'vertical_sort donde words y correctOrder no tienen las mismas palabras; alguna sobra o falta y no se podrá resolver.'));
        }
      }
      break;

    case ActivityKind.complete:
      if (options.isEmpty) {
        out.add(ActivityIssue('error', file, index,
            'complete sin optionList: la plantilla de huecos ("") vive ahí.'));
      } else {
        final blanks = options.where((e) => e.isEmpty).length;
        if (blanks == 0) {
          out.add(ActivityIssue('aviso', file, index,
              'complete sin ningún "" en optionList: no habrá huecos que rellenar.'));
        } else if (blanks != order.length) {
          out.add(ActivityIssue('error', file, index,
              'complete con $blanks huecos pero ${order.length} palabras en correctOrder: deben coincidir.'));
        }
      }
      if (words.length != order.length) {
        out.add(ActivityIssue('error', file, index,
            'complete con ${words.length} words y ${order.length} en correctOrder: deben ser iguales.'));
      } else if (words.isNotEmpty && !_sameSetCI(words, order)) {
        out.add(ActivityIssue('aviso', file, index,
            'complete donde el banco (words) y correctOrder no coinciden; revisa que no sobre ni falte palabra.'));
      }
      break;

    case ActivityKind.matching:
      if (words.length < 2 || options.length < 2) {
        out.add(ActivityIssue('error', file, index,
            'matching necesita words y optionList con mínimo 2 elementos.'));
      } else if (words.length != options.length) {
        out.add(ActivityIssue('error', file, index,
            'matching con ${words.length} en words y ${options.length} en optionList: las parejas van por posición y deben ser iguales.'));
      }
      break;

    case ActivityKind.dragAndDrop:
      if (words.isEmpty || order.isEmpty) {
        out.add(ActivityIssue('error', file, index,
            'drag_and_drop necesita words y correctOrder no vacíos.'));
      } else if (words.length != order.length) {
        out.add(ActivityIssue('error', file, index,
            'drag_and_drop con ${words.length} piezas y ${order.length} casillas: deben ser iguales.'));
      }
      break;

    case ActivityKind.flashcard:
      break;

    case ActivityKind.conversation:
    case ActivityKind.unknown:
      break;
  }
}

/// Valida UNA pregunta dict. Las hojas de conversación (listas) se reportan
/// como info y se saltan: no son preguntas.
void validateItem(dynamic item, String file, int index, List<ActivityIssue> out) {
  if (item is! Map) {
    out.add(ActivityIssue('info', file, index,
        'bloque de conversación (lista), no es pregunta: se omite en presentación y repaso.'));
    return;
  }
  try {
    _checkQuestion(Map<String, dynamic>.from(item), file, index, out);
  } catch (e) {
    out.add(ActivityIssue(
        'error', file, index, 'no se pudo leer la pregunta: $e'));
  }
}
