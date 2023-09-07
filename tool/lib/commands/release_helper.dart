import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:devtools_tool/utils.dart';
import 'package:path/path.dart' as path;

class ReleaseHelperCommand extends Command {
  ReleaseHelperCommand() {
    argParser.addFlag(
      'use-current-branch',
      negatable: false,
      help:
          'Uses the current branch as the base for the release, instead of a fresh copy of master. For use when developing.',
    );
  }
  @override
  String get description =>
      'Creates a release version of devtools from the master branch, and pushes up a draft PR.';

  @override
  String get name => 'release-helper';

  @override
  FutureOr? run() async {
    final useCurrentBranch = argResults!['use-current-branch']!;
    final currentBranchResult = await DevtoolsProcess.runOrThrow('git', [
      'rev-parse',
      '--abbrev-ref',
      'HEAD',
    ]);
    final initialBranch = currentBranchResult.stdout.toString().trim();
    String? releaseBranch;

    try {
      // Change the CWD to the repo root
      Directory.current = pathFromRepoRoot("");
      print("Finding a remote that points to flutter/devtools.git.");
      final String devtoolsRemotes =
          (await DevtoolsProcess.runOrThrow('git', ['remote', '-v'])).stdout;
      final remoteRegexp = RegExp(
        r'^(?<remote>\S+)\s+(?<path>\S+)\s+\((?<action>\S+)\)',
        multiLine: true,
      );
      final remoteRegexpResults = remoteRegexp.allMatches(devtoolsRemotes);
      final RegExpMatch devtoolsRemoteResult;

      try {
        devtoolsRemoteResult = remoteRegexpResults.firstWhere((element) =>
            RegExp(r'flutter/devtools.git$')
                .hasMatch(element.namedGroup('path')!));
      } on StateError {
        throw "ERROR: Couldn't find a remote that points to flutter/devtools.git. Instead got: \n$devtoolsRemotes";
      }
      final remoteOrigin = devtoolsRemoteResult.namedGroup('remote')!;

      final gitStatusResult =
          await DevtoolsProcess.runOrThrow('git', ['status', '-s']);
      if (gitStatusResult.stdout.isNotEmpty) {
        throw "Error: Make sure your working directory is clean before running the helper";
      }

      releaseBranch =
          '_release_helper_release_${DateTime.now().millisecondsSinceEpoch}';

      if (!useCurrentBranch) {
        print("Preparing the release branch.");
        await DevtoolsProcess.runOrThrow(
            'git', ['fetch', remoteOrigin, 'master']);

        await DevtoolsProcess.runOrThrow('git', [
          'checkout',
          '-b',
          releaseBranch,
          '$remoteOrigin/master',
        ]);
      }

      print("Ensuring ./tool packages are ready.");
      Directory.current = pathFromRepoRoot("tool");
      await DevtoolsProcess.runOrThrow('dart', ['pub', 'get']);

      Directory.current = pathFromRepoRoot("");

      final currentVersionResult =
          await DevtoolsProcess.runOrThrow('devtools_tool', [
        'update-version',
        'current-version',
      ]);

      final originalVersion = currentVersionResult.stdout;

      print("Setting the release version.");
      await DevtoolsProcess.runOrThrow('devtools_tool', [
        'update-version',
        'auto',
        '--type',
        'release',
      ]);

      final getNewVersionResult =
          await DevtoolsProcess.runOrThrow('devtools_tool', [
        'update-version',
        'current-version',
      ]);

      final newVersion = getNewVersionResult.stdout;

      final commitMessage = "Releasing from $originalVersion to $newVersion";

      await DevtoolsProcess.runOrThrow('git', [
        'commit',
        '-a',
        '-m',
        commitMessage,
      ]);

      await DevtoolsProcess.runOrThrow('git', [
        'push',
        '-u',
        remoteOrigin,
        releaseBranch,
      ]);

      print('Creating the PR.');
      final createPRResult = await DevtoolsProcess.runOrThrow('gh', [
        'pr',
        'create',
        '--repo',
        'flutter/devtools',
        '--draft',
        '--title',
        commitMessage,
        '--fill',
      ]);

      final prURL = createPRResult.stdout;

      print("Updating your flutter version to the most recent candidate.");
      await DevtoolsProcess.runOrThrow(
          path
              .join(
                '.',
                'tool',
                'update_flutter_sdk.sh',
              )
              .toString(),
          ['--local']);

      print('Your Draft release PR can be found at: $prURL');
      print('DONE');
      print(
        'Build, run and test this release using: `dart ./tool/build_e2e.dart`',
      );
    } finally {
      // try to bring the caller back to their original branch if we have failed
      await Process.run('git', ['checkout', initialBranch]);

      // Try to clean up the temporary branch we made
      if (releaseBranch != null) {
        await Process.run('git', [
          'branch',
          '-D',
          releaseBranch,
        ]);
      }
    }
  }
}
