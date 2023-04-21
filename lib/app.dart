import 'package:flutter/material.dart';
import 'package:ai_datasets_trainer/page_home.dart';

class AIDatasetsTrainerApp extends StatelessWidget {
  const AIDatasetsTrainerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Dataset Trainer',
      theme: ThemeData(primarySwatch: Colors.blue,),
      home: const HomePage(title: 'IA Dataset Trainer'),
    );
  }
}