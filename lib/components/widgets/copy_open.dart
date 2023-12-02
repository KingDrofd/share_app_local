import 'package:flutter/material.dart';
import 'package:share_app_local/components/custom_button.dart';
import 'package:share_app_local/services/messages/message_handler.dart'
    as _messageHandler;

import '../../models/json_message.dart';
import '../../services/messages/message_loader.dart';
import '../../utils/utilities.dart';

class CopyOpen extends StatefulWidget {
  const CopyOpen(
      {super.key,
      required this.messageLoader,
      required this.index,
      required this.listMessages});

  final List<Message> listMessages;
  final MessageLoader messageLoader;
  final int index;

  @override
  State<CopyOpen> createState() => _CopyOpenState();
}

class _CopyOpenState extends State<CopyOpen> {
  @override
  Widget build(BuildContext context) {
    _messageHandler.MessageHandler messageHandler =
        _messageHandler.MessageHandler(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        isLink(widget.listMessages[widget.index].type)
            ? CustomButton(
                child: Icon(
                  Icons.launch_rounded,
                  color: Color.fromARGB(255, 37, 0, 89),
                  size: 25,
                ),
                onTap: () {
                  messageHandler.handleLinkMessage(
                      widget.listMessages[widget.index].content);
                },
              )
            : Container(),
        SizedBox(width: 10),
        CustomButton(
          onTap: () {
            messageHandler
                .handleTextMessage(widget.listMessages[widget.index].content);
          },
          child: Icon(
            Icons.copy_rounded,
            color: Color.fromARGB(255, 37, 0, 89),
            size: 25,
          ),
        ),
      ],
    );
  }
}
