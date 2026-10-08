// Helpers compartidos de imágenes/texto para PRESENTAR y REPASAR.
//
// Antes esta lógica estaba duplicada en `quiz_screen.dart` y
// `review_quiz_page.dart`. Cualquier cambio de rutas o de cómo se
// detectan imágenes se hace aquí una sola vez.

import 'package:flutter/material.dart';

/// Quita la extensión para mostrar: "U1_L1_Q1_1.png" -> "U1_L1_Q1_1".
String stripExtension(String s) {
  return s.replaceAll(RegExp(r'\.[^.\s]+$', caseSensitive: false), '');
}

bool hasImageExtension(String value) {
  final v = value.toLowerCase();
  return v.endsWith('.png') || v.endsWith('.jpg') || v.endsWith('.jpeg');
}

/// True si el valor parece una imagen de lección, con o sin extensión:
/// "U1_L2_Q2_1.png", "U1_L2_Q2_1", "Allku.png".
bool looksLikeLessonImage(String value) {
  if (value.isEmpty) return false;
  return hasImageExtension(value) ||
      RegExp(r'^U\d+_L\d+_Q\d+(?:_\d+)?$').hasMatch(value);
}

String normalizeImageFileName(String value) {
  if (value.isEmpty) return value;
  if (hasImageExtension(value)) return value;
  return '$value.png';
}

/// Ruta del asset de imagen de una actividad.
/// Copia exacta de la convención usada en la presentación.
String lessonImageAsset(int unity, String lesson, String fileName) {
  return 'assets/images/unity_$unity/lesson_$lesson/${normalizeImageFileName(fileName)}';
}

String resolveImageAsset(int unity, String lesson, String fileName) {
  if (fileName.isEmpty) return fileName;
  if (fileName.startsWith('assets/')) return fileName;
  return lessonImageAsset(unity, lesson, fileName);
}

/// Imagen que no rompe si el asset no existe: muestra espacio vacío.
class SafeActivityImage extends StatelessWidget {
  final String assetPath;
  final double? height;
  final double? width;
  final BoxFit fit;

  const SafeActivityImage(
    this.assetPath, {
    Key? key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assetPath.isEmpty) return const SizedBox.shrink();
    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}

/// Muestra un valor como imagen+texto si parece imagen, o texto plano.
class TextOrImage extends StatelessWidget {
  final String value;
  final int unity;
  final String lesson;
  final double imgSize;

  const TextOrImage(
    this.value, {
    Key? key,
    required this.unity,
    required this.lesson,
    this.imgSize = 44,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (looksLikeLessonImage(value)) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeActivityImage(
            resolveImageAsset(unity, lesson, value),
            height: imgSize,
            width: imgSize,
          ),
          const SizedBox(width: 6),
          Flexible(child: Text(stripExtension(value))),
        ],
      );
    }
    return Text(value);
  }
}
