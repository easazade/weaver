#!/usr/bin/env dart

import 'dart:io';

import 'package:args/args.dart';

void main(List<String> arguments) async {
  final bumpCommandParser = ArgParser()
    ..addOption(
      'type',
      abbr: 't',
      allowed: ['major', 'minor', 'patch'],
      help:
          'Version bump type: major, minor, or patch (optional - will prompt if not provided)',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    );

  final showCommandParser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    );

  final publishCommandParser = ArgParser()
    ..addFlag(
      'dry-run',
      abbr: 'd',
      negatable: false,
      help: 'Run in dry-run mode (passes --dry-run to dart pub publish)',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    );

  final tagCommandParser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    );

  final parser = ArgParser()
    ..addCommand('bump', bumpCommandParser)
    ..addCommand('show', showCommandParser)
    ..addCommand('publish', publishCommandParser)
    ..addCommand('tag', tagCommandParser)
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    );

  ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (e) {
    print('Error: ${e.toString()}');
    print('\nUsage: versions.dart <command> [options]');
    print('Commands:');
    print('  bump     Bump version for all packages');
    print('  show     Show versions for all packages');
    print('  publish  Publish packages to pub.dev');
    print('  tag      Tag the last commit with the latest unified version');
    print('\nRun "versions.dart <command> --help" for more information.');
    exit(1);
  }

  if (results['help'] == true) {
    print(parser.usage);
    print('\nCommands:');
    print('  bump     Bump version for all packages');
    print('  show     Show versions for all packages');
    print('  publish  Publish packages to pub.dev');
    print('  tag      Tag the last commit with the latest unified version');
    exit(0);
  }

  final command = results.command;
  if (command == null) {
    print('Usage: versions.dart <command> [options]\n');
    print('Commands:');
    print('  bump     Bump version for all packages');
    print('  show     Show versions for all packages');
    print('  publish  Publish packages to pub.dev');
    print('  tag      Tag the last commit with the latest unified version\n');
    print('Run "versions.dart <command> --help" for more information.');
    exit(1);
  }

  if (command['help'] == true) {
    if (command.name == 'bump') {
      print(bumpCommandParser.usage);
    } else if (command.name == 'show') {
      print(showCommandParser.usage);
    } else if (command.name == 'publish') {
      print(publishCommandParser.usage);
    } else if (command.name == 'tag') {
      print(tagCommandParser.usage);
    }
    exit(0);
  }

  if (command.name == 'bump') {
    String bumpType;
    final providedType = command['type'] as String?;
    if (providedType != null) {
      bumpType = providedType;
    } else {
      bumpType = await promptForBumpType();
    }
    await bumpVersions(bumpType);
  } else if (command.name == 'show') {
    await showVersions();
  } else if (command.name == 'publish') {
    final dryRun = command['dry-run'] == true;
    await publishPackages(dryRun);
  } else if (command.name == 'tag') {
    await tagLatestVersion();
  } else {
    print('Unknown command: ${command.name}');
    print('\nAvailable commands: bump, show, publish, tag');
    exit(1);
  }
}

Future<String> promptForBumpType() async {
  print('Select version bump type:');
  print('  1. major');
  print('  2. minor');
  print('  3. patch');
  print('\nEnter your choice (1-3):');

  final input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) {
    print('No selection made. Exiting.');
    exit(0);
  }

  final choice = input.trim();
  switch (choice) {
    case '1':
      return 'major';
    case '2':
      return 'minor';
    case '3':
      return 'patch';
    default:
      // Try to parse as direct name
      final lowerChoice = choice.toLowerCase();
      if (lowerChoice == 'major' ||
          lowerChoice == 'minor' ||
          lowerChoice == 'patch') {
        return lowerChoice;
      }
      print('Invalid choice: $choice');
      print('Please enter 1, 2, 3, or major, minor, patch');
      exit(1);
  }
}

