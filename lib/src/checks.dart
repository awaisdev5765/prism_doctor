// Copyright 2026 Awais Rehman. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'report.dart';

/// Line-based heuristic checks (fast, analyzer-free core).
///
/// The companion analyzer-powered rules live in `lints.dart` as
/// custom_lint rules for IDE feedback; these CLI checks cover the same
/// ground for CI audits without requiring the analyzer driver.
const defaultChecks = <Check>[
  _HardcodedColorCheck(),
  _MagicNumberCheck(),
  _DeprecatedMaterialImportCheck(),
];

class _HardcodedColorCheck implements Check {
  const _HardcodedColorCheck();

  @override
  String get id => 'no_hardcoded_colors';

  @override
  String get description =>
      'Color(0x...) literals outside test files should be tokens/theme colors.';

  @override
  List<Finding> run(String filePath, String source) {
    final findings = <Finding>[];
    if (filePath.contains('/test/') || filePath.contains('test/')) {
      return findings;
    }
    final pattern = RegExp(r'Color\(0x[0-9a-fA-F]{8}\)');
    final lines = source.split('\n');
    for (var i = 0; i < lines.length; i++) {
      for (final match in pattern.allMatches(lines[i])) {
        findings.add(Finding(
          file: filePath,
          line: i + 1,
          column: match.start + 1,
          rule: id,
          message: 'hardcoded color ${match.group(0)}',
          severity: 'warning',
        ));
      }
    }
    return findings;
  }
}

class _MagicNumberCheck implements Check {
  const _MagicNumberCheck();

  @override
  String get id => 'no_magic_numbers';

  @override
  String get description =>
      'Raw numeric arguments to EdgeInsets/SizedBox(width:/height:) bypass '
      'spacing tokens.';

  @override
  List<Finding> run(String filePath, String source) {
    final findings = <Finding>[];
    if (filePath.contains('test/')) {
      return findings;
    }
    final pattern = RegExp(
      r'(EdgeInsets\.(?:all|symmetric|only|fromLTRB)\([^)]*?\b\d+\b|'
      r'SizedBox\([^)]*\b(?:width|height):\s*\d+\b)',
    );
    final lines = source.split('\n');
    for (var i = 0; i < lines.length; i++) {
      for (final match in pattern.allMatches(lines[i])) {
        findings.add(Finding(
          file: filePath,
          line: i + 1,
          column: match.start + 1,
          rule: id,
          message: 'magic layout number',
          severity: 'info',
        ));
      }
    }
    return findings;
  }
}

class _DeprecatedMaterialImportCheck implements Check {
  const _DeprecatedMaterialImportCheck();

  @override
  String get id => 'no_deprecated_material_import';

  @override
  String get description =>
      'package:flutter/material.dart is deprecated after Flutter 3.47; '
      'use package:material_ui/material_ui.dart.';

  @override
  List<Finding> run(String filePath, String source) {
    final findings = <Finding>[];
    final lines = source.split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].contains("import 'package:flutter/material.dart'")) {
        findings.add(Finding(
          file: filePath,
          line: i + 1,
          column: 1,
          rule: id,
          message: 'deprecated material import → package:material_ui',
          severity: 'warning',
        ));
      }
    }
    return findings;
  }
}
