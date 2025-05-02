
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Util/PhoneUtil.dart';
import 'package:fchatapi/util/Translate.dart';

class ExpressTimeline extends StatelessWidget {
  final List<ZtoTrackObj> data;
  final String customerNo;

  const ExpressTimeline({
    super.key,
    required this.data,
    required this.customerNo,
  });

  Widget getExpressid(){
    if(customerNo.isEmpty) {
      return Text(Translate.show('订单号')+'：$customerNo',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }else{
      return SizedBox(width: 1,);
    }
  }
  Widget readtrack(){
    if(data.isEmpty){
      return _initTrackList();
    }
    return _getTrackList();
  }

  Widget _initTrackList(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 时间线圆点 + 竖线
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color:Colors.green ,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text("等待发货")
          ),
        ),
      ],
    );
  }

  Widget _getTrackList(){
    return   ListView.builder(
      itemCount: data.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // 防止嵌套滚动冲突
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final item = data[index];
        final isLast = index == data.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 时间线圆点 + 竖线
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: index == 0 ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // 内容部分
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: item.buildTrackItem()
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部标题栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child:getExpressid(),
        ),
        // 快递轨迹列表
        readtrack(),
      ],
    );
  }
}

class ZtoTrackObj {
  final String status; // 快递当前状态，如“已揽件”、“运输中”
  final String time;   // 时间字符串，如“2025-04-09 12:22:01”
  final String message;
  ZtoTrackObj({required this.status, required this.time, required this.message}){
    PhoneUtil.applog("轨迹消息显示$message");
  }

  factory ZtoTrackObj.fromJson(Map<String, dynamic> json) {
    return ZtoTrackObj(
      status: json['ActionName'] ?? '',
      time: json['Time'] ?? '',
      message:json['Message'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'time': time,
      'message':message,
    };
  }

  Widget buildTrackItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 时间线点 + 连线
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            // 可选：底部线段（由父组件控制是否显示）
          ],
        ),
        const SizedBox(width: 12),
        // 文本部分
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:  Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


}
