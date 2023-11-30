import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:share_app_local/services/directory_handler.dart';
import 'package:share_app_local/services/server/server_download.dart';
import 'package:share_app_local/utils/utilities.dart';

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
    var result = await Process.run("python", [
      "C:/Users/kingd/Documents/GitHub/shareIt/share_app_local/build/windows/x64/runner/Debug/py_serv_env/server.py"
    ]);

    result.stdout.transform(utf8.decoder).forEach(print);
  }

  Future<void> downloadRepo() async {
    final serverFilePath = directories.getServerFilePath();

    if (directories.fileExists(serverFilePath.path)) {
      print('Found server.py at: ${serverFilePath.path}\\py_serv_env');
    } else {
      print(
          'No server.py found in the installation directory at: ${directories.getInstallationDirectory()}\\py_serv_env.');

      await Future.delayed(Duration(seconds: 1));

      print("Cloning...");

      try {
        await repo.cloneRepo(
            "kingdrofd", "py_serv_env", directories.getInstallationDirectory());
        if (directories.fileExists(serverFilePath.path)) {
          print('Found server.py at: ${serverFilePath.path}\\py_serv_env');
        }
      } catch (e) {
        print('Error during cloning: $e');
      } finally {}
    }
  }
}

class DownloadProgress extends StatefulWidget {
  const DownloadProgress({super.key});

  @override
  State<DownloadProgress> createState() => _DownloadProgressState();
}

class _DownloadProgressState extends State<DownloadProgress> {
  bool _downloading = false;
  Directories directories = Directories();
  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
    });

    try {
      final serverDownload = Server();
      await serverDownload.downloadRepo();
    } catch (error) {
      print('Error during download: $error');
      // Handle error as needed
    } finally {
      setState(() {
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _downloading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("Downloading necessary files")
                ],
              )
            : Text('Download Complete'),
      ),
    );
  }
}
