import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:share_app_local/components/widgets/copy_open.dart';
import 'package:share_app_local/models/json_message.dart';
import 'package:share_app_local/services/directory_handler.dart';
import 'package:share_app_local/utils/utilities.dart';

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
        home: DownloadProgress());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

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

  Future _initStuff() async {
    listMessages = [];
    messageLoader = MessageLoader();
    paths = await directories.listDirectories();

    if (paths.isNotEmpty) {
      selectedUser = paths.first;
      messageLoader.loadMessages("$selectedUser");
    }
  }

  @override
  void initState() {
    super.initState();
    _initStuff();
  }

  @override
  void dispose() {
    messageLoader.dispose();
    super.dispose();
  }

  bool serverStarted = false;
  int? pythonProcess;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              if (!serverStarted) {
                server.launchPythonScript(context);
                serverStarted = !serverStarted;
              } else if (serverStarted) {
                server.killPythonScript(context);
                serverStarted = !serverStarted;
              }
              server.isProcessNameRunning("server");
            });
          },
          child: Icon(
            serverStarted ? Icons.wifi_off : Icons.wifi,
            size: 25,
          ),
        ),
        appBar: AppBar(
          elevation: 20,
          // shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.only(
          //         bottomLeft: Radius.circular(10),
          //         bottomRight: Radius.circular(10))),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.person,
                  color: Color.fromRGBO(53, 53, 53, 1),
                ),
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
              Text(
                selectedUser ?? "Default User",
                style: GoogleFonts.rubik(),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _initStuff();
                      });
                    },
                    icon: Icon(Icons.refresh,
                        color: Color.fromRGBO(53, 53, 53, 1)),
                  ),
                  IconButton(
                    onPressed: () {
                      directories.openDirectory(selectedUser!);
                    },
                    icon: Icon(
                      Icons.folder,
                      color: Color.fromRGBO(53, 53, 53, 1),
                    ),
                  ),
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
                          child: Text(
                              toggleButtons ? 'Hide buttons' : 'Show buttons'),
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
                        PopupMenuItem<String>(
                          onTap: () {
                            setState(() async {
                              await directories.deleteDirectory(selectedUser!);
                              _initStuff();
                            });
                          },
                          value: 'Delete User',
                          child: Text('Delete Current User'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [],
        ),
        body: _buildHomePage());
  }

  Widget _buildHomePage() {
    return Stack(
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
