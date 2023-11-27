import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:share_app_local/components/widgets/copy_open.dart';
import 'package:share_app_local/models/json_message.dart';
import 'package:share_app_local/services/directory_handler.dart';

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

  @override
  void initState() {
    super.initState();
    listMessages = [];
    messageLoader = MessageLoader();

    messageLoader.loadMessages();
  }

  @override
  void dispose() {
    messageLoader.dispose();
    super.dispose();
  }

  int? pythonProcess;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          server.downloadRepo();
        },
      ),
      body: _buildHomePage(),
    );
  }

  Scaffold _buildHomePage() {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var url = Uri.parse(listMessages.last.content);

          launchUrl(url);
        },
        child: const Icon(
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
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              listMessages = snapshot.data ?? [];

              return _buildListView();
            }
          },
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
