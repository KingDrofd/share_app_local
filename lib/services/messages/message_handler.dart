import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageHandler {
  final BuildContext context;

  MessageHandler(this.context);

  Future<void> handleLinkMessage(String content) async {
    await _launchUrl(content);
  }

  Future<void> handleTextMessage(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 500),
          content: Text(
            "Copied to clipboard",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  Future<void> _launchUrl(String link) async {
    var url = Uri.parse(link);

    launchUrl(url);
  }
}
