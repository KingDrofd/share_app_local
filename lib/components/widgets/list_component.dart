import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_app_local/models/json_message.dart';

class ListComponent extends StatefulWidget {
  const ListComponent({
    super.key,
    required this.listMessages,
    required this.index,
  });

  final List<Message> listMessages;
  final int index;

  @override
  State<ListComponent> createState() => _ListComponentState();
}

class _ListComponentState extends State<ListComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          alignment: Alignment.centerLeft,
          height: 50,
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 183, 170, 170),
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
            ),
            child: Text(
              widget.listMessages[widget.index].content,
              style: GoogleFonts.arimo(fontSize: 17, color: Colors.black),
            ),
          )),
    );
  }
}
