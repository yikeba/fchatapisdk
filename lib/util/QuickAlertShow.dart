import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'Tools.dart';
import 'UIxml.dart';




class QuickAlertShow {
  static showQRABApay(
      BuildContext context, Widget qr, String title, String text) async {
    return await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      confirmBtnText: '确认',
      cancelBtnText: '取消',
      title: title,
      text: text,
      widget: qr,
      onConfirmBtnTap: () async {
        Navigator.of(context).pop("ok");
        //ABA进行检测是否支付完毕
      },
    );
  }

  static Future<String> showCopyinfo(BuildContext context, String title, String text) async {
    return await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        confirmBtnText: '继续',
        cancelBtnText: '取消',
        title: title,
        widget: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            SizedBox(width: 5,),
            IconButton(onPressed: (){
              Tools.Copytext(context, text);
            }, icon: Icon(Icons.copy_outlined))
        ],),
        onConfirmBtnTap: () async {
          Navigator.of(context).pop("ok");
        },
        onCancelBtnTap: () {
          Navigator.of(context).pop("cancel");
        });
  }

  static showPayWidget(
      BuildContext context, Widget ipwidget, String title, String text) async {
    return await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      confirmBtnText: '确认',
      cancelBtnText: '取消',
      title: title,
      text: text,
      widget: SizedBox(
        width: double.infinity, // 让 ApplePayButton 占满可用空间
        child: ipwidget,
      ),
      onConfirmBtnTap: () async {
        Navigator.of(context).pop("ok");
        // 在这里添加支付结果处理逻辑
      },
    );
  }

  // 弹出支付对话框函数
  static void showPayDialog(BuildContext context,Widget igpay) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10), // 确保对话框不会超出屏幕
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Apple Pay',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                igpay,
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // 取消并关闭对话框
                  },
                  child: const Text('取消'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static showImage(
      BuildContext context, Widget image, String title, String text) async {
    return await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      confirmBtnText: '确认',
      cancelBtnText: '取消',
      title: title,
      text: text,
      widget: image,
      onConfirmBtnTap: () async {
        Navigator.of(context).pop("ok");
        //ABA进行检测是否支付完毕
      },
    );
  }

  static showH5alipay(
      BuildContext context, Widget qr, String title, String text) async {
    return await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      confirmBtnText: '确认',
      cancelBtnText: '取消',
      title: title,
      text: text,
      widget: qr,
      onConfirmBtnTap: () async {
        Navigator.of(context).pop("ok");
      },
    );
  }

  static showQRinfo(
      BuildContext context, Widget qr, String title, String text) async {
    return await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      confirmBtnText: '返回',
      //cancelBtnText: '取消',
      title: title,
      text: text,
      widget: qr,
      onConfirmBtnTap: () async {
        Navigator.of(context).pop("ok");
      },
    );
  }


  static Future<String> showinfo(BuildContext context, String title, String text) async {
    return await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        confirmBtnText: '继续',
        cancelBtnText: '取消',
        title: title,
        text: text,
        onConfirmBtnTap: () async {
          Navigator.of(context).pop("ok");
        },
        onCancelBtnTap: () {
          Navigator.of(context).pop("cancel");
        });
  }


  static Future<bool?> showTimedDialog(BuildContext context, int time) async {
    bool? confirmed;
    // 创建一个 5 秒自动关闭的定时器
    Future.delayed(Duration(seconds: time), () {
      if (confirmed == null) {
        Navigator.of(context).pop(false); // 5秒后自动返回 false（取消）
      }
    });

    confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 点击外部不关闭对话框
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认操作'),
          content: const Text('您是否确定要继续？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(false); // 返回 false 表示取消
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop(true); // 返回 true 表示确定
              },
            ),
          ],
        );
      },
    );

    // 打印结果
    if (confirmed == true) {
      print('用户选择了确定');
    } else {
      print('用户选择了取消或超时');
    }
    return confirmed;
  }



  static showinfook(BuildContext context, String title, String text) async {
    await QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        cancelBtnText: ('继续'),
        title: title,
        text: text,
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        });
  }

  static showetextsave(BuildContext context, String title, String text) async {
    String message = "";
    return await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        barrierDismissible: true,
        confirmBtnText: ('保存'),
        cancelBtnText: ('取消'),
        title: title,
        text: text,
        widget: TextFormField(
          decoration: InputDecoration(
            alignLabelWithHint: true,
            hintText: title,
            prefixIcon: const Icon(
              Icons.text_fields,
            ),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          onChanged: (value) => message = value,
        ),
        onConfirmBtnTap: () async {
          Navigator.of(context).pop(message);
        },
        onCancelBtnTap: () {
          Navigator.pop(context);
        });
  }

  static showemailsave(BuildContext context) async {
    String message = "";
    return await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        barrierDismissible: true,
        confirmBtnText: ('保存'),
        cancelBtnText: ('取消'),
        title: ('电子邮件输入'),
        text: '格式 xxxx@xxx.xxx',
        //leadingImage: 'assets/custom.gif',
        widget: TextFormField(
          decoration: const InputDecoration(
            alignLabelWithHint: true,
            hintText: ('电子邮件'),
            prefixIcon: Icon(
              Icons.email_outlined,
            ),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => message = value,
        ),
        onConfirmBtnTap: () async {
          Navigator.of(context).pop(message);
        },
        onCancelBtnTap: () {
          Navigator.pop(context);
        });
  }

  static showphonesave(BuildContext context) async {
    String message = "";
    return await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        barrierDismissible: true,
        confirmBtnText: ('保存'),
        cancelBtnText: ('取消'),
        title: ('手机号码输入'),
        text: '包括国际区号，案例：008613301235785',
        widget: TextFormField(
          decoration: const InputDecoration(
            alignLabelWithHint: true,
            hintText: ('输入手机号码'),
            prefixIcon: Icon(
              Icons.phone_outlined,
            ),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.phone,
          onChanged: (value) => message = value,
        ),
        onConfirmBtnTap: () async {
          if (message.length < 5) {
            await QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              text: 'Please input something',
            );
            return;
          }
          Navigator.of(context).pop(message);
        },
        onCancelBtnTap: () {
          Navigator.pop(context);
        });
  }



  static inputtext(BuildContext context, String title) async {
    String text="";
    return await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        barrierDismissible: true,
        confirmBtnText: ('发送'),
        cancelBtnText: ('取消'),
        title: title,
        widget: getinputtext(context, callBack: (val){
          text=val;
        }),
        onConfirmBtnTap: () async {
          if(text.isEmpty){
           // UIxml.showToastsstr(("请输入公告内容"), context);
            return ;
          }
          //PhoneUtil.applog("回调公告内容$text");
          Navigator.of(context).pop(text);
        },
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        }
        );
  }

  static Widget getinputtext(BuildContext context,{required callBack}) {
    var inputcon;
    final FocusNode foc0 = FocusNode(); //自动获得金额焦点
    List<TextInputFormatter> finputtype = [];
    var itype = TextInputType.text;
    Color bordercolor = Colors.grey;

    return Container(
      width: UIxml.getWidthproportion(60),
      height: UIxml.getHeightproportion(10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border(
          top: BorderSide(color: bordercolor, width: 1),
          left: BorderSide(color: bordercolor, width: 1),
          bottom: BorderSide(color: bordercolor, width: 1),
          right: BorderSide(color: bordercolor, width: 1),
        ),
      ),
      child: TextField(
          keyboardType: itype,
          inputFormatters: finputtype,
          textAlign: TextAlign.start,
          maxLines: 3,
          focusNode: foc0,
          autofocus: true,
          controller: inputcon,
          decoration: const InputDecoration(
            hintStyle: TextStyle(fontSize: 14, color: Colors.black38),
            hintText: '',
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ), //InputBorder.none,
            contentPadding: EdgeInsets.fromLTRB(3, 0, 1, 1),
          ),
          onChanged: (value){
            callBack(value);
          },
          onSubmitted: (value) {
            FocusScope.of(context).requestFocus(foc0); //切换焦点
          }),
    );
  }


  static rpminputpass(BuildContext context, String title) async {
    String message = "";
    return await QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      barrierDismissible: true,
      confirmBtnText: ('确定'),
      title: title,
      text: ('红包口令'),
      widget: TextFormField(
        decoration: InputDecoration(
          alignLabelWithHint: true,
          hintText: ('输入红包口令'),
          prefixIcon: Image.asset(
            'assets/img/rpm.png',
            width: 10,
            height: 20,
          ),
        ),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        onChanged: (value) => message = value,
      ),
      onConfirmBtnTap: () async {
        Navigator.of(context).pop(message);
      },
    );
  }

  static bool _waitaddstatus = false;

  static waitadd(BuildContext context, String text) {
    _waitaddstatus = true;
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Loading',
      text: text,
    );
  }

  static waitVoice(BuildContext context, Widget widget) {
    _waitaddstatus = true;
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: ('正在录音'),
      widget: widget,
    );
  }

  static waitaddclose(BuildContext context) {
    if (_waitaddstatus) {
      _waitaddstatus = false;
      Navigator.of(context).pop("");
    }
  }
}
