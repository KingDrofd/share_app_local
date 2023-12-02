import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';

class ServerDownload {
  Future<void> cloneRepo(
      String owner, String repo, String targetDirectory) async {
    final url = 'https://api.github.com/repos/$owner/$repo/zipball';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<int> bytes = response.bodyBytes;
      final String zipPath = '$targetDirectory/$repo.zip';

      await File(zipPath).writeAsBytes(bytes);

      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final String filePath = path.join(targetDirectory, file.name);
        if (file.isFile) {
          await File(filePath).writeAsBytes(file.content);
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }

      final extractedDirName = 'KingDrofd-py_serv_env-3b058dd';
      final extractedDirPath = path.join(targetDirectory, extractedDirName);
      final repoDirPath = path.join(targetDirectory, repo);

      try {
        await Directory(extractedDirPath).rename(repoDirPath);
        print('Directory renamed successfully.');
      } catch (e) {
        print('Error renaming directory: $e');
      }

      await File(zipPath).delete();
    } else {
      print('Failed to clone repository. Status code: ${response.statusCode}');
    }
  }

  // Future<String> getRepositoryZipUrl(String repositoryUrl) async {
  //   final apiUrl =
  //       Uri.parse('https://api.github.com/repos/$repositoryUrl/zipball');
  //   final response = await http.get(apiUrl);

  //   if (response.statusCode == 200) {
  //     final jsonResponse = json.decode(response.body) as List;
  //     final archiveUrl = jsonResponse[0]['archive_url'] as String;
  //     return archiveUrl.replaceAll('{archive_format}{/ref}', 'zipball');
  //   } else {
  //     throw Exception(
  //         'Failed to get repository zip URL. Status code: ${response.statusCode}');
  //   }
  // }

  // Future<void> downloadRepository(
  //     String repositoryUrl, String destinationDirectory) async {
  //   try {
  //     // Get the zip archive URL for the repository
  //     final archiveUrl = await getRepositoryZipUrl(repositoryUrl);

  //     // Download the zip file
  //     final response = await http.get(Uri.parse(archiveUrl));

  //     if (response.statusCode == 200) {
  //       final zipFile = File('$destinationDirectory/repository.zip');
  //       await zipFile.writeAsBytes(response.bodyBytes, flush: true);

  //       print('Repository downloaded successfully.');
  //       // Perform any additional tasks, e.g., unzip the file
  //     } else {
  //       print(
  //           'Error downloading repository. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  // Future<void> cloneRepository(
  //     String repositoryUrl, String destinationDirectory) async {
  //   try {
  //     // Use the "git clone" command to clone the repository
  //     final result = await Process.run('git', ['clone', repositoryUrl],
  //         workingDirectory: destinationDirectory);

  //     // Check the exit code to determine if the command was successful
  //     if (result.exitCode == 0) {
  //       print('Repository cloned successfully at: $destinationDirectory');
  //     } else {
  //       print('Error cloning repository. Exit code: ${result.exitCode}');
  //       print('Error message: ${result.stderr}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }
}
