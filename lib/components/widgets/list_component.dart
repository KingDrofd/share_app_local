import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_app_local/models/json_message.dart';
import 'package:share_app_local/services/messages/message_handler.dart'
    as _messageHandler;
import '../../utils/utilities.dart';

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
  bool isElevated = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _messageHandler.MessageHandler messageHandler =
        _messageHandler.MessageHandler(context);
    return Expanded(
      child: Row(
        children: [
          Container(
            decoration:
                BoxDecoration(shape: BoxShape.circle, boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade300,
                  offset: Offset(4, 4),
                  blurRadius: 5,
                  spreadRadius: 2),
            ]),
            child: SvgPicture.asset(
              isLink(widget.listMessages[widget.index].type)
                  ? "assets/link.svg"
                  : "assets/document.svg",
              // colorFilter: ColorFilter.mode(
              //     Color.fromRGBO(37, 0, 89, 1), BlendMode.srcIn),
              height: 60,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: toggleSelectable
                ? MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onHorizontalDragStart: (details) {
                        isElevated = false;
                      },
                      onVerticalDragStart: (details) {
                        isElevated = false;
                      },
                      onTapDown: (details) {
                        setState(() {
                          isElevated = true;
                        });
                      },
                      onTapUp: (details) async {
                        await Future.delayed(Duration(milliseconds: 100));
                        setState(() {
                          isElevated = false;
                          isLink(widget.listMessages[widget.index].type)
                              ? messageHandler.handleLinkMessage(
                                  widget.listMessages[widget.index].content)
                              : messageHandler.handleTextMessage(
                                  widget.listMessages[widget.index].content);
                        });
                      },
                      child: AnimatedContainer(
                          duration: Duration(milliseconds: 50),
                          alignment: Alignment.centerLeft,
                          height: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(4, 4),
                                    blurRadius: 5,
                                    spreadRadius: -2,
                                    color: Colors.grey[500]!,
                                    inset: isElevated),
                                BoxShadow(
                                    offset: Offset(-4, -4),
                                    blurRadius: 5,
                                    spreadRadius: -2,
                                    color: Colors.grey[100]!,
                                    inset: isElevated),
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                            ),
                            child: Text(
                              widget.listMessages[widget.index].content,
                              style: GoogleFonts.rubik(
                                fontSize: 17,
                                color: Colors.black,
                              ),
                            ),
                          )),
                    ),
                  )
                : AnimatedContainer(
                    duration: Duration(milliseconds: 50),
                    alignment: Alignment.centerLeft,
                    height: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(4, 4),
                              blurRadius: 5,
                              spreadRadius: -2,
                              color: Colors.grey[500]!,
                              inset: isElevated),
                          BoxShadow(
                              offset: Offset(-4, -4),
                              blurRadius: 5,
                              spreadRadius: -2,
                              color: Colors.grey[100]!,
                              inset: isElevated),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                      ),
                      child: SelectableText(
                        widget.listMessages[widget.index].content,
                        style: GoogleFonts.rubik(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
