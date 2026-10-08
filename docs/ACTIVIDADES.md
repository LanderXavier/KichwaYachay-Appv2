# Guía de actividades (para quienes NO programaron la app)

> Lee esto antes de tocar cualquier `assets/database/unity_*_lesson_*.json`.
> Si solo vas a crear o corregir actividades, con este documento + el
> validador te alcanza. No necesitas entender todo el código Flutter.

## 1. Mapa rápido: dónde vive cada cosa

| Quiero... | Voy a... |
|---|---|
| Crear/corregir una actividad | Edito el JSON de la lección + corro el validador (§5) |
| Saber qué campos usa cada tipo | `lib/activities/activity_specs.dart` (fichas con ejemplo) |
| Cambiar cómo SE PRESENTA un tipo | `lib/activities/play/<tipo>_play.dart` (3 funciones, §8) |
| Cambiar cómo SE REPASA un tipo | `lib/activities/review/<tipo>_review.dart` (ver `activity_review.dart`) |
| Cambiar rutas de imágenes | `lib/activities/activity_media.dart` (una sola vez) |
| Agregar un tipo nuevo | Checklist de §8 (1 archivo del tipo de actividad + 1 línea de registro + resto) |

## 2. Reglas de oro (las que rompían la app)

1. **Los 8 tipos comparten los mismos campos**, pero cada tipo usa unos y ignora otros. Lee la ficha de tu tipo antes de escribir.
2. **`correctOrder` significa cosas distintas según el tipo**: en `vertical_sort`/`complete` es el orden correcto; en `translate` es una lista de `true/false`; en `matching` va vacío.
3. **Las parejas van por posición**: en `matching`, `words[0]` empareja con `optionList[0]`, etc. Mismo largo obligatorio.
4. **`imagePath` y `audioPath` son TEXTO**, no lista. Si pones `["foto.png"]`, se usa solo el primero y sale un aviso.
5. **Audios**: `audioPath` debe terminar en `.mp3` y el archivo debe existir en `assets/audios/unity_X/lesson_Y/`.
6. **Imágenes**: se buscan en `assets/images/unity_X/lesson_Y/`. Vale `"U1_L2_Q2_1.png"` o `"U1_L2_Q2_1"` (sin extensión también funciona).
7. **Lección nueva = archivo + pubspec**: si creas `unity_7_lesson_1.json`, agrégalo en `pubspec.yaml` bajo `assets:` (sección Database Values) o no se cargará.
8. **Las hojas de conversación** (listas con `speaker`/`bot`) NO son preguntas: la presentación y el repaso las omiten automáticamente, pero no las mezcles dentro de una pregunta.

## 3. Los 8 tipos (contrato de campos + ejemplo JSON)

> Todos los ejemplos salen de tu base de datos real. Cópialos y cambia los textos.

### multiple_choice — elegir una opción
- `optionList`: mínimo 2 opciones. `correctAnswer`: la correcta, **debe existir** en `optionList`. `words`/`correctOrder`: `[]`.
```json
{
  "questionSpanish": "¿Cuál es blanco?",
  "questionKichwa": "",
  "correctAnswer": "U1_L1_Q1_1.png",
  "audioPath": "",
  "imagePath": "",
  "questionType": "multiple_choice",
  "optionList": ["U1_L1_Q1_2.png", "U1_L1_Q1_1.png"],
  "words": [],
  "correctOrder": []
}
```

### listen_and_translate — escuchar y elegir
- `audioPath`: `.mp3` obligatorio (vive en `assets/audios/unity_X/lesson_Y/`). `optionList`: mínimo 2. `correctAnswer` dentro de `optionList`.
```json
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
}
```

### translate — marcar palabras (¡caso especial!)
- `words`: palabras a mostrar. `correctOrder`: lista de `true/false` **del mismo largo** (`true` = esa palabra se marca). `correctAnswer`: `""`.
```json
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
}
```

