import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_app_local/services/directory_handler.dart';

import '../../models/json_message.dart';

class MessageLoader {
  late StreamController<List<Message>> _streamController;
  Directories directories = Directories();

  MessageLoader() {
    _streamController = StreamController<List<Message>>();
  }

  Stream<List<Message>> get messageStream => _streamController.stream;
  bool loadingMessages = false;
  Timer? _timer;

  Future<void> loadMessages(String name) async {
    try {
      // Clear the timer if it already exists
      _timer?.cancel();

      // Schedule a periodic task to load messages
      _timer = Timer.periodic(Duration(milliseconds: 5), (_) async {
        try {
          List<Message> loadedMessages = await readJsonFile(name);
          _streamController.add(loadedMessages);
        } catch (e) {
          print("Error loading messages: $e");
        }
      });
    } catch (e) {
      print("Error scheduling timer: $e");
    }
  }

  // Add a method to stop the periodic loading when necessary
  void stopLoading() {
    _timer?.cancel();
    _streamController.close();
  }

  Future<List<Message>> readJsonFile(String name) async {
    try {
      // Get the path to the JSON file
      String appDocumentsDir = await directories.getDocumentsDirectoryPath();
      String filePath =
          "$appDocumentsDir/uploads/${name}_messages/messages.json";

      // Check if the file exists
      File file = File(filePath);
      if (!file.existsSync()) {
        print('File does not exist at the specified path: $filePath');
        return [];
      }

      // Read the file
      String content = await file.readAsString();

      // Parse the JSON content
      Map<String, dynamic>? jsonData = jsonDecode(content);

      if (jsonData != null && jsonData.containsKey('messages')) {
        List<dynamic> messagesData = jsonData['messages'];
        List<Message> messages =
            messagesData.map((json) => Message.fromJson(json)).toList();

        return messages;
      } else {
        print('Invalid JSON format: Missing or null "messages" field.');
        return [];
      }
    } catch (e) {
      print('Error reading JSON file: $e');
      return [];
    }
  }

  void dispose() {
    _streamController.close();
  }
}
