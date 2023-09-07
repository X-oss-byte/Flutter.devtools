// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:html';
import 'dart:io';

import 'package:devtools_tool/model.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as path;

String convertProcessOutputToString(List<List<int>> output, String indent) {
  String result = output.map((codes) => utf8.decode(codes)).join();
  result = result.trim();
  result = result
      .split('\n')
      .where((line) => line.isNotEmpty)
      .map((line) => '$indent$line')
      .join('\n');
  return result;
}

abstract class DartSdkHelper {
  static const commandDebugMessage = 'Consider running this command from your'
      'Dart SDK directory locally to debug.';

  static Future<void> fetchAndCheckoutMaster(
    ProcessManager processManager,
  ) async {
    final dartSdkLocation = localDartSdkLocation();
    await runAll(
      processManager,
      workingDirectory: dartSdkLocation,
      additionalErrorMessage: commandDebugMessage,
      commands: [
        CliCommand('git fetch origin'),
        CliCommand('git rebase-update'),
        CliCommand('git checkout origin/main'),
      ],
    );
  }
}

String localDartSdkLocation() {
  final localDartSdkLocation = Platform.environment['LOCAL_DART_SDK'];
  if (localDartSdkLocation == null) {
    throw Exception('LOCAL_DART_SDK environment variable not set. Please add '
        'the following to your \'.bash_profile\' or \'.bash_rc\' file:\n'
        'export LOCAL_DART_SDK=<absolute/path/to/my/dart/sdk>');
  }
  return localDartSdkLocation;
}

class CliCommand {
  CliCommand._({
    String? command,
    String? exe,
    List<String>? args,
    this.throwOnException = true,
  }) {
    assert((command == null) != ((exe == null) && (args == null)));
    final commandElements = command?.split(' ');
    this.exe = exe ?? commandElements!.first;
    this.args = args ?? commandElements!.sublist(1);
  }

  CliCommand(
    String command, {
    this.throwOnException = true,
  })  : exe = command.split(' ').first,
        args = command.split(' ').sublist(1);

  factory CliCommand.from(
    String exe,
    List<String> args, {
    bool throwOnException = true,
  }) {
    return CliCommand._(
      exe: exe,
      args: args,
      throwOnException: throwOnException,
    );
  }

  late final String exe;
  late final List<String> args;
  final bool throwOnException;
}

Future<void> runProcess(
  ProcessManager processManager,
  CliCommand command, {
  String? workingDirectory,
  String? additionalErrorMessage = '',
}) async {
  final process = await processManager.spawn(
    command.exe,
    command.args,
    workingDirectory: workingDirectory,
  );
  final code = await process.exitCode;
  if (command.throwOnException && code != 0) {
    throw ProcessException(
      command.exe,
      command.args,
      'Failed with exit code: $code. $additionalErrorMessage',
      code,
    );
  }
}

Future<void> runAll(
  ProcessManager processManager, {
  required List<CliCommand> commands,
  String? workingDirectory,
  String? additionalErrorMessage = '',
}) async {
  for (final command in commands) {
    await runProcess(
      processManager,
      command,
      workingDirectory: workingDirectory,
      additionalErrorMessage: additionalErrorMessage,
    );
  }
}

String pathFromRepoRoot(String pathFromRoot) {
  return path.join(DevToolsRepo.getInstance()!.repoPath, pathFromRoot);
}

extension DevtoolsProcess on Process {
  static Future<dynamic> runOrThrow(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) async {
    final result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      stdoutEncoding: stdoutEncoding,
      stderrEncoding: stderrEncoding,
    );

    if (result.exitCode != 0) {
      throw 'FAILED: $executable $arguments\nSTDOUT:\n${result.stdout}\nSTDERR${result.stderr}}';
    }

    return result;
  }
}
