import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'JsonUtil.dart';
import 'PhoneUtil.dart';
import 'Tools.dart';



class UIxml {
  //static Color UItitleColor = HexColor("#B0E0E6"); //标题栏统一色彩
  static Color UItitleColor = HexColor("#FFF5EE"); //标题栏统一色彩
  static num systemfontsize = 1.0;
  static int systemSizemode = 0;
  static double devicewidth = 0;
  static double deviceheight = 0;
  static num screenWidth = 400;
  static num screenHeight = 800;
  static num statusBarHeight = 0;
  static num bottomBarHeight = 0;
  static num viewHeight = 0; //有效内容高度
  static num infoHeight = 0; //信息内容高度，减去了导航栏目，标题栏的有效高度
  static num viewTop = 0; //有效内容top位置
  static double applabelheight = 0; //app设定的标题栏和导航蓝高度
  static double pixelratio = 0; //屏幕密度
  static int currentIndex = 0; //导航菜单序号
  static String nowBottomtag = "maindiao"; //当期导航菜单状态
  static Size? souDeviceSize;

  static final StreamController<double> progressdoubleUI = StreamController.broadcast();
  static final StreamController<String> progressUI = StreamController.broadcast();
  static final StreamController<int> newcontactrs = StreamController.broadcast();






  static initContextSize(BuildContext context){
    try {
      if (!context.mounted) return;
    }catch(e){
      return;
    }

    if(Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setPreferredOrientations([ // 强制竖屏
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ]);
    }
    var screen = MediaQuery.of(context).size;
    screenWidth = screen.width; // 屏幕宽(注意是dp, 转换px 需要 screenWidth * pixelRatio)
    screenHeight = screen.height; // 屏幕高(注意是dp
    viewHeight = screenHeight - statusBarHeight - bottomBarHeight;
    if(Platform.isWindows || Platform.isMacOS){
      if(screenWidth>1024)screenWidth = 1024;
      if(screenHeight>768)screenHeight =768;
    }
   // PhoneUtil.applog("重新构建屏幕竖版尺寸 width$screenWidth  height:$screenHeight");
  }
  static initdevicesize(BuildContext context) async {
    MediaQueryData mq = MediaQuery.of(context);
    MediaQueryData? mqsize = MediaQuery.maybeOf(context);
    //if (mqsize != null) {
     // PhoneUtil.applog("设备尺寸DP width mqsize：${mqsize.size.height}");
    //}
    Size size = MediaQueryData.fromWindow(window).size;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
   // PhoneUtil.applog("Context 设备尺寸DP width ：$width  , heidght:$height");
    souDeviceSize=MediaQuery.of(context).size;
    pixelratio = mq.devicePixelRatio; // 屏幕密度
    screenWidth = mq.size.width; // 屏幕宽(注意是dp, 转换px 需要 screenWidth * pixelRatio)
    screenHeight = mq.size.height; // 屏幕高(注意是dp

    statusBarHeight = 20; // 顶部状态栏, 随着刘海屏会增高
    if (MediaQuery.of(context).padding.top > 0) {
      statusBarHeight = MediaQuery.of(context).padding.top;
    }
    if (MediaQuery.of(context).padding.bottom > 0) {
      bottomBarHeight = MediaQuery.of(context).padding.bottom;
    }
    viewHeight = screenHeight - statusBarHeight - bottomBarHeight;
    viewTop = statusBarHeight;
    applabelheight = UIxml.allgetHeightproportion(8);
    infoHeight = viewHeight - (applabelheight * 2);
    setminphone(); //设置小屏幕手机的有效内容误差
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      systemSizemode = 0;
    }
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      systemSizemode = 1;
    }
    if (screenWidth == 0) {
      if (systemSizemode == 0) {
        //screenWidth = 392; // 屏幕宽(注意是dp, 转换px 需要 screenWidth * pixelRatio)
        //screenHeight = 825; // 屏幕高(注意是dp)
        statusBarHeight = 20; // 顶部状态栏, 随着刘海屏会增高
        bottomBarHeight = 20; // 底部功能栏, 类似于iPhone XR 底部安全区域
        pixelratio=2;
      }
      if (systemSizemode == 1) {
        screenWidth = 434; // 屏幕宽(注意是dp, 转换px 需要 screenWidth * pixelRatio)
        screenHeight = 434; // 屏幕高(注意是dp)
        statusBarHeight = 20; // 顶部状态栏, 随着刘海屏会增高
        bottomBarHeight = 20; // 底部功能栏, 类似于iPhone XR 底部安全区域
        pixelratio=2;
      }
    }
    if(Platform.isWindows || Platform.isMacOS){
      screenWidth=1024;
      screenHeight=768;
    }
    devicewidth = screenWidth.toDouble();
    deviceheight = screenHeight.toDouble();
    PhoneUtil.applog("设备尺寸DP width：${size.width} height:${size.height} 屏幕密度:$pixelratio");
    // PhoneUtil.applog("本地保存width:" + screenWidth.toString());
    // PhoneUtil.applog("本地保存hegiht:" + screenHeight.toString());
  }

  static savedevicesize(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);
    screenWidth = mq.size.width; // 屏幕宽(注意是dp, 转换px 需要 screenWidth * pixelRatio)
    screenHeight = mq.size.height; // 屏幕高(注意是dp)
    if (screenWidth == 0 || screenHeight == 0) {
      return;
    }
    Map map = HashMap();
    map.putIfAbsent("width", () => screenWidth.toString());
    map.putIfAbsent("height", () => screenHeight.toString());
    String path = "display.set";
    //FileUtil.writerootmdinfo(path, JsonUtil.maptostr(map));
    initdevicesize(context);
  }



  static setminphone() {
    if (screenHeight > 700) return;
    infoHeight = infoHeight - getHeightproportion(1) - getWidthproportion(1);
  }

  //切记flutter 是dpi单位，不是px
  static getWidthproportion(int t) {
    if (screenWidth == 0) {
      screenWidth = devicewidth;
    }
    if(screenWidth>screenHeight){

    }
    num nt = t / 100;
    num wd = screenWidth;
    num nd = nt * wd;
    return nd;
  }

  static allgetHeightproportion(int t) {
    num nt = t / 100;
    num wd = screenHeight;
    num nd = nt * wd;
    return nd;
  }

  static getHeightproportion(double t) {
    if (viewHeight == 0) {
      screenHeight - statusBarHeight - bottomBarHeight;
    }
    num nt = t / 100;
    num wd = viewHeight;
    num nd = nt * wd;
    // if (nd == 0) PhoneUtil.applog("动态高度:" + nd.toString());
    return nd;
  }



  //弹出选择框
  static Future<String> showimage(BuildContext context) async {
    String rec = "";
    await showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Image.asset(
              "assets/images/openwx1.jpg",
              fit: BoxFit.fill,
            ),
          );
        });
    return rec;
  }


  //弹出选择框
  static Future<String> showdiaoagree(
      String showstr, BuildContext context) async {
    String rec = "";
    PhoneUtil.applog("显示协议内容:" + showstr);
    await showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              showstr,
              maxLines: 50,
              style: TextStyle(
                color: Colors.black,
                fontSize: UIxml.bestFontsize(13),
              ),
            ),
            content: Container(
              width: UIxml.getWidthproportion(70),
              height: UIxml.getHeightproportion(6),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              margin: const EdgeInsets.fromLTRB(2, 0, 0, 0),
              padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
              child: Row(
                children: [
                  TextButton(
                    child: const Text("返回"),
                    onPressed: () {
                      rec = "cancel";
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "同意",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      rec = "ok";
                      Navigator.of(context).pop();
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        });
    return rec;
  }


  //标题栏菜单选择显示内容
  static SelectView(IconData icon, String text, String id) {
    return PopupMenuItem<String>(
        value: id,
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: Tools.generateRandomColor()),
            Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Text(
                text,
                textAlign: TextAlign.left,
              ),
            )
          ],
        ));
  }

 /* //网络图片加载框
  static creatNetworkImageView(String url, int w, int h) {
    print("network img:" + url);
    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0), //弧度
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: UIxml.getWidthproportion(w),
          height: UIxml.getWidthproportion(h),
        ),
      );
    } on Exception {
      return Image.asset(
        "assets/img/free.png",
        width: UIxml.getWidthproportion(w),
        height: UIxml.getWidthproportion(h),
      );
    }
  }*/

 /* //网络图片加载框
  static getNetworkImageView(String url) {
    //print("network img:"+url);
    try {
      return Image(
        image: NetworkImage(url),
      );
    } on Exception {
      return Image.asset(
        "assets/img/free.png",
      );
    }
  }*/


  //资源图片加载框
  static creatImage(String name, int w, int h) {
    String url = 'assets/img/' + name;
    try {
      return Image.asset(
        url,
        width: UIxml.getWidthproportion(w),
        height: UIxml.getWidthproportion(h),
      );
    } on Exception {
      return Image.asset(
        "assets/img/free.png",
        width: UIxml.getWidthproportion(w),
        height: UIxml.getWidthproportion(h),
      );
    }
  }


  static getlabel(String label, Color backcolor, double fontsize) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backcolor,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: bestFontsize(fontsize),
          color: Colors.white,
        ),
      ),
    );
  }

  static getlabelColor(
      String label, Color fontcolor, Color backcolor, double fontsize) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backcolor,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: bestFontsize(fontsize),
          color: fontcolor,
        ),
      ),
    );
  }


  /*static showDEFToastsstr(String str, BuildContext context) {
    Toast tosat = Toast(str, 10000);
    tosat.toast(context);
  }

  static showToastsstr(String str, BuildContext context) {
    if(context.mounted) {
      Toast tosat = Toast(str, 2000);
      tosat.toast(context);
    }
  }
  static showmminToastsstr(String str, BuildContext context) {
    Toast tosat = Toast(str, 1000);
    tosat.toast(context);
  }*/

  static maincreatImagesize(double w, double h) {
    return Image.asset(
      "assets/img/free.png",
      width: w,
      height: h,
    );
  }

  static double getboottomheight() {
    final key = GlobalKey();
    double height = key.currentContext!.size!.height;
    PhoneUtil.applog("获得底部导航栏目高度：" + height.toString());
    return height;
  }

  static viewmsg(String arrleng) {
    //PhoneUtil.applog("更新u，未阅读消息:"+arrleng);
    return Positioned(
      top: -6.0,
      right: -10.0,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: const BoxConstraints(
          minWidth: 12,
          minHeight: 12,
        ),
        child: Text(
          arrleng,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  static mainviewmsg(String arrleng) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(
        minWidth: 12,
        minHeight: 12,
      ),
      child: Text(
        arrleng,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }






  static double getFontsize(double fontsize, BuildContext context) {
    double textScaleFactor = MediaQuery.textScaleFactorOf(context);
    fontsize / textScaleFactor;
    return fontsize;
  }

  static bestFontsize(double fontsize) {
    if(kDebugMode){

    }
    double basepixe = 1.5;
    //double basepixe = 2.0;
    double offest = basepixe - pixelratio;
    if (offest < 0 || offest == 1) return fontsize;
    double n = fontsize * (1 - offest);
    if (n > fontsize) return fontsize;
    return n;
  }

  static topProogres(double status) {
    // 条形进度条
    return LinearProgressIndicator(
      minHeight: UIxml.getWidthproportion(1),
      backgroundColor: Colors.blue,
      value: status,
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
    );
  }

  static webtopProogres(double status) {
    // 条形进度条
    return LinearProgressIndicator(
      backgroundColor: Colors.blue,
      value: status,
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.black54),
    );
  }





  static voiceviewProgress(BuildContext context, double status) {
    double w = UIxml.getWidthproportion(40);
    double w1 = UIxml.getWidthproportion(30);
    String url = 'assets/img/bar1.gif';
    return Container(
        padding: const EdgeInsets.all(5.0),
        width: w,
        height: w,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                url,
                width: w1,
                height: w1,
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: const Text(
                "加载中...",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ));
  }

  static roundProgress(double status, String workid) {
    //显示滚动条
    return CircularProgressIndicator(
      semanticsLabel: workid,
      strokeWidth: 1.0,
      backgroundColor: Colors.grey,
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
      value: status,
      semanticsValue: "加载中",
    );
  }

  //资源图片加载框
  static viewmianImage(String name, int w, int h) {
    String url = 'assets/img/' + name;
    return Container(
      //padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Image.asset(
        url,
        width: UIxml.getWidthproportion(w),
        height: UIxml.getWidthproportion(w),
      ),
    );
  }

  static Widget getlabelviewleft(
      String label, double w, double h, Color backcolor) {
    return Container(
      width: w,
      height: h,
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: bestFontsize(13),
          color: backcolor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget getlabelview(
      String label, double w, double h, Color backcolor) {
    return Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backcolor,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /*static getnetimg(String url, double w) {
    double rad = 20;
    if (url.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(0, 2, 0, 0),
        clipBehavior: Clip.hardEdge,
        width: w,
        height: w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(rad)),
        ),
        child: Image(
            image: NetworkImage(url),
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return const Icon(
                Icons.link,
              );
            }),
      );
    } else {
      return Container(
          margin: const EdgeInsets.fromLTRB(0, 2, 0, 0),
          clipBehavior: Clip.hardEdge,
          width: w,
          height: w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(rad)),
          ),
          child: const Icon(
            Icons.link,
            color: Colors.black38,
          ));
    }
  }*/

  static getlabelviewfont(
      String label, double w, double h, Color backcolor, double fontsize) {
    return Container(
      width: w,
      height: h,
      alignment: Alignment.topLeft,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        label,
        maxLines: 3,
        style: TextStyle(
          fontSize: UIxml.bestFontsize(fontsize),
          color: backcolor,
        ),
      ),
    );
  }
}

class HexsColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexsColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class MyPainter extends CustomPainter {
  //默认的线的背景颜色
  Color lineColor = Colors.black;

  //默认的线的宽度
  late double width = UIxml.getWidthproportion(1);

  //已完成线的颜色
  late Color completeColor = Colors.black45;

  //已完成的百分比
  late double completePercent = 100;

  //已完成的线的宽度
  late double completeWidth = UIxml.getWidthproportion(1);

  // 从哪开始 1从下开始, 2 从上开始 3 从左开始 4 从右开始  默认从下开始
  late double startType = 1;

  //是不是虚线的圈
  late bool isDividerRound = false;

  //中间的实圆 统计线条是不是渐变的圆
  late bool isGradient = false;

  //结束的位置
  late double endAngle = pi * 2;

  //默认的线的背景颜色
  late List<Color> lineColors;

  //实心圆阴影颜色
  // Color shadowColor;
  //渐变圆  深色在下面 还是在左面  默认在下面
  late bool isTransfrom = false;

  MyPainter(
    // this.lineColor,
    //  this.completeColor,
    //  this.completePercent,
    //  this.width,
    // this.completeWidth,
    this.lineColors,
    // this.shadowColor,
    //_init();
  );

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2); //  坐标中心
    double radius = min(size.width / 2, size.height / 2); //  半径

    //是否有第二层圆
    //是不是 虚线圆
    if (isDividerRound) {
      //背景的线
      Paint line = Paint()
        ..color = lineColor
        // ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true
        ..strokeWidth = width;

      double i = 0.00;
      while (i < pi * 2) {
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), i,
            0.04, false, line);
        i = i + 0.08;
      }
    } else {
      //背景的线  实线
      Paint line = Paint()
        ..color = lineColor
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = width;

      canvas.drawCircle(
          //  画圆方法
          center,
          radius,
          line);
    }
      //画上面的圆
    if (completeWidth > 0) {
      double arcAngle = 2 * pi * (completePercent / 100);

      // 从哪开始 1从下开始, 2 从上开始 3 从左开始 4 从右开始  默认从下开始
      double start = pi / 2;
      if (startType == 2) {
        start = -pi / 2;
      } else if (startType == 3) {
        start = pi;
      } else if (startType == 4) {
        start = pi * 2;
      }

      //创建画笔
      Paint paint = Paint()
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = completeWidth;

      ///是渐变圆
      if (isGradient == true) {
        //渐变圆 深色位置偏移量  默认深色在下面
        double transfrom;
        if (isTransfrom == false) {
          //深色在下面
          transfrom = -pi / 2;
        } else {
          //深色在左面
          transfrom = pi * 2;
        }
        paint.shader = SweepGradient(
          startAngle: 0.0,
          endAngle: pi * 2,
          colors: lineColors,
          tileMode: TileMode.clamp,
          transform: GradientRotation(transfrom),
        ).createShader(
          Rect.fromCircle(center: center, radius: radius),
        );

        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start,
            arcAngle, false, paint);
      } else {
        ///是实体圆
        paint.color = completeColor;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          start, //  -pi / 2,从正上方开始  pi / 2,从下方开始
          arcAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

////单项选择对话框
class showdiaosignlinfo {
  String selectrec = "";

  oldshowgetselect(List<String> arr, BuildContext context) {
    List<Widget> infowidget = [];
    double font = UIxml.bestFontsize(14);
    for (String str in arr) {
      Widget wt = InkWell(
        onTap: () {
          selectrec = str;
          Navigator.of(context).pop();
        },
        child: Text(
          str,
          style: TextStyle(fontSize: font),
        ),
      );
      infowidget.add(wt);
      infowidget.add(const Spacer());
    }
    return infowidget;
  }






}



class DarkModeProvider with ChangeNotifier {
  /// 深色模式 0: 关闭 1: 开启 2: 随系统
  int _darkMode = 2;

  int get darkMode => _darkMode;

  void changeappMode(int darkMode) async {
    _darkMode = darkMode;
    notifyListeners();
    //SpUtil.putInt(SpConstant.DARK_MODE, darkMode);
  }
}

class KeyBoardTools {
  //IOS 数字键盘增加完成按钮
  OverlayEntry? _overlayEntry;
  BuildContext context;
  late FocusNode _numberFocusNode;
  Widget? doneWidget;

  KeyBoardTools(this.context, {required this.doneWidget}) {
    _numberFocusNode = FocusNode();
    doneWidget ??= const Text('');
  }

  void initState() {
    _numberFocusNode.addListener(() {
      if (_numberFocusNode.hasFocus) {
        showOverlay();
      } else {
        removeOverlay();
      }
    });
  }

  void dispose() {
    _numberFocusNode.dispose();
  }

  FocusNode get numFocusNode {
    return _numberFocusNode;
  }

  showOverlay() {
    if (_overlayEntry != null) return;
    OverlayState? overlayState = Overlay.of(context);
    if (overlayState == null) return;
    _overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: doneWidget!);
    });
    overlayState.insert(_overlayEntry!);
  }

  removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}

///ios键盘done
class InputDoneView extends StatelessWidget {
  String doneText;
  dynamic doneback;
  InputDoneView(this.doneText, this.doneback, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
          child: CupertinoButton(
            padding: const EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                PhoneUtil.applog("done 点击触发");
                doneback("ok");
             },
            child: Text(doneText,
                style: const TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

const Widget linsdivider = Divider(color: Color(0xFFEEEEEE), thickness: 1);
Widget dividerSmall = Container(
  width: 40,
  decoration: const BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: Color(0xFFA0A0A0),
        width: 1,
      ),
    ),
  ),
);

Widget dividerM = Container(
  width: UIxml.getWidthproportion(80),
  decoration: const BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: Color(0xFFA0A0A0),
        width: 1,
      ),
    ),
  ),
);

Widget dividerL = Container(
  width: UIxml.getWidthproportion(90),
  decoration: const BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: Color(0xFFA0A0A0),
        width: 1,
      ),
    ),
  ),
);


Widget dividerwidth = Container(
  width: UIxml.screenWidth.toDouble(),
  decoration: const BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: Color(0xFFA0A0A0),
        width: 1,
      ),
    ),
  ),
);