Future<void> showVersions() async {
  final packages = await getPackages();
  if (packages.isEmpty) {
    print('No packages found in packages directory');
    exit(0);
  }

  final packageVersions = <String, String>{};

  for (final package in packages) {
    final pubspecFile = File('${package.path}/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      print('Warning: ${package.path}/pubspec.yaml not found, skipping');
      continue;
    }

    final content = await pubspecFile.readAsString();
    final version = extractVersion(content);
    if (version != 'unknown') {
      final packageName = package.path.split(Platform.pathSeparator).last;
      packageVersions[packageName] = version;
    }
  }

  if (packageVersions.isEmpty) {
    print('No valid versions found in packages');
    exit(0);
  }

  print('Package versions:');
  packageVersions.forEach((name, version) {
    print('  $name: $version');
  });
}

Future<void> bumpVersions(String bumpType) async {
  final packages = await getPackages();
  if (packages.isEmpty) {
    print('No packages found in packages directory');
    exit(0);
  }

  // First, collect all versions and find the highest one
  print('Collecting current versions...\n');
  final packageVersions = <String, String>{};
  Version? highestVersion;

  for (final package in packages) {
    final pubspecFile = File('${package.path}/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      print('Warning: ${package.path}/pubspec.yaml not found, skipping');
      continue;
    }

    final content = await pubspecFile.readAsString();
    final version = extractVersion(content);
    if (version != 'unknown') {
      final packageName = package.path.split(Platform.pathSeparator).last;
      packageVersions[packageName] = version;

      final versionObj = parseVersion(version);
      if (versionObj != null) {
        if (highestVersion == null ||
            isVersionHigher(versionObj, highestVersion)) {
          highestVersion = versionObj;
        }
      }
    }
  }

  if (highestVersion == null) {
    print('Error: No valid versions found in packages');
    exit(1);
  }

  // Show current versions
  print('Current versions:');
  packageVersions.forEach((name, version) {
    print('  $name: $version');
  });
  print(
      '\nHighest version: ${highestVersion.major}.${highestVersion.minor}.${highestVersion.patch}');

  // Bump the highest version
  final bumpedVersion = bumpVersion(highestVersion, bumpType);
  final newVersionString =
      '${bumpedVersion.major}.${bumpedVersion.minor}.${bumpedVersion.patch}';

  print('Bumping $bumpType version to unified version: $newVersionString\n');

  // Update all packages to the unified version
  final updatedPackages = <Directory>[];
  for (final package in packages) {
    final pubspecFile = File('${package.path}/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      continue;
    }

    final content = await pubspecFile.readAsString();
    final oldVersion = extractVersion(content);
    final updatedContent = setVersion(content, newVersionString);

    if (updatedContent != content) {
      await pubspecFile.writeAsString(updatedContent);
      final packageName = package.path.split(Platform.pathSeparator).last;
      print('✓ $packageName: $oldVersion → $newVersionString');
      updatedPackages.add(package);
    }
  }

  // Update CHANGELOG.md for all updated packages
  if (updatedPackages.isNotEmpty) {
    print('\nUpdating CHANGELOG.md files...');
    for (final package in updatedPackages) {
      await updateChangelog(package, newVersionString);
      final packageName = package.path.split(Platform.pathSeparator).last;
      print('✓ Updated CHANGELOG.md for $packageName');
    }
  }

  print(
      '\nVersion bump completed! All packages now at unified version: $newVersionString');
}

Future<void> tagLatestVersion() async {
  final packages = await getPackages();
  if (packages.isEmpty) {
    print('No packages found in packages directory');
    exit(0);
  }

  // Collect all versions and find the highest one
  print('Collecting current versions...\n');
  Version? highestVersion;

  for (final package in packages) {
    final pubspecFile = File('${package.path}/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      continue;
    }

    final content = await pubspecFile.readAsString();
    final version = extractVersion(content);
    if (version != 'unknown') {
      final versionObj = parseVersion(version);
      if (versionObj != null) {
        if (highestVersion == null ||
            isVersionHigher(versionObj, highestVersion)) {
          highestVersion = versionObj;
        }
      }
    }
  }

  if (highestVersion == null) {
    print('Error: No valid versions found in packages');
    exit(1);
  }

  final versionString =
      '${highestVersion.major}.${highestVersion.minor}.${highestVersion.patch}';
  print('Latest unified version: $versionString\n');

  await createGitTag(versionString);
}

