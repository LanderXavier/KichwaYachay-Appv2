// Validador de actividades: revisa TODOS los JSON de lecciones.
//
// Uso:
//   dart run tool/validate_activities.dart
//
// Sale con código 1 si hay al menos un [error].
// No necesita Flutter: usa solo las fichas puras de lib/activities/.

import 'dart:convert';
import 'dart:io';

import '../lib/activities/activity_specs.dart';

bool _looksLikeImage(String v) {
  if (v.isEmpty) return false;
  final lower = v.toLowerCase();
  return lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      RegExp(r'^U\d+_L\d+_Q\d+(?:_\d+)?$').hasMatch(v);
}

String _withPng(String v) {
  final lower = v.toLowerCase();
  if (lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg')) {
    return v;
  }
  return '$v.png';
}

void main() {
  final dbDir = Directory('assets/database');
  if (!dbDir.existsSync()) {
    print('No existe assets/database. Corre desde la raíz del proyecto.');
    exit(2);
  }

  final files = dbDir
      .listSync()
      .whereType<File>()
      .where((f) => RegExp(r'unity_\d+_lesson_\d+\.json')
          .hasMatch(f.path.split(Platform.pathSeparator).last))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final pubspec =
      File('pubspec.yaml').existsSync() ? File('pubspec.yaml').readAsStringSync() : '';

  final issues = <ActivityIssue>[];
  var questions = 0;

  for (final file in files) {
    final name = file.path.split(Platform.pathSeparator).last;
    final m = RegExp(r'unity_(\d+)_lesson_(\d+)\.json').firstMatch(name)!;
    final unity = m.group(1)!;
    final lesson = m.group(2)!;

    if (pubspec.isNotEmpty && !pubspec.contains('assets/database/$name')) {
      issues.add(ActivityIssue('aviso', name, -1,
          'el archivo NO está declarado en pubspec.yaml (assets): no se cargará en la app.'));
    }

    List<dynamic> data;
    try {
      data = json.decode(file.readAsStringSync()) as List<dynamic>;
    } catch (e) {
      issues.add(ActivityIssue('error', name, -1, 'JSON inválido: $e'));
      continue;
    }

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      validateItem(item, name, i, issues);
      if (item is! Map) continue;
      questions++;
      final q = Map<String, dynamic>.from(item);

      // Chequeo de assets referenciados.
      final imageCandidates = <String>[];
      final ip = q['imagePath'];
      if (ip is List) {
        imageCandidates.addAll(ip.map((e) => e.toString()));
      } else if (ip != null && ip.toString().isNotEmpty) {
        imageCandidates.add(ip.toString());
      }
      for (final listKey in ['optionList', 'words', 'correctOrder']) {
        final v = q[listKey];
        if (v is List) {
          for (final e in v) {
            if (e.toString().isNotEmpty && _looksLikeImage(e.toString())) {
              imageCandidates.add(e.toString());
            }
          }
        }
      }
      for (final img in imageCandidates.toSet()) {
        final rel =
            'assets/images/unity_$unity/lesson_$lesson/${_withPng(img)}';
        if (!File(rel).existsSync()) {
          issues.add(ActivityIssue('aviso', name, i,
              'imagen "$img" no existe como $rel.'));
        }
      }

      final ap = q['audioPath'];
      final audioStr = ap is List && ap.isNotEmpty
          ? ap.first.toString()
          : (ap?.toString() ?? '');
      if (audioStr.isNotEmpty && audioStr.toLowerCase().endsWith('.mp3')) {
        final rel = 'assets/audios/unity_$unity/lesson_$lesson/$audioStr';
        if (!File(rel).existsSync()) {
          issues.add(ActivityIssue('aviso', name, i,
              'audio "$audioStr" no existe como $rel.'));
        }
      }
    }
  }

  final errors = issues.where((e) => e.level == 'error').length;
  final warns = issues.where((e) => e.level == 'aviso').length;
  final infos = issues.where((e) => e.level == 'info').length;

  print('Revisados ${files.length} archivos, $questions preguntas.');
  print('Errores: $errors | Avisos: $warns | Info: $infos\n');
  for (final issue in issues) {
    print(issue);
  }

  if (errors > 0) {
    print('\nHay errores: corrígelos antes de probar (ver docs/ACTIVIDADES.md).');
    exit(1);
  }
  print('\nSin errores. Los avisos conviene revisarlos.');
}
