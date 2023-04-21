import 'package:flutter/material.dart';
import 'controller_ftp.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var exempleSentence = "Cette phrase est une phrase d'exemple.";
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
  final _dropdownLabels = ["Sentiment :", "Emotion :", "Decision :", "Race :", "Height :"];
  final _dropdownValues = [
    ["POSITIVE", "NEUTRAL OR POSITIVE", "NEUTRAL OR NEGATIVE", "NEGATIVE", "NONE"],
    ["JOY", "PLAYFULNESS", "ENTHUSIASM", "PASSIVE", "SARCASM", "ANGER", "NONE"],
    ["ACCEPT", "HESITATE", "DECLINE", "NONE"],
    ["HUMAN", "CAT", "LION", "NONE"],
    ["SMALL", "BIG", "NONE"],
  ];
  Widget _buildDropdown(int index) {
    return Column(children: [
      Row(children: [
        Text(_dropdownLabels[index], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 20)),
        const SizedBox(width: 20),
        Expanded(child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedValues[index],
          onChanged: (value) => setState(() => _selectedValues[index] = value),
          items: _dropdownValues[index].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        ),),
      ]),
      const SizedBox(height: 20),
    ]);
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(color: Colors.blue, padding: const EdgeInsets.all(20.0), child: Text(exempleSentence, style: const TextStyle(color: Colors.white, fontSize: 24))),
        const SizedBox(height: 50),
        ...List.generate(_dropdownValues.length, _buildDropdown),
        const SizedBox(height: 20),
        TextField(controller: _phraseController, decoration: const InputDecoration(labelText: "Une phrase similaire avec les mêmes tags :", border: OutlineInputBorder())),
        const SizedBox(height: 20),
        TextField(controller: _tagsController, decoration: const InputDecoration(labelText: "Tags personnalisés :", border: OutlineInputBorder())),
        const SizedBox(height: 50),
        ElevatedButton(onPressed: _handleSubmit, child: const Text("Envoyer le formulaire", style: TextStyle(color: Colors.white, fontSize: 20))),
      ]),),),),
    );
  }
  void _handleSubmit() async {
    setState(() {
      alternativeSentence = _phraseController.text;
      selectedSentiment = _selectedValues[0] ?? "NULL";
      selectedEmotion = _selectedValues[1] ?? "NULL";
      selectedDecision = _selectedValues[2] ?? "NULL";
      selectedRace = _selectedValues[3] ?? "NULL";
      selectedHeight = _selectedValues[4] ?? "NULL";
      customTags = _tagsController.text.split(',').map((tag) => tag.trim()).toList();
      exempleSentence = alternativeSentence;
    });
    await dataToFTP();
  }
  Future<void> dataToFTP() async {
    if (alternativeSentence.isNotEmpty) {
      FtpController ftpController = FtpController();
      List<dynamic> formData = [alternativeSentence, selectedSentiment, selectedEmotion, selectedDecision, selectedRace, selectedHeight];
      // <- Add custom tags here
      // <- Save the file here
      // <- Send the file to the FTP server here
    }
  }
}