Future<void> createGitTag(String version) async {
  final tagName = 'v$version';
  print('Creating git tag: $tagName...');

  // Check if git is available
  try {
    final gitCheck = await Process.run('git', ['--version']);
    if (gitCheck.exitCode != 0) {
      print('Error: git is not available');
      return;
    }
  } catch (e) {
    print('Error: git is not available: $e');
    return;
  }

  // Check if we're in a git repository
  try {
    final gitDirCheck = await Process.run('git', ['rev-parse', '--git-dir']);
    if (gitDirCheck.exitCode != 0) {
      print('Error: Not in a git repository');
      return;
    }
  } catch (e) {
    print('Error: Not in a git repository: $e');
    return;
  }

  // Check if tag already exists
  try {
    final tagCheck = await Process.run('git', ['tag', '-l', tagName]);
    if (tagCheck.stdout.toString().trim() == tagName) {
      print('Warning: Tag $tagName already exists. Skipping tag creation.');
      return;
    }
  } catch (e) {
    // Continue if check fails
  }

  // Create the tag on the last commit
  try {
    final process = await Process.run('git', ['tag', tagName]);
    if (process.exitCode == 0) {
      print('✓ Successfully created git tag: $tagName');
    } else {
      print('Error: Failed to create git tag (exit code: ${process.exitCode})');
      if (process.stderr != null) {
        print('Error message: ${process.stderr}');
      }
    }
  } catch (e) {
    print('Error: Failed to create git tag: $e');
  }
}

Future<void> updateChangelog(Directory package, String newVersion) async {
  final changelogFile = File('${package.path}/CHANGELOG.md');

  String changelogContent;
  if (await changelogFile.exists()) {
    changelogContent = await changelogFile.readAsString();
  } else {
    changelogContent = '';
  }

  // Create the new changelog entry
  final newEntry = '## $newVersion\n\n@@TODO\n\n';

  // If changelog is empty, just write the new entry
  if (changelogContent.isEmpty) {
    await changelogFile.writeAsString(newEntry);
    return;
  }

  // Otherwise, prepend the new entry to the existing content
  final updatedContent = newEntry + changelogContent;
  await changelogFile.writeAsString(updatedContent);
}

Future<List<Directory>> getPackages() async {
  final packagesDir = Directory('packages');
  if (!await packagesDir.exists()) {
    print('Error: packages directory not found');
    exit(1);
  }

  return await packagesDir
      .list()
      .where((entity) => entity is Directory)
      .cast<Directory>()
      .toList();
}

class Version {
  final int major;
  final int minor;
  final int patch;

  Version(this.major, this.minor, this.patch);
}

