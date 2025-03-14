import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../util/Translate.dart';

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 卡通动画
            Lottie.asset(
              'assets/not404.json', // 需要在 assets 目录放置 JSON 动画
              width: 250,
              height: 250,
              fit: BoxFit.cover,
              package: "fchatapi"
            ),
            const SizedBox(height: 20),

            // 标题
            Text(
              Translate.show("哎呀！你迷路了"),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // 说明文本
            Text(
              Translate.show( "页面找不到了，可能被外星人带走了 🛸"),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 返回首页按钮
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/'); // 返回首页
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.blue,
              ),
              child: const Text("返回首页", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
