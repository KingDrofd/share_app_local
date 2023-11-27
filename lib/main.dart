import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_app_local/components/custom_button.dart';
import 'package:share_app_local/models/json_message.dart';
import 'package:share_app_local/services/message_handler.dart'
    as message_handler;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import 'services/message_loader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Read Json',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MyHomePage(title: "List Dirs"));
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
  List<String> directories = [];

  Future<void> _listDirectories() async {
    try {
      // Get the application documents directory
      Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();

      // List all directories in the documents directory
      List<FileSystemEntity> entities = appDocumentsDirectory.listSync();

      setState(() {
        directories = entities
            .where((entity) => entity is Directory)
            .map((dir) => dir.uri.pathSegments.last)
            .toList();
      });
      print(directories);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getDirectory() async {
    try {
      var appDir = await getApplicationDocumentsDirectory();
      print("Current directory: ${appDir.path}");
    } catch (e) {
      print("Error getting directory: $e");
    }
  }

  String getInstallationDirectory() {
    String directory;

    if (Platform.isMacOS) {
      // On macOS, the installation directory is where the executable is located.
      // This assumes that the Dart executable is in the same directory as the app.
      directory = File(Platform.resolvedExecutable).parent.path;

      // Check if server.py exists in the installation directory.
      File serverFile = File('$directory/server.py');
      if (serverFile.existsSync()) {
        path = 'Found server.py at: ${serverFile.path}';
        Process.run('python3', ['$directory/server.py'])
            .then((ProcessResult result) {
          if (result.exitCode == 0) {
            print('Script executed successfully.');
          } else {
            print('Error executing script:\n${result.stderr}');
          }
        });
      } else {
        print('No server.py found in the installation directory.');
      }
    } else {
      directory = "Unsupported platform";
    }

    return path;
  }

  @override
  void initState() {
    super.initState();
    listMessages = [];
    messageLoader = MessageLoader();
    messageLoader.loadMessages();

    _listDirectories();
  }

  @override
  void dispose() {
    messageLoader.dispose();
    super.dispose();
  }

  bool isLink(String input) {
    // Regular expression to match URLs
    // final RegExp urlRegExp = RegExp(
    //   r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$',
    //   caseSensitive: false,
    //   multiLine: false,
    // );
    if (input == 'link') {
      return true;
    } else {
      return false;
    }
  }

  String path = "filepath";
  int? pythonProcess;
  @override
  Widget build(BuildContext context) {
    message_handler.MessageHandler _message_handler =
        message_handler.MessageHandler(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        path = getInstallationDirectory();
      }),
      body: _buildHomePage(_message_handler),
    );
  }

  Center _buildTest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              launchPythonScript()
                  .then((value) => print("wont reach here"))
                  .whenComplete(() => print("reaches hrere"))
                  .then((value) => printText())
                  .onError((error, stackTrace) => print(error.toString()));
            },
            child: Text('Launch Python Script'),
          ),
          ElevatedButton(
            onPressed: () {
              killPythonScript();
            },
            child: Text('Kill Python Script'),
          ),
        ],
      ),
    );
  }

  Future<void> checkPythonVersion() async {
    try {
      var result = await Process.run('python', ['--version']);
      print(result.stdout);
    } catch (e) {
      print('Error checking Python version: $e');
    }
    try {
      var result = await Process.run(
          '/Users/regadabdellah/Documents/Github/FlutterProjects/share_app/python_env/server_env/dist/server',
          ['--version']);
      print(result.stdout);
    } catch (e) {
      print('Error checking Python version: $e');
    }
  }

  void killPythonScript() {
    Process.killPid(30924);
  }

  void printText() {
    print("text");
  }

  Future<void> launchPythonScript() async {
    var result = await Process.start(
        '/Users/regadabdellah/Documents/Github/FlutterProjects/share_app/python_env/server_env/dist/server',
        []);

    result.stdout.transform(utf8.decoder).forEach(print);
  }

  Scaffold _buildHomePage(message_handler.MessageHandler _message_handler) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var url = Uri.parse(listMessages.last.content);

          launchUrl(url);
        },
        child: Icon(
          Icons.launch,
          size: 25,
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Center(
          child: Text(
            "Desktop Server",
            style: GoogleFonts.roboto(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Center(
        child: StreamBuilder<List<Message>>(
          stream: messageLoader.messageStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              listMessages = snapshot.data ?? [];

              return ListView.builder(
                itemCount: listMessages.length,
                itemBuilder: (context, index) {
                  Color tileColor = index % 2 == 0
                      ? Colors.white
                      : const Color.fromARGB(255, 248, 245, 255);
                  double height = index % 2 == 0 ? 50 : 65;
                  if (index < listMessages.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                                alignment: Alignment.centerLeft,
                                height: 100,
                                decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 235, 226, 255),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        listMessages[index].content,
                                        style: GoogleFonts.roboto(fontSize: 14),
                                      ),
                                      Text(path),
                                    ],
                                  ),
                                )),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              isLink(listMessages[index].type)
                                  ? CustomButton(
                                      child: Icon(
                                        Icons.launch_rounded,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                      onTap: () {
                                        _message_handler.handleLinkMessage(
                                            listMessages[index].content);
                                      },
                                    )
                                  : SizedBox(
                                      width: 50,
                                      height: 50,
                                    ),
                              SizedBox(width: 10),
                              CustomButton(
                                onTap: () {
                                  _message_handler.handleTextMessage(
                                      listMessages[index].content);
                                },
                                child: Icon(
                                  Icons.copy_rounded,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox(); // Placeholder for index out of bounds
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
