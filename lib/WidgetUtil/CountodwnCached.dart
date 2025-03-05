import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class CountodwnCached extends StatefulWidget {
  final int downtime; //倒计时秒速 最大
  final TextStyle txtstyle;
  final double? width;
  final double? height;
  void Function(String data) callBack;

  CountodwnCached({
    Key? key,
    required this.downtime,
    required this.txtstyle,
    required this.callBack,
    this.width = 100,
    this.height = 30,
  }) : super(key: key);

  @override
  State<CountodwnCached> createState() => _countodwnCached();
}

class _countodwnCached extends State<CountodwnCached>
    with AutomaticKeepAliveClientMixin {
  int htxt = 0; //显示小时
  int mtxt = 0; //显示分钟
  int stxt = 0; //显示秒
  String viewtimestr = "";
  Timer? downtimer;
  int downint = 0;

  @override
  void initState() {
    super.initState();
    updateUI();
  }

  @override
  void dispose() {
    if (downtimer != null) {
      downtimer!.cancel();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CountodwnCached oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void updateUI() {
    downint = widget.downtime;
    DateTime sj = DateTime.fromMillisecondsSinceEpoch(downint);
    htxt = sj.toUtc().hour;
    mtxt = sj.toUtc().minute;
    stxt = sj.toUtc().second;
    initviewtime();
    downtimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      downint = downint - 1000;
      if (downint <= 0) {
        widget.callBack("end");
        downtimer!.cancel();
        downtimer = null;
        viewtimestr = "00:00";
        if (mounted) {
          setState(() {});
        }
        return;
      }
      DateTime sj = DateTime.fromMillisecondsSinceEpoch(downint);
      htxt = sj.toUtc().hour;
      mtxt = sj.toUtc().minute;
      stxt = sj.toUtc().second;
      viewtime();
    });
  }

  initviewtime() {
    String mstr = mtxt.toString();
    String sstr = stxt.toString();
    if (htxt > 0) {
      viewtimestr = "$htxt:";
      if (mtxt < 10) mstr = "0$mtxt";
      viewtimestr = "$viewtimestr$mstr:";
      if (stxt < 10) sstr = "0$stxt";
      viewtimestr = viewtimestr + sstr;
      return;
    }
    if (mtxt > 0) {
      if (mtxt < 10) mstr = "0$mtxt";
      viewtimestr = "$viewtimestr$mstr:";
      if (stxt < 10) sstr = "0$stxt";
      viewtimestr = viewtimestr + sstr;
      return;
    }
    if (stxt > 0) {
      if (stxt < 10) sstr = "0$stxt";
      viewtimestr = viewtimestr + sstr;
    }
  }

  viewtime() {
    viewtimestr = "";
    String mstr = mtxt.toString();
    String sstr = stxt.toString();
    if (htxt > 0) {
      viewtimestr = "$htxt:";
    }
    if (mtxt > 0) {
      if (mtxt < 10) mstr = "0$mtxt";
      viewtimestr = "$viewtimestr$mstr:";
    }
    if (stxt > 0) {
      if (stxt < 10) sstr = "0$stxt";
      viewtimestr = viewtimestr + sstr;
    } else {
      viewtimestr = "${viewtimestr}00";
    }
    if (downint > 3600000) {
      //PhoneUtil.applog("刷新时间:$viewtimestr");
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: widget.width,
      height: widget.height,
      child: Text(
        viewtimestr,
        style: widget.txtstyle,
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

Widget imageDefault(
    {double conwidth = 138,
      double conheight = 178,
      double imgwidth = 80, // 图片的宽度
      double imgheight = 80, // 图片的高度
      String path = "assets/img/free.png",
      BoxFit boxFit = BoxFit.fill}) {
  return SizedBox(
    width: double.maxFinite,
    height: double.maxFinite,
    child: Center(
      child: Image.asset(
        path,
        width: 80.w,
        height: imgheight.w,
        fit: boxFit,
      ),
    ),
  );
}
