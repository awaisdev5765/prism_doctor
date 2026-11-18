// Copyright 2026 Awais Rehman. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:prism_doctor/src/auditor.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('prism_doctor_test');
  });
  tearDown(() {
    tmp.deleteSync(recursive: true);
  });

  test('flags hardcoded colors and magic numbers', () {
    File('${tmp.path}/lib/main.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync('''
import 'package:flutter/material.dart';
void main() {
  final c = Color(0xFF123456);
  final p = EdgeInsets.all(16);
}
''');
    final report = Auditor(root: tmp.path).audit();
    final rules = report.findings.map((f) => f.rule).toSet();
    expect(rules, contains('no_hardcoded_colors'));
    expect(rules, contains('no_magic_numbers'));
    expect(report.filesScanned, 1);
  });

  test('flags deprecated material import', () {
    File('${tmp.path}/lib/widget.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync(
          "import 'package:flutter/material.dart';\nvoid x() {}\n");
    final report = Auditor(root: tmp.path).audit();
    expect(report.findings.any((f) => f.rule == 'no_deprecated_material_import'),
        isTrue);
  });

  test('skips build directories and test files for color check', () {
    File('${tmp.path}/build/cache.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync('final c = Color(0xFF123456);\n');
    File('${tmp.path}/test/widget_test.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync('final c = Color(0xFF123456);\n');
    final report = Auditor(root: tmp.path).audit();
    expect(report.findings.where((f) => f.rule == 'no_hardcoded_colors'),
        isEmpty);
  });

  test('perfect project scores 100', () {
    File('${tmp.path}/lib/clean.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync('import "package:material_ui/material_ui.dart";\n'
          'void x() {}\n');
    final report = Auditor(root: tmp.path).audit();
    expect(report.score, 100);
    expect(report.grade, 'A');
  });
}
