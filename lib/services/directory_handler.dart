import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Directories {
  String getInstallationDirectory() {
    final directory = File(Platform.resolvedExecutable).parent.path;

    return directory;
  }

  File getServerFilePath() {
    File serverFile =
        File('${getInstallationDirectory()}\\py_serv_env\\server.py');
    return serverFile;
  }

  bool fileExists(String path) {
    File file = File(path);
    return file.existsSync();
  }

  Future<String> getDocumentsDirectoryPath() async {
    Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    return appDocumentsDir.path;
  }

  Future<List<String>> listDirectories() async {
    try {
      // Get a list of directories in the specified path
      String appDocumentsDir = await getDocumentsDirectoryPath();
      List<FileSystemEntity> entities =
          Directory('$appDocumentsDir/uploads').listSync(followLinks: false);

      List<String> jsonNames = [];

      // Extract only the directories from the list
      for (var subDirectory in entities) {
        if (subDirectory is Directory) {
          File messagesFile = File('${subDirectory.path}/messages.json');
          if (messagesFile.existsSync()) {
            String jsonContent = messagesFile.readAsStringSync();

            Map<String, dynamic> jsonData = jsonDecode(jsonContent);
            jsonNames.add(jsonData['name']);
          } else {
            print('messages.json not found in ${subDirectory.path}');
          }
        }
      }

      return jsonNames;
    } catch (e) {
      print('Error: $e');
      return []; // Return an empty list in case of an error
    }
  }

  void openDirectory(String directory) async {
    // Use the appropriate command based on the platform
    String appDocumentsDir = await getDocumentsDirectoryPath();

    if (Platform.isWindows) {
      // Use 'start' command to open Explorer and navigate to the directory
      await Process.run(
        'explorer',
        ['$appDocumentsDir\\uploads\\${directory}_messages'],
      );
    } else if (Platform.isMacOS) {
      // Use 'open' command to open Finder and navigate to the directory
      await Process.run('open', ['$appDocumentsDir/uploads/$directory']);
    } else {
      // Handle error
      print('Could not open file explorer or finder.');
    }
  }

  Future<void> deleteDirectory(String directoryPath) async {
    try {
      String appDocumentsDir = await getDocumentsDirectoryPath();
      // Create a Directory object
      Directory directory =
          Directory("$appDocumentsDir/uploads/${directoryPath}_messages");

      // Check if the directory exists
      if (await directory.exists()) {
        // Delete the directory and its contents recursively
        await directory.delete(recursive: true);
        print('Directory deleted: $directoryPath');
      } else {
        print('Directory does not exist: $directoryPath');
      }
    } catch (e) {
      print('Error deleting directory: $e');
    }
  }
}
