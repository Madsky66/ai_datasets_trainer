import 'dart:io';
import 'package:ftpconnect/ftpconnect.dart';

class FtpController {
  final String host;
  final String username;
  final String password;
  final String remotePath;
  FtpController({this.host = 'stone.o2switch.net', this.username = 'whrv1384', this.password = 'cRrz-e5Z3-qje!', this.remotePath = '/dataset',});
  Future<File> downloadFile(String localPath) async {
    FTPConnect ftpConnect = FTPConnect(host, user: username, pass: password);
    await ftpConnect.connect();
    await ftpConnect.changeDirectory(remotePath);
    File localFile = File(localPath);
    bool res = await ftpConnect.downloadFileWithRetry('DATA.txt', localFile);
    await ftpConnect.disconnect();
    return localFile;
  }
  Future<void> uploadFile(String localPath) async {
    FTPConnect ftpConnect = FTPConnect(host, user: username, pass: password);
    await ftpConnect.connect();
    await ftpConnect.changeDirectory(remotePath);
    File localFile = File(localPath);
    bool res = await ftpConnect.uploadFileWithRetry(localFile);
    await ftpConnect.disconnect();
  }
}