import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Directories {
  String getInstallationDirectory() {
    final directory = File(Platform.resolvedExecutable).parent.path;

    return directory;
  }

  File getServerFilePath() {
    File serverFile = File('$getInstallationDirectory/py_serv_env/server.py');
    return serverFile;
  }
}
