import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('結果')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, '/', (route) => false),
          child: Text('ホームに戻る'),
        ),
      ),
    );
  }
}
