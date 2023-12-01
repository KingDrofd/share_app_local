import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: false,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     FloatingActionButton(
      //       onPressed: () {
      //         //server.launchPythonScript();

      //         setState(() {
      //           toggleButtons = !toggleButtons;
      //         });
      //       },
      //       child: Icon(
      //         toggleButtons ? Icons.toggle_on : Icons.toggle_off,
      //         size: 25,
      //       ),
      //     ),
      //     Gap(10),
      //     FloatingActionButton(
      //       onPressed: () {
      //         //server.launchPythonScript();

      //         setState(() {
      //           toggleSelectable = !toggleSelectable;
      //         });
      //       },
      //       child: const Icon(
      //         Icons.launch,
      //         size: 25,
      //       ),
      //     ),
      //   ],
      // ),
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10))),
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PopupMenuButton<String>(
              icon: Icon(Icons.person),
              itemBuilder: (BuildContext context) {
                return paths.map((String value) {
                  return PopupMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList();
              },
              onSelected: (String value) {
                setState(() {
                  // Stop ongoing loading for the previous user
                  if (isLoading) {}

                  // Start loading for the new user
                  selectedUser = value;
                  messageLoader.loadMessages(selectedUser!);
                });
              },
            ),
            Text(selectedUser!),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.delete),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  onTap: () {
                    setState(() {
                      toggleButtons = !toggleButtons;
                    });
                  },
                  value: 'Toggle right buttons',
                  child: Text(toggleButtons ? 'Hide buttons' : 'Show buttons'),
                ),
                PopupMenuItem<String>(
                  onTap: () {
                    setState(() {
                      toggleSelectable = !toggleSelectable;
                    });
                  },
                  value: 'Togggle Button list',
                  child: Text(toggleSelectable
                      ? 'Turn off button list'
                      : 'Turn on button list'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
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
        ],
      ),
    );
  }

  ListView _buildListView() {
    return ListView.builder(
      itemCount: listMessages.length,
      itemBuilder: (context, index) {
        if (index < listMessages.length) {
          return Padding(
            padding:
                const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListComponent(
                      listMessages: listMessages,
                      index: index,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (toggleButtons)
                      CopyOpen(
                          messageLoader: messageLoader,
                          index: index,
                          listMessages: listMessages),
                  ],
                ),
                // Divider(
                //   height: 2,
                //   indent: 2,
                // )
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
