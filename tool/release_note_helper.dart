#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'lib/release_note_classes.dart';

void main(List<String> args) {
  final runner = CommandRunner(
    'release_note_helper',
    'Helps manage version notes for release.',
  )
    ..addCommand(VerifyCommand())
    ..addCommand(MarkDownCommand())
    ..addCommand(BackfillPullRequestUrlCommand());

  runner.run(args).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
  return;
}

class MarkDownCommand extends Command {
  @override
  final name = 'markdown';
  @override
  final description = 'Prints all versions listed in the `file`, in markdown.';

  MarkDownCommand() {
    argParser.addOption(
      'version',
      abbr: 'v',
      help: 'The released version to print the markdown for.',
    );
    argParser.addOption(
      'file',
      abbr: 'f',
      mandatory: true,
      help: 'The json release file to operate on.',
    );
  }

  @override
  void run() async {
    final filePath = argResults!['file'].toString();
    final version = argResults?['version']?.toString();

    final fileContents = await File(filePath).readAsString();
    Release release = Release.fromJson(jsonDecode(fileContents));

    print(release.toMarkdown());
  }
}

class VerifyCommand extends Command {
  @override
  final name = 'verify';
  @override
  final description =
      'Verifies that the release_notes.json file is still readable with the serializable dart classes.';

  VerifyCommand() {
    argParser.addOption(
      'file',
      abbr: 'f',
      mandatory: true,
      help:
          'The json release file to verify. The file will be decoded and parsed to ensure that it\'s format is still what is expected.',
    );
  }

  @override
  void run() async {
    final filePath = argResults!['file'].toString();
    final url = argResults!['file'].toString();
    print("The filepath $filePath");
    final fileContents = await File(filePath).readAsString();
    // This step will fail if the json is not valid, or can't be unserialized
    Release.fromJson(jsonDecode(fileContents));

    print('Release notes were successfully decoded and serialized');
  }
}

class BackfillPullRequestUrlCommand extends Command {
  @override
  final name = 'pr-url';

  @override
  final description =
      'Verifies that the release_notes.json file is still readable with the serializable dart classes.';

  BackfillPullRequestUrlCommand() {
    argParser.addOption(
      'url',
      abbr: 'u',
      mandatory: true,
      help:
          'Add the url to any note, that does NOT already have an URL assigned to it.',
    );
    argParser.addOption(
      'file',
      abbr: 'f',
      mandatory: true,
      help: 'The json release file to operate on.',
    );
  }

  @override
  void run() async {
    final filePath = argResults!['file'].toString();
    final url = argResults!['url'].toString();
    print("The filepath $filePath");
    final file = File(filePath);
    final fileContents = await file.readAsString();
    // This step will fail if the json is not valid, or can't be unserialized
    final release = Release.fromJson(jsonDecode(fileContents));

    for (var section in release.sections) {
      for (var note in section.notes) {
        note.githubPullRequestUrls ??= [url];
      }
    }
    final encoder = new JsonEncoder.withIndent("     ");
    file.writeAsString(encoder.convert(
      release.toJson(),
    ));
    print("$filePath successfully updated");
  }
}