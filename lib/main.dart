import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:share_app_local/components/widgets/copy_open.dart';
import 'package:share_app_local/models/json_message.dart';
import 'package:share_app_local/services/directory_handler.dart';
import 'package:share_app_local/utils/utilities.dart';

import 'package:url_launcher/url_launcher.dart';

import 'components/widgets/list_component.dart';
import 'services/messages/message_loader.dart';

import 'services/server/server_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Read Json',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: "READ JSON"));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Message> listMessages;
  late MessageLoader messageLoader;

  Server server = Server();

  Directories directories = Directories();
  List<String> paths = [];

  String? selectedUser;

  @override
  void initState() {
    super.initState();
    listMessages = [];
    messageLoader = MessageLoader();
    paths = messageLoader.listDirectories();

    selectedUser = messageLoader.listDirectories().first;
    messageLoader.loadMessages("$selectedUser");
  }

  @override
  void dispose() {
    messageLoader.dispose();
    super.dispose();
  }

  int? pythonProcess;
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildHomePage());
  }

  Scaffold _buildHomePage() {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          server.launchPythonScript();
        },
        child: const Icon(
          Icons.launch,
          size: 25,
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 183, 58, 58),
        title: Center(
          child: DropdownButton<String>(
            value: selectedUser,
            elevation: 12,
            iconEnabledColor: Colors.white,
            dropdownColor: const Color.fromARGB(255, 183, 58, 58),
            focusColor: Colors.transparent,
            underline: Container(),
            style: GoogleFonts.arimo(color: Colors.white, fontSize: 20),
            onChanged: (newValue) {
              setState(() {
                // Stop ongoing loading for the previous user
                if (isLoading) {}

                // Start loading for the new user
                selectedUser = newValue;
                messageLoader.loadMessages(selectedUser!);
              });
            },
            items: paths.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: StreamBuilder<List<Message>>(
                stream: messageLoader.messageStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    listMessages = snapshot.data ?? [];

                    return _buildListView();
                  }
                },
              ),
            ),
            // Expanded(
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Container(
            //           decoration: BoxDecoration(
            //             image: DecorationImage(
            //               fit: BoxFit.cover,
            //               image: AssetImage("assets/placeholder.png"),
            //             ),
            //             boxShadow: <BoxShadow>[
            //               BoxShadow(
            //                   offset: Offset(0, 0),
            //                   color: Colors.black.withOpacity(.2),
            //                   blurRadius: 6,
            //                   spreadRadius: 5),
            //             ],
            //             borderRadius: BorderRadius.circular(20),
            //             color: Colors.white,
            //           ),
            //           alignment: Alignment.center,
            //           width: 150,
            //           height: 150,
            //         ),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Container(
            //           decoration: BoxDecoration(
            //             image: DecorationImage(
            //               fit: BoxFit.cover,
            //               image: AssetImage("assets/video_placeholder.jpg"),
            //             ),
            //             boxShadow: <BoxShadow>[
            //               BoxShadow(
            //                   offset: Offset(0, 0),
            //                   color: Colors.black.withOpacity(.2),
            //                   blurRadius: 6,
            //                   spreadRadius: 5),
            //             ],
            //             borderRadius: BorderRadius.circular(20),
            //             color: Colors.white,
            //           ),
            //           alignment: Alignment.center,
            //           width: 150,
            //           height: 150,
            //         ),
            //       ),
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  ListView _buildListView() {
    return ListView.builder(
      itemCount: listMessages.length,
      itemBuilder: (context, index) {
        if (index < listMessages.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ListComponent(
                  listMessages: listMessages,
                  index: index,
                ),
                const SizedBox(
                  width: 10,
                ),
                CopyOpen(
                    messageLoader: messageLoader,
                    index: index,
                    listMessages: listMessages),
              ],
            ),
          );
        } else {
          return const SizedBox(); // Placeholder for index out of bounds
        }
      },
    );
  }
}
