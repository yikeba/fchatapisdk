import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../util/UIxml.dart';

class AutoWaitWidget{
  static ViewPro? vpro;
  //弹出等待加载框
  static autoProgress(BuildContext context) {
    if (vpro == null) {
      vpro = ViewPro(context);
      // PhoneUtil.applog("初始化 viewprogress");
      vpro!.showprogress();
    } else {
      vpro = ViewPro(context);
      vpro!.showprogress();
      return;
    }
  }

  //弹出等待加载框
  static autoStrProgress(String str, BuildContext context) {
    if (vpro == null) {
      vpro = ViewPro(context);
      vpro!.viewstr = str;
      vpro?.showautoStream();
    }
  }

  //弹出等待加载框
  static automaxProgress(String str, BuildContext context) {
    if (vpro == null) {
      vpro = ViewPro(context);
      vpro!.viewstr = str;
    } else {
      vpro = ViewPro(context);
      vpro!.viewstr = str;
      vpro?.showautoStream();
      return;
    }
    vpro?.showautoStream();
  }
  //关闭等待加载框
  static closeProgress() {
    if (vpro != null) {
      vpro!.closepro();
      vpro = null;
      //PhoneUtil.applog("关闭进度条");
    }
  }

}

class ViewPro {
  final BuildContext _context;

  ViewPro(this._context);
  String viewstr = "wait ...";

  showprogress() {
    double w = UIxml.getWidthproportion(35);
    double w1 = UIxml.getWidthproportion(25);
    if (w == 0) w = 100;
    if (w1 == 0) w1 = 80;
    String url = 'assets/img/bar1.gif';
    showDialog(
        context: _context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: UnconstrainedBox(
                alignment: Alignment.center,
                child: Container(
                  //padding: const EdgeInsets.all(5.0),
                  //margin: EdgeInsets.fromLTRB(0, top, 0, 0),
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
                      InkWell(
                        onTap: closepro,
                        child: Container(
                            alignment: Alignment.topLeft,
                            child: Icon(
                              Icons.clear,
                              size: UIxml.getWidthproportion(4),
                            )),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                          url,
                          width: w1,
                          height: w1,
                          package: "fchatapi",
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          viewstr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: UIxml.bestFontsize(11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  showautoStream() {
    String url = 'assets/img/bar1.gif';
    UIxml.progressUI.stream.listen((event) {
      //PhoneUtil.applog("监听动态显示进度条:$event");
    });
    showDialog(
        context: _context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: UnconstrainedBox(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: closepro,
                      child: Container(
                          alignment: Alignment.topLeft,
                          child: const Icon(
                            Icons.clear,
                            size: 20,
                          )),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        url,
                        width: 50,
                        height: 50,
                        package: "fchatapi",
                      ),
                    ),
                    StreamBuilder(
                        stream: UIxml.progressUI.stream,
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                          } else {
                            viewstr = snapshot.data;
                          }
                          return Text(viewstr);
                        }),
                  ],
                ),
              ),
            ),
          );
        });
  }

  showStream() {
    double w = UIxml.getWidthproportion(35);
    double w1 = UIxml.getWidthproportion(25);
    String url = 'assets/img/bar1.gif';
    UIxml.progressUI.stream.listen((event) {
      //PhoneUtil.applog("监听动态显示进度条:"+event);
    });
    showDialog(
        context: _context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: UnconstrainedBox(
                alignment: Alignment.center,
                child: Container(
                  //padding: const EdgeInsets.all(5.0),
                  //margin: EdgeInsets.fromLTRB(0, top, 0, 0),
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
                      InkWell(
                        onTap: closepro,
                        child: Container(
                            alignment: Alignment.topLeft,
                            child: Icon(
                              Icons.clear,
                              size: UIxml.getWidthproportion(4),
                            )),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                          url,
                          width: w1,
                          height: w1,
                          package: "fchatapi",
                        ),
                      ),
                      StreamBuilder(
                          stream: UIxml.progressUI.stream,
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                            } else {
                              viewstr = snapshot.data;
                            }
                            return Container(
                              alignment: Alignment.center,
                              child: Text(
                                viewstr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }


  closepro() {
    try {
      Navigator.of(_context).pop();
    } catch (e) {
      //PhoneUtil.applog("关闭进度条错误");
    }
  }
}