import 'package:flutter/material.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    final howToWidgets = locale == 'ja'
        ? [
            _text('ステージをクリアして\n美しい木や花を育てよう！', bold: true, size: 20),
            _image('assets/plants/flower.png', width: 280),
            _text('① 3つ選んで目標の数にしよう！'),
            _image('assets/images/howto.jpg', width: 280),
            _text('② ×や÷は＋や−より先に計算されるよ！\n（3 + 2 × 3 = 3 + 6 = 9）'),
            _text('③ 最初に選んだ記号は無視するよ！\n（-3 + 2 ÷ 2 → 3 + 2 ÷ 2）'),
            _text('④ 正解するとステージが進むよ！'),
            _text('⑤ ヒントボタンを押すと広告を見ることでヒントが表示されるよ。'),
            _image('assets/images/hint.png', width: 120),
            _text('⑥ デイリーモードは毎日新しい問題が出るよ！'),
            _text('⑦ 広告を消すにはホーム画面から「広告削除」ができるよ。'),
            _image('assets/images/NoAD.png', width: 100),
            _textButton(context, 'はじめる'),
          ]
        : [
            _text('Clear stages and grow beautiful trees and flowers!', bold: true, size: 20),
            _image('assets/plants/flower.png', width: 280),
            _text('① Choose 3 items to reach the target number!'),
            _image('assets/images/howto.jpg', width: 280),
            _text('② × and ÷ are calculated before + and -!\n(3 + 2 × 3 = 3 + 6 = 9)'),
            _text('③ The first symbol is ignored!\n(-3 + 2 ÷ 2 → 3 + 2 ÷ 2)'),
            _text('④ Clear the stage by getting the correct answer!'),
            _text('⑤ Tap the hint button to watch an ad and get a hint.'),
            _image('assets/images/hint.png', width: 120),
            _text('⑥ A new daily puzzle is available every day!'),
            _text('⑦ To remove ads, tap "Remove Ads" on the home screen.'),
            _image('assets/images/NoAD.png', width: 100),
            _textButton(context, 'Let\'s Play!'),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(locale == 'ja' ? '遊び方' : 'How to Play'),
        backgroundColor: Colors.transparent.withAlpha(50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x665EFCE8), Color(0x66736EFE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: howToWidgets,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _text(String text, {bool bold = false, double size = 20}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _image(String path, {double width = 200}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Center(
        child: Image.asset(
          path,
          width: width,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _textButton(BuildContext context, String label) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.popUntil(context, ModalRoute.withName('/'));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
        ),
        child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

}
