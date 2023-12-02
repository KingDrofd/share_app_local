import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_app_local/main.dart';

import 'package:share_app_local/services/directory_handler.dart';
import 'package:share_app_local/services/server/server_download.dart';
import 'package:share_app_local/utils/utilities.dart';

class Server {
  ServerDownload repo = ServerDownload();

  Directories directories = Directories();
  Process? process;
  Future<void> checkPythonVersion() async {
    try {
      var result = await Process.start('python', ['--version']);
    } catch (e) {
      print('Error checking Python version: $e');
    }
  }

  Future<void> killPythonScript(BuildContext context) async {
    await Process.run('powershell', ['-Command', 'Stop-Process -Name server']);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1000),
          content: Text(
            "Server Stopped",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> isProcessNameRunning(String processName) async {
    try {
      // Run the 'ps' command to list all processes and filter by the process name
      ProcessResult result = await Process.run('ps', ['aux']);
      String psOutput = result.stdout as String;

      // Check if the process name appears in the output
      print(psOutput.contains(processName));
      return psOutput.contains(processName);
    } catch (e) {
      // An exception may occur if the 'ps' command fails
      return false;
    }
  }

  Future<void> launchPythonScript(BuildContext context) async {
    var result = await Process.start(
        "${directories.getInstallationDirectory()}\\py_serv_env\\dist\\server.exe",
        []);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1000),
          content: Text(
            "Server Started",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
    process = result;
  }

  Future<void> downloadRepo() async {
    final serverFilePath = directories.getServerFilePath();

    if (directories.fileExists(serverFilePath.path)) {
      print('Found server.py at: ${serverFilePath.path}\\py_serv_env');
    } else {
      print(
          'No server.py found in the installation directory at: ${directories.getInstallationDirectory()}\\py_serv_env.');

      await Future.delayed(const Duration(seconds: 1));

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
        isDownloaded = true;
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
            : MyHomePage(),
      ),
    );
  }
}
