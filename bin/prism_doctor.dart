// Copyright 2026 Awais Rehman. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';

import 'package:prism_doctor/src/auditor.dart';
import 'package:prism_doctor/src/report.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.')
    ..addFlag('json', negatable: false, help: 'Emit findings as JSON.')
    ..addOption('severity',
        allowed: ['info', 'warning', 'error'],
        defaultsTo: 'info',
        help: 'Minimum severity to report.')
    ..addOption('fail-on',
        allowed: ['none', 'info', 'warning', 'error'],
        defaultsTo: 'warning',
        help: 'Exit non-zero when findings at or above this severity exist.');

  ArgResults arg;
  try {
    arg = parser.parse(arguments);
  } on ArgParserException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(parser.usage);
    exitCode = 64;
    return;
  }

  if (arg['help'] as bool || arg.rest.isEmpty) {
    stdout.writeln('Usage: prism_doctor <project-root> [options]');
    stdout.writeln(parser.usage);
    return;
  }

  final root = arg.rest.first;
  final report = Auditor(root: root).audit();

  final minSeverity = arg['severity'] as String;
  final filtered = _filterBySeverity(report, minSeverity);
  final effective = Report(
    root: report.root,
    findings: filtered,
    filesScanned: report.filesScanned,
  );

  if (arg['json'] as bool) {
    stdout.writeln(_toJson(effective));
  } else {
    stdout.writeln(effective.render());
  }

  final failOn = arg['fail-on'] as String;
  final fails =
      _severityCount(effective, failOn) > 0 && failOn != 'none';
  if (fails) {
    exitCode = 1;
  }
}

List<Finding> _filterBySeverity(Report report, String minSeverity) {
  const order = ['info', 'warning', 'error'];
  final min = order.indexOf(minSeverity);
  return report.findings
      .where((f) => order.indexOf(f.severity) >= min)
      .toList();
}

int _severityCount(Report report, String severity) {
  const order = ['info', 'warning', 'error'];
  final min = order.indexOf(severity);
  return report.findings
      .where((f) => order.indexOf(f.severity) >= min)
      .length;
}

String _toJson(Report report) {
  
  final b = StringBuffer('{');
  b.write('"root":"${escapeJson(report.root)}",');
  b.write('"filesScanned":${report.filesScanned},');
  b.write('"score":${report.score},');
  b.write('"grade":"${report.grade}",');
  b.write('"findings":[');
  b.write(report.findings
      .map((f) => '{"file":"${escapeJson(f.file)}","line":${f.line},'
          '"column":${f.column},"rule":"${f.rule}",'
          '"severity":"${f.severity}","message":"${escapeJson(f.message)}"}')
      .join(','));
  b.write(']}');
  return b.toString();
}

String escapeJson(String s) =>
    s.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
