import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> difficulties = ['EASY', 'NORMAL', 'HARD', 'LEGEND'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('COLLECTION'),
        backgroundColor: Colors.transparent.withAlpha(50),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x665EFCE8), Color(0x66736EFE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: kToolbarHeight + 60),
          itemCount: difficulties.length,
          itemBuilder: (context, index) {
            final difficulty = difficulties[index];
            return ExpansionTile(
              title: Text(
                difficulty,
                style: const TextStyle(color: Colors.white), // テキストも白系に
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 16, // 横間隔
                    runSpacing: 16, // 縦間隔
                    children: List.generate(8, (i) {
                      final imagePath = 'assets/plants/${difficulty.toLowerCase()}_$i.png';
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 64) / 2, // 横2つに割る
                        child: Image.asset(imagePath, height: 160),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
