# KichwaYachay — Aprende kichwa jugando 🇪🇨

Aplicación móvil y de escritorio **estilo Duolingo** para aprender kichwa,
construida con **Flutter**. Cada unidad tiene lecciones con actividades
interactivas (opción múltiple, ordenar, arrastrar, relacionar, audio, flashcards…)
y pantalla de **repaso** por lección.

## ✨ Qué incluye

- **Unidades y lecciones**: catálogo por niveles (`Dashboard` → unidad → `Mis lecciones`).
- **8 tipos de actividad** configurables por JSON, sin tocar código para crear preguntas nuevas.
- **Repaso por lección**: muestra cada actividad ya resuelta (pares, frases, opciones correctas).
- **Validación de contenido**: `dart run tool/validate_activities.dart` detecta errores en los JSON antes de probar.
- **Linux + Android**: corre en escritorio KDE y en celular con el mismo código.

### Screenshots (originales del autor)

<img src="https://i.ibb.co/jTggZrT/img-01.png" width="420" height="800">
<img src="https://i.ibb.co/ZGz9d1W/01-lessons.png" width="420" height="800">
<img src="https://i.ibb.co/fYBj1Vm/04-quiz-screen.png" width="420" height="800">


https://ibb.co/dgtRvkR

## 🗂️ Estructura del proyecto

```
assets/database/unity_X_lesson_Y.json  ← contenido (aquí se editan actividades)
assets/images/unity_X/lesson_Y/        ← imágenes de cada lección
assets/audios/unity_X/lesson_Y/        ← audios (.mp3)
lib/activities/                        ← sistema de actividades
  question_type.dart                   ← los 8 tipos (fuente única)
  activity_specs.dart                  ← contrato + validación por tipo
  activity_media.dart                  ← rutas de imágenes (un solo lugar)
  play/<tipo>_play.dart                ← cómo se resuelve cada tipo
  review/<tipo>_review.dart            ← cómo se repasa cada tipo
lib/pages/quiz_screen.dart             ← repartidor (NO editar por tipo)
lib/pages/review_quiz_page.dart        ← repartidor del repaso
tool/validate_activities.dart          ← validador de JSON
docs/ACTIVIDADES.md                    ← guía completa (¡léela!)
```

## 📝 Crear o corregir actividades (sin programar Flutter)

1. Lee **`docs/ACTIVIDADES.md`** (§3 trae ejemplo JSON copiable de cada tipo).
2. Edita el `assets/database/unity_X_lesson_Y.json` correspondiente.
3. Si es lección nueva, declárala en `pubspec.yaml` (sección `assets`).
4. Valida: `dart run tool/validate_activities.dart` (0 errores).
5. Prueba: `flutter run -d linux` → juega + repasa.

## 🆕 Agregar un tipo de actividad nuevo (9º, 10º…)

Ver checklist con esqueletos copiables en **`docs/ACTIVIDADES.md` §8**:
1 archivo en `play/` + 1 línea de registro + constante + ficha/validación +
vista de repaso + ejemplo en docs. `quiz_screen.dart` no se toca.

## 🧑‍💻 Flujo normal: descargar, modificar y probar (VS Code + Flutter + Android Studio)

```bash
git clone https://github.com/LanderXavier/KichwaYachay-Appv2.git
cd KichwaYachay-Appv2
flutter pub get
dart run tool/validate_activities.dart   # contenido OK (0 errores)
```

- **VS Code**: abre la carpeta, instala las extensiones *Flutter* y *Dart*.
  `F5` o `flutter run -d linux` para probar en escritorio,
  `flutter run -d android` con el celular en depuración USB.
- **Android Studio**: *Open* → la carpeta del proyecto (no la subcarpeta `android/`),
  instala el plugin Flutter si falta, elige dispositivo y ▶ Run.
  Para el APK: `flutter build apk --debug` → sale en
  `build/app/outputs/flutter-apk/app-debug.apk`, cópialo al celular e instálalo.
- **Solo contenido** (preguntas, sin programar): edita los JSON de
  `assets/database/` siguiendo `docs/ACTIVIDADES.md` y valida antes de probar.

## 💻 Requisitos y cómo correr

- Flutter SDK estable (`https://docs.flutter.dev/get-started/install`)
- Linux: `clang cmake ninja pkgconf gtk3` · Android: Android SDK

```bash
flutter pub get
dart run tool/validate_activities.dart   # contenido OK
flutter run -d linux                     # escritorio
flutter run -d android                   # celular (con SDK / depuración USB)
```

## 📦 Origen

Interfaz base: Language Learning Flutter UI de ariscybertech
(`https://github.com/ariscybertech/aris_language_learning`),
adaptada y extendida con contenido kichwa, nuevos tipos de actividad,
repaso, validador y soporte Linux.

### Built From Language Learning Flutter UI By ariscybertech

https://github.com/ariscybertech/aris_language_learning

![Main Page](https://res.cloudinary.com/olayemii/image/upload/v1611748849/assets/language-1_oestuf.png)