### vertical_sort — ordenar arrastrando
- `words`: desordenadas. `correctOrder`: en orden. Mismo largo y **mismas palabras**.
```json
{
  "questionSpanish": "Ordena Correctamente",
  "questionKichwa": "",
  "correctAnswer": ["wiwa killuta"],
  "audioPath": "",
  "imagePath": "",
  "questionType": "vertical_sort",
  "optionList": [],
  "words": ["killuta", "wiwa"],
  "correctOrder": ["wiwa", "killuta"]
}
```

### complete — frase con huecos
- `optionList`: plantilla, cada `""` es un hueco. `words`: banco. `correctOrder`: en orden.
- **Nº de `""` == largo de `correctOrder` == largo de `words`.**
```json
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
}
```

### matching — relacionar dos columnas
- `words` (izquierda) y `optionList` (derecha), mismo largo, mínimo 2. Pareja por posición: `words[0]` con `optionList[0]`, etc. `correctAnswer`: `""`.
```json
{
  "questionSpanish": "Relaciona los números en kichwa con su valor",
  "questionKichwa": "Yupaykuna: paktachiy",
  "correctAnswer": "",
  "audioPath": "",
  "imagePath": "",
  "questionType": "matching",
  "words": ["shuk", "ishkay", "kimsa", "chusku", "pichka"],
  "optionList": ["1", "2", "3", "4", "5"],
  "correctOrder": []
}
```

### drag_and_drop — arrastrar piezas
- `words`: piezas. `correctOrder`: casillas. Mismo largo. `optionList`: `[]`.
- Mismo conjunto desordenado = reordenar; conjuntos distintos (español/kichwa, como aquí) = relacionar por posición.
```json
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
}
```

### flashcard_question — tarjeta informativa
- Solo se mira. `imagePath` como **texto** (no lista) + `questionKichwa` opcional, resto vacío. Con `optionList` se vuelve pregunta.
```json
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
}
```

## 4. Ejemplo completo de lección

```json
[
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
  },
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
  }
]
```

## 5. Validador (úsalo siempre antes de probar)

```bash
export PATH="$HOME/dev/flutter/bin:$PATH"
dart run tool/validate_activities.dart
```

- `[error]` = la app se rompe o la actividad no se puede resolver. Corrige antes de probar.
- `[aviso]` = funciona pero se ve mal o es sospechoso (respuesta fuera de opciones, audio sin `.mp3`, imagen que no existe).
- `[info]` = solo informativo (hojas de conversación).

## 6. Agregar una lección nueva (checklist)

1. Crea `assets/database/unity_X_lesson_Y.json` copiando los ejemplos de §3 (uno por tipo).
2. Decláralo en `pubspec.yaml` (assets → Database Values).
3. Pon sus imágenes en `assets/images/unity_X/lesson_Y/` y audios en `assets/audios/unity_X/lesson_Y/`.
4. Corre el validador y corrige errores/avisos.
5. Prueba en Linux: `flutter run -d linux` → entra a la unidad → resuelve + repasa.

## 7. Errores reales que ya encontramos (para no repetirlos)

- Unidad 2: `translate` con `correctOrder` de palabras en vez de `true/false` → crasheaba el repaso.
- Unidad 6: `flashcard` con `imagePath` como lista `["...png"]` → se mostraba `[..]` en vez de la imagen.
- Unidad 6 lecciones 2 y 4: hoja de conversación colada como pregunta → crasheaba la presentación.
- `complete` con distinto nº de huecos y palabras → casilleros imposibles.
- `audioPath` con texto de frase en vez de `.mp3` → botón de audio muerto.

## 8. Agregar un tipo NUEVO (ej: un 9º `questionType`)

### 8.1 Cómo fluye una actividad (para ubicarte)

