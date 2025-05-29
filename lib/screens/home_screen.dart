import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HOME')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/difficulty-select'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,       // ボタンの背景色
            foregroundColor: Colors.white,      // テキスト色
            shape: BeveledRectangleBorder(      // 角の形状
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 32,
            ),
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('START'),
        ),
      ),
    );
  }
}
