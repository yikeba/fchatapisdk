import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetUtil{

  // 弹出等待框
  static bool showopenstate=true;
  static void showLoadingDialog(BuildContext context) {
    showopenstate=true;
    showDialog(
      barrierDismissible: false, // 禁止点击对话框外部关闭
      context: context,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
  static void closeshow(BuildContext context){
      if(showopenstate) {
        Navigator.of(context).pop(); // 加载完成后关闭对话框
      }

  }
}