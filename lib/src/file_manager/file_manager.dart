import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract interface class FileManager {
  bool directoryExists(String directory);

  bool fileExists(String fileDir);

  Future<FileSystemEntity> deleteDirectory(
    String directoryPath, {
    bool recursive = false,
  });

  Future<Directory> createDirectory(
    String directoryPath, {
    bool recursive = false,
  });

  Future<String> getApplicationPath();
}

class FileManagerImpl implements FileManager {
  @override
  Future<Directory> createDirectory(
    String directoryPath, {
    bool recursive = false,
  }) =>
      Directory(directoryPath).create(recursive: recursive);

  @override
  Future<FileSystemEntity> deleteDirectory(
    String directoryPath, {
    bool recursive = false,
  }) =>
      Directory(directoryPath).delete(recursive: true);

  @override
  bool directoryExists(String directoryPath) =>
      Directory(directoryPath).existsSync();

  @override
  bool fileExists(String fileDir) => File(fileDir).existsSync();

  @override
  Future<String> getApplicationPath() async =>
      (await getApplicationDocumentsDirectory()).path;
}
