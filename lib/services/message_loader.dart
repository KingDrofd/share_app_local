import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/json_message.dart';

class MessageLoader {
  late StreamController<List<Message>> _streamController;

  MessageLoader() {
    _streamController = StreamController<List<Message>>();
  }

  Stream<List<Message>> get messageStream => _streamController.stream;

  Future<void> loadMessages() async {
    try {
      while (true) {
        // Read the data continuously
        List<Message> loadedMessages = await readJsonFile();
        _streamController.add(loadedMessages);
        await Future.delayed(Duration(milliseconds: 5));
      }
    } catch (e) {
      print("error loading messages: $e");
    }
  }

  Future<List<Message>> readJsonFile() async {
    try {
      // Get the path to the JSON file
      String? filePath =
          '/Users/regadabdellah/Documents/uploads/Y2N_messages/messages.json';

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
