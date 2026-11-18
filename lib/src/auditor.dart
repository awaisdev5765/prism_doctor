// Copyright 2026 Awais Rehman. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;

import 'checks.dart';
import 'report.dart';

/// Walks a project and runs every [Check] over Dart sources.
class Auditor {
  Auditor({required this.root, List<Check>? checks})
      : checks = checks ?? defaultChecks;

  final String root;
  final List<Check> checks;

  static const _skipDirs = {
    '.dart_tool',
    'build',
    '.git',
    '.idea',
    'ephemeral',
  };

  Report audit() {
    final findings = <Finding>[];
    var files = 0;

    final dir = Directory(root);
    if (!dir.existsSync()) {
      throw ArgumentError('Not a directory: $root');
    }

    final entries = dir
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((f) {
          final rel = p.relative(f.path, from: root);
          final parts = p.split(rel);
          if (parts.any(_skipDirs.contains)) {
            return false;
          }
          // Only lib/ + test/ + bin/ Dart sources by default.
          return rel.endsWith('.dart');
        });

    for (final file in entries) {
      files++;
      final source = file.readAsStringSync();
      final rel = p.relative(file.path, from: root);
      for (final check in checks) {
        findings.addAll(check.run(rel, source));
      }
    }

    return Report(root: root, findings: findings, filesScanned: files);
  }
}