```
JSON de la lección
  → Question (parseo tolerante en lib/classes/ y lib/models/)
  → ActivityKind.parse(questionType)
  → PRESENTACIÓN: activityPlayBindings[kind] en play/activity_play.dart
      (init → build → check, todo en play/<tipo>_play.dart)
  → REPASO: buildActivityReview() en review/activity_review.dart
      (un archivo por tipo en review/)
```

`quiz_screen.dart` (251 líneas) y `review_quiz_page.dart` son repartidores:
muestran el enunciado y delegan. **No se tocan** para un tipo nuevo.

### 8.2 Formas de `answer` que ya existen

| Tipo | `answer` es | Vacío inicial |
|---|---|---|
| `multiple_choice`, `listen_and_translate` | `int` (índice elegido) | `-1` |
| `translate` | `List<bool>` paralelo a `words` | todo `false` |
| `vertical_sort` | `List<String>` en orden del usuario | copia de `words` |
| `complete`, `drag_and_drop`, `matching` | `List<String>` casillas (`""` = vacía) | todo `""` |
| `flashcard_question` | `String?` (opción elegida) | `null` |

### 8.3 Paso a paso con esqueletos copiables

**1. Presentación del tipo de actividad**: crea `lib/activities/play/mi_tipo_play.dart`.
Copia `multiple_choice_play.dart` (elegir) o `match_play.dart` (arrastrar):

```dart
import 'package:flutter/material.dart';
import 'package:language_learning_ui/activities/play/activity_play.dart';
import 'package:language_learning_ui/models/question_model.dart';

// 1) Respuesta vacía (también se usa para reiniciar tras fallar).
dynamic initMiTipoAnswer(Question q) => -1;

// 2) Corrección: true si gana. Hay ayuda: activityListEquals(a, b)
// compara listas como texto.
bool checkMiTipoAnswer(Question q, dynamic answer) {
  return answer == q.correctAnswer;
}

// 3) Widgets. Lee args.question y args.answer;
// avisa cambios con args.onChanged(nuevoValor).
// Audio: args.playAudio("archivo.mp3").
// Imágenes: TextOrImage(...) / SafeActivityImage(...) de activity_media.dart.
List<Widget> buildMiTipoPlay(BuildContext context, PlayArgs args) {
  return [
    Text('Mi tipo: ${args.question.questionSpanish}'),
  ];
}
```

`PlayArgs` trae: `question`, `unity`, `lesson`, `answer`, `onChanged`,
`playAudio`, `matchScrollController`, `matchScrollKey` (estos dos últimos
solo para tableros de arrastre).

**2. Registro**: 1 línea en `activityPlayBindings`
(`lib/activities/play/activity_play.dart`):

```dart
ActivityKind.miTipo: ActivityBinding(
  initAnswer: initMiTipoAnswer,
  checkAnswer: checkMiTipoAnswer,
  build: buildMiTipoPlay,
),
```

**3. Tipo**: 1 constante en `lib/activities/question_type.dart`:

```dart
static const miTipo = ActivityKind._('mi_tipo', 'Mi tipo');
```

(y agrégala a la lista `values`).

**4. Contrato**: 1 ficha con ejemplo + 1 rama `case` en el validador,
ambas en `lib/activities/activity_specs.dart` (copia un tipo parecido).
Desde ese momento `dart run tool/validate_activities.dart` revisa tu tipo.

**5. Repaso**: 1 archivo `lib/activities/review/mi_tipo_review.dart` con
`Widget buildMiTipoReview(context, q, unity, lesson)` + 1 caso en el `switch`
de `activity_review.dart`. Si tu tipo no necesita repaso especial, el `default`
muestra la respuesta en texto y listo.

**6. Docs**: 1 subsección en §3 de esta guía con su ejemplo JSON.

**7. Verifica**:
```bash
dart run tool/validate_activities.dart   # datos
flutter analyze                          # código (0 errores)
flutter run -d linux                     # resuelve + repasa el tipo nuevo
```
