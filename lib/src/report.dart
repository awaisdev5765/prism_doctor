// Copyright 2026 Awais Rehman. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A finding reported by a check.
class Finding {
  final String file;
  final int line;
  final int column;
  final String rule;
  final String message;
  final String severity; // info | warning | error

  const Finding({
    required this.file,
    required this.line,
    required this.column,
    required this.rule,
    required this.message,
    required this.severity,
  });

  @override
  String toString() => '$severity • $file:$line:$column • $rule • $message';
}

/// A design-system audit rule.
abstract class Check {
  String get id;
  String get description;

  /// Returns findings for [source] from [filePath].
  List<Finding> run(String filePath, String source);
}

/// Scores an audit: 100 minus weighted penalties.
class Report {
  final String root;
  final List<Finding> findings;
  final int filesScanned;

  Report({required this.root, required this.findings, required this.filesScanned});

  int get errorCount =>
      findings.where((f) => f.severity == 'error').length;
  int get warningCount =>
      findings.where((f) => f.severity == 'warning').length;
  int get infoCount => findings.where((f) => f.severity == 'info').length;

  int get score {
    final s = 100 - errorCount * 10 - warningCount * 4 - infoCount * 0.25;
    return s < 0 ? 0 : s.round();
  }

  String get grade {
    final s = score;
    if (s >= 95) return 'A';
    if (s >= 85) return 'B';
    if (s >= 70) return 'C';
    if (s >= 50) return 'D';
    return 'F';
  }

  /// Renders the terminal report.
  String render() {
    final b = StringBuffer();
    b.writeln('prism doctor — design system audit');
    b.writeln('root: $root  |  files scanned: $filesScanned');
    b.writeln();
    if (findings.isEmpty) {
      b.writeln('No findings. Design system looks consistent. 🎉');
    } else {
      final byFile = <String, List<Finding>>{};
      for (final f in findings) {
        byFile.putIfAbsent(f.file, () => []).add(f);
      }
      for (final entry in byFile.entries) {
        b.writeln(entry.key);
        for (final f in entry.value) {
          b.writeln('  ${f.severity.padRight(7)} ${f.line}:${f.column}  '
              '${f.rule}: ${f.message}');
        }
      }
      b.writeln();
    }
    b.writeln('score: $score/100  grade: $grade  '
        '(errors: $errorCount, warnings: $warningCount, info: $infoCount)');
    return b.toString();
  }
}
