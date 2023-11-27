import 'dart:convert';
import 'dart:io';

import 'package:share_app_local/services/directory_handler.dart';
import 'package:share_app_local/services/server/server_download.dart';

class Server {
  ServerDownload repo = ServerDownload();

  Directories directories = Directories();

  Future<void> checkPythonVersion() async {
    try {
      var result = await Process.run('python', ['--version']);
      print(result.stdout);
    } catch (e) {
      print('Error checking Python version: $e');
    }
  }

  void killPythonScript() {
    Process.killPid(30924);
  }

  Future<void> launchPythonScript() async {
    var result = await Process.start(
        '/Users/regadabdellah/Documents/Github/FlutterProjects/share_app/python_env/server_env/dist/server',
        []);

    result.stdout.transform(utf8.decoder).forEach(print);
  }

  void downloadRepo() async {
    if (directories.getServerFilePath().existsSync()) {
      print('Found server.py at: ${directories.getServerFilePath().path}');
    } else {
      print(
          'No server.py found in the installation directory at: ${directories.getInstallationDirectory()}.');

      await Future.delayed(Duration(seconds: 1));

      print("Cloning...");

      await repo.cloneRepo(
          "kingdrofd", "py_serv_env", directories.getInstallationDirectory());

      print(
          'Repository cloned successfully at: ${directories.getInstallationDirectory()}');
      //  downloadRepository("kingdrofd/py_serv_env", directory);
      //  cloneRepository(
      //     "https://github.com/KingDrofd/py_serv_env.git", directory);
    }
  }
}