Version? parseVersion(String versionString) {
  final versionRegex = RegExp(r'^(\d+)\.(\d+)\.(\d+)');
  final match = versionRegex.firstMatch(versionString);
  if (match == null) return null;

  return Version(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

bool isVersionHigher(Version v1, Version v2) {
  if (v1.major > v2.major) return true;
  if (v1.major < v2.major) return false;
  if (v1.minor > v2.minor) return true;
  if (v1.minor < v2.minor) return false;
  return v1.patch > v2.patch;
}

Version bumpVersion(Version version, String bumpType) {
  switch (bumpType) {
    case 'major':
      return Version(version.major + 1, 0, 0);
    case 'minor':
      return Version(version.major, version.minor + 1, 0);
    case 'patch':
      return Version(version.major, version.minor, version.patch + 1);
    default:
      return version;
  }
}

String setVersion(String pubspecContent, String newVersion) {
  final versionRegex = RegExp(r'^version:\s*(\d+\.\d+\.\d+)', multiLine: true);
  final match = versionRegex.firstMatch(pubspecContent);

  if (match == null) {
    return pubspecContent;
  }

  return pubspecContent.replaceFirst(
    versionRegex,
    'version: $newVersion',
  );
}

String extractVersion(String pubspecContent) {
  final versionRegex = RegExp(r'^version:\s*(\d+\.\d+\.\d+)', multiLine: true);
  final match = versionRegex.firstMatch(pubspecContent);
  return match?.group(1) ?? 'unknown';
}

Future<void> publishPackages(bool dryRun) async {
  // First check: Verify no @@TODO in CHANGELOG files
  print('Checking CHANGELOG files for @@TODO entries...\n');
  final packages = await getPackages();
  final packagesWithTodo = <String>[];

  for (final package in packages) {
    final changelogFile = File('${package.path}/CHANGELOG.md');
    if (await changelogFile.exists()) {
      final content = await changelogFile.readAsString();
      if (content.contains('@@TODO')) {
        final packageName = package.path.split(Platform.pathSeparator).last;
        packagesWithTodo.add(packageName);
      }
    }
  }

  if (packagesWithTodo.isNotEmpty) {
    print('Error: Found @@TODO entries in the following packages:');
    for (final packageName in packagesWithTodo) {
      print('  - $packageName');
    }
    print(
        '\nPlease remove all @@TODO entries from CHANGELOG files before publishing.');
    exit(1);
  }

  print('✓ No @@TODO entries found in CHANGELOG files.\n');

  // Get packages with pubspec.yaml
  final validPackages = <Directory>[];
  for (final package in packages) {
    final pubspecFile = File('${package.path}/pubspec.yaml');
    if (await pubspecFile.exists()) {
      validPackages.add(package);
    }
  }

  if (validPackages.isEmpty) {
    print('No valid packages found to publish');
    exit(0);
  }

  // List packages and ask user to select
  print('Available packages:');
  for (int i = 0; i < validPackages.length; i++) {
    final packageName =
        validPackages[i].path.split(Platform.pathSeparator).last;
    print('  ${i + 1}. $packageName');
  }

  print('\nEnter package numbers to publish (comma-separated, e.g., 1,2,3):');
  final input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) {
    print('No packages selected. Exiting.');
    exit(0);
  }

  // Parse selected package numbers
  final selectedIndices = <int>[];
  final parts = input.split(',');
  for (final part in parts) {
    final trimmed = part.trim();
    final index = int.tryParse(trimmed);
    if (index != null && index >= 1 && index <= validPackages.length) {
      selectedIndices.add(index - 1); // Convert to 0-based index
    } else {
      print('Warning: Invalid package number "$trimmed", skipping.');
    }
  }

  if (selectedIndices.isEmpty) {
    print('No valid packages selected. Exiting.');
    exit(0);
  }

  // Publish selected packages
  final selectedPackages =
      selectedIndices.map((i) => validPackages[i]).toList();
  print('\n${dryRun ? 'Dry-run: ' : ''}Publishing packages...\n');

  for (final package in selectedPackages) {
    final packageName = package.path.split(Platform.pathSeparator).last;
    print('${dryRun ? '[DRY-RUN] ' : ''}Publishing $packageName...');

    final process = await Process.start(
      'dart',
      [
        'pub',
        'publish',
        if (dryRun) '--dry-run',
      ],
      workingDirectory: package.path,
      mode: ProcessStartMode.inheritStdio,
    );

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      print('\nError: Failed to publish $packageName (exit code: $exitCode)');
      exit(exitCode);
    }
    print(
        '✓ ${dryRun ? '[DRY-RUN] ' : ''}Successfully published $packageName\n');
  }

  print('${dryRun ? 'Dry-run ' : ''}Publish completed!');
}
