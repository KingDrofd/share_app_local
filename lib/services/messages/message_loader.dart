import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../models/json_message.dart';

class MessageLoader {
  late StreamController<List<Message>> _streamController;

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

  List<String> listDirectories() {
    try {
      // Get a list of directories in the specified path
      List<FileSystemEntity> entities =
          Directory("C:/Users/kingd/Documents/uploads/")
              .listSync(followLinks: false);

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
      print('Error listing directories: $e');
      return [];
    }
  }

  Future<List<Message>> readJsonFile(String name) async {
    try {
      // Get the path to the JSON file
      String? filePath =
          "C:/Users/kingd/Documents/uploads/${name}_messages/messages.json";

      // Read the file
      File file = File(filePath);
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
