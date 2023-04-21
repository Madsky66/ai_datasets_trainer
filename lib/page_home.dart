import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'app_id.dart';
import 'controller_ftp.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSubmitting = false;
  Future<String> randomSentence = Future.value('');
  @override void initState() {
    super.initState();
    randomSentence = _loadRandomSentence();
  }
  late String alternativeSentence;
  late String selectedSentiment;
  late String selectedEmotion;
  late String selectedDecision;
  late String selectedRace;
  late String selectedHeight;
  List<String>? customTags;
  final _phraseController = TextEditingController();
  final _tagsController = TextEditingController();
  final _selectedValues = List<String?>.filled(5, null);
  final _dropdownOptions = [
    {"label": "Sentiment :", "values": ["POSITIVE", "NEUTRAL OR POSITIVE", "NEUTRAL OR NEGATIVE", "NEGATIVE", "NONE"]},
    {"label": "Emotion :", "values": ["JOY", "PLAYFULNESS", "ENTHUSIASM", "PASSIVE", "SARCASM", "ANGER", "NONE"]},
    {"label": "Decision :", "values": ["ACCEPT", "HESITATE", "DECLINE", "NONE"]},
    {"label": "Race :", "values": ["HUMAN", "CAT", "LION", "NONE"]},
    {"label": "Height :", "values": ["SMALL", "BIG", "NONE"]},
  ].map((item) => item.map((key, value) => MapEntry<String, dynamic>(key, value))).toList();
  Future<String> _loadRandomSentence() async {
    FtpController ftpController = FtpController();
    String newRandomSentence = await getRandomSentence(ftpController);
    return newRandomSentence;
  }
  Widget _buildDropdown(int index) {
    return Column(children: [
      Row(children: [
        Text(_dropdownOptions[index]['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 20)),
        const SizedBox(width: 20),
        Expanded(child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedValues[index],
          onChanged: (value) => setState(() => _selectedValues[index] = value),
          items: (_dropdownOptions[index]['values'] as List<String>).map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        ),),
      ]),
      const SizedBox(height: 20),
    ]);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        FutureBuilder<String>(future: randomSentence, builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {return const CircularProgressIndicator();}
            else if (snapshot.hasError) {return Text('Erreur: ${snapshot.error}');}
            else {return Container(color: Colors.blue, padding: const EdgeInsets.all(20.0), child: Text(snapshot.data!, style: const TextStyle(color: Colors.white, fontSize: 24)),);}
          },),
        const SizedBox(height: 50),
        ...List.generate(_dropdownOptions.length, _buildDropdown),
        const SizedBox(height: 20),
        TextField(controller: _phraseController, decoration: const InputDecoration(labelText: "Une phrase similaire avec les mêmes tags :", border: OutlineInputBorder()),),
        const SizedBox(height: 20),
        TextField(controller: _tagsController, decoration: const InputDecoration(labelText: "Tags personnalisés :", border: OutlineInputBorder()),),
        const SizedBox(height: 50),
        ElevatedButton(onPressed: _isSubmitting ? null : _handleSubmit, child: const Text("Envoyer le formulaire", style: TextStyle(color: Colors.white, fontSize: 20)),),
      ],),),),),
    );
  }
  String _getSelectedValue(int index) => _selectedValues[index] ?? "NULL";
  void _handleSubmit() async {
    setState(() {_isSubmitting = true;});
    setState(() {
      alternativeSentence = _phraseController.text;
      selectedSentiment = _getSelectedValue(0);
      selectedEmotion = _getSelectedValue(1);
      selectedDecision = _getSelectedValue(2);
      selectedRace = _getSelectedValue(3);
      selectedHeight = _getSelectedValue(4);
      customTags = _tagsController.text.split(',').map((tag) => tag.trim()).toList();
    });
    await downloadAndUpdateFTPFile(() {setState(() {_isSubmitting = false;});});
    setState(() {randomSentence = _loadRandomSentence();});
  }
  Future<void> downloadAndUpdateFTPFile(Function onCompleted) async {
    if (alternativeSentence.isNotEmpty) {
      FtpController ftpController = FtpController();
      String uniqueId = await AppId().getUniqueId();
      String fileName = 'DATA_$uniqueId.txt';
      Directory tempDir = await getTemporaryDirectory();
      File tempFile = File('${tempDir.path}/$fileName');
      if (await ftpController.checkFileExists(fileName)) {tempFile = await ftpController.downloadFile(tempFile.path, fileName);}
      else {await tempFile.create();}
      List<dynamic> formData = [alternativeSentence, selectedSentiment, selectedEmotion, selectedDecision, selectedRace, selectedHeight, customTags];
      String jsonData = jsonEncode(formData);
      bool isEmpty = await tempFile.length() == 0;
      if (isEmpty) {await tempFile.writeAsString(jsonData, mode: FileMode.append);}
      else {await tempFile.writeAsString('\n$jsonData', mode: FileMode.append);}
      await ftpController.uploadFile(tempFile.path, fileName);
      await tempFile.delete();
      onCompleted();
    }
  }
  Future<String> getRandomSentence(FtpController ftpController) async {
    String fileName = 'SENTENCES.txt';
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/$fileName');
    if (await ftpController.checkFileExists(fileName)) {
      tempFile = await ftpController.downloadFile(tempFile.path, fileName);
      List<String> sentences = await tempFile.readAsLines();
      await tempFile.delete();
      if (sentences.isNotEmpty) {return sentences[Random().nextInt(sentences.length)];}
    }
    return "Pas de phrases disponibles.";
  }
}