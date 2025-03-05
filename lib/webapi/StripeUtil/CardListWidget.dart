
import 'package:fchatapi/FChatApiSdk.dart';
import 'package:flutter/material.dart';
import '../../util/QuickAlertShow.dart';
import '../PayHtmlObj.dart';
import '../WebUItools.dart';
import 'CardObj.dart';
import 'CardUtil.dart';


class BankCardScreen extends StatefulWidget {
  Widget? order;
  PayHtmlObj? pobj;
  BankCardScreen({super.key,this.order,this.pobj});
  @override
  _BankCardScreenState createState() => _BankCardScreenState();
}

class _BankCardScreenState extends State<BankCardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
       //判断是否设置支付密码

    });
  }

  Future<void> _addBankCard() async {
    await WebUItools.openWebpay(context,null,null);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("银行卡")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: FChatApiSdk.loccard.cardarr.length,
              itemBuilder: (context, index) {
                CardObj card = FChatApiSdk.loccard.cardarr[index];
                return card.paycardwidget(context,onTap: (value) {
                      if(value==null){
                        if(mounted) {
                          setState(() {
                          });
                        }
                      }else {
                        if (!value) {
                          //UIxml.showdiaoagree("支付失败!", context);
                        }else{
                          //ChatPayUtil.isPaystatus = true;
                          Navigator.of(context).pop();
                        }
                      }
                  });
              }),
          ),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(0, 5, 0, 15),
            child: ElevatedButton(
              onPressed: _addBankCard,
              child: const Text("其他银行卡付款"),
            ),
          ),
        ],
      ),
    );
  }
}
