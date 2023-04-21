import 'dart:io';
import 'package:ftpconnect/ftpconnect.dart';

class FtpController {
  final String host;
  final String username;
  final String password;
  final String remotePath;
  FtpController({this.host = 'stone.o2switch.net', this.username = 'whrv1384', this.password = 'cRrz-e5Z3-qje!', this.remotePath = '/dataset',});
  Future<FTPConnect> _connect() async {
    FTPConnect ftpConnect = FTPConnect(host, user: username, pass: password);
    await ftpConnect.connect();
    await ftpConnect.changeDirectory(remotePath);
    return ftpConnect;
  }
  Future<File> downloadFile(String localPath, String remoteFileName) async {
    FTPConnect ftpConnect = await _connect();
    File localFile = File(localPath);
    await ftpConnect.downloadFile(remoteFileName, localFile);
    await ftpConnect.disconnect();
    return localFile;
  }
  Future<void> uploadFile(String localPath, String remoteFileName) async {
    FTPConnect ftpConnect = await _connect();
    File localFile = File(localPath);
    bool res = await ftpConnect.uploadFileWithRetry(localFile, pRemoteName: remoteFileName);
    await ftpConnect.disconnect();
  }
  Future<bool> checkFileExists(String fileName) async {
    FTPConnect ftpConnect = await _connect();
    final fileList = await ftpConnect.listDirectoryContent();
    await ftpConnect.disconnect();
    return fileList.any((file) => file.name == fileName);
  }
}