
import 'dart:collection';
import 'dart:io';
import 'package:intl/intl.dart';

import 'JsonUtil.dart';
import 'PhoneUtil.dart';
import 'Tools.dart';

class DateUtil{

  static const String PARAM_FORMAT = "yyyy/MM/dd";
  static const String PARAM_TIME_FORMAT = 'yyyy/MM/dd';
  static const String PARAM_TIME_FORMAT_H = 'yyyy/MM/dd HH';
  static const String PARAM_TIME_FORMAT_H_M_S = 'yyyy/MM/dd HH:mm:ss';
  static const String FORMAT_D_M_H_M_S = 'dd-MM HH:mm:ss';
  static const int onedaylong=1000*60*1440;
  static const int oneminutelong=1000*60;

  static DateTime getinttodate(int dateint){
    return DateTime.fromMillisecondsSinceEpoch(dateint,isUtc: true);
  }

  static Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }
  ///i==0为当天日期，i为未来几天日期 i=1明天日期
  static String getbaseDatastr(String datestr) {
    DateTime rectime=DateTime.parse(datestr);
    String yy=rectime.year.toString();
    String mm=rectime.month.toString();
    String dd=rectime.day.toString();
    return "$yy-$mm-$dd";
  }


  //自然产生日期，没有补0
  static String getDateDatastr(DateTime rectime) {
    String yy=rectime.year.toString();
    String mm=rectime.month.toString();
    String dd=rectime.day.toString();
    return "$yy-$mm-$dd";
  }


  static String getDatetimeDatastr(DateTime rectime) {
    String yy=rectime.year.toString();
    String mm="";
    if(rectime.month<10){
      mm="0${rectime.month}";
    }else{
      mm=rectime.month.toString();
    }
    String dd="";
    if(rectime.day<10){
      dd="0${rectime.day}";
    }else{
      dd=rectime.day.toString();
    }
    return "$yy-$mm-$dd";
  }

  ///i==0为当天日期，i为未来几天日期 i=1明天日期
  static String getfutureDatastr(String datestr,int i) {
    int nowtoday=DateTime.parse(datestr).millisecondsSinceEpoch;//返回当天时间戳
    int lj=i*1440*60*1000;
    int iday=nowtoday+lj;
    DateTime rectime=DateTime.fromMillisecondsSinceEpoch(iday);
    return getDatetimeDatastr(rectime);
  }
  ///i==0为当天日期，i为未来几天日期 i=1明天日期
  static DateTime addday(DateTime date,int i) {
    int nowtoday=date.millisecondsSinceEpoch;//返回当天时间戳
    int lj=i*1440*60*1000;
    int iday=nowtoday+lj;
    return DateTime.fromMillisecondsSinceEpoch(iday);

  }

  ///计算2个日期之间多少天，并返回日期数组
  static List<DateTime>getDateList(DateTime startday,DateTime endday) {
    List<DateTime> arr=[];
    final differenceDays = endday.difference(startday).inDays;
    for(int i=0;i<differenceDays+1;i++){
      DateTime day=getDateTimeday(startday,i);
      arr.add(day);
    }
    return arr;
  }

  ///i==0为当天日期，i为未来几天日期 i=1明天日期
  static String getDatastr(int i) {
    String y=DateTime.now().year.toString();
    int mint=DateTime.now().month;
    String m=DateTime.now().month.toString();
    if(mint<10)m="0$m";
    String d=DateTime.now().day.toString();
    int dint=DateTime.now().day;
    if(dint<10)d="0$d";
    String yyyymmdd="$y-$m-$d";
    int nowtoday=DateTime.parse(yyyymmdd).millisecondsSinceEpoch;//返回当天时间戳
    // print("今天日期:"+yyyymmdd+"开始时间戳:"+nowtoday.toString());
    int lj=i*1440*60*1000;
    int iday=nowtoday+lj;
    DateTime rectime=DateTime.fromMillisecondsSinceEpoch(iday);
    String yy=rectime.year.toString();
    String mm=rectime.month.toString();
    String dd=rectime.day.toString();
    //print("得到日期:"+rectime.toString());
    return "$yy-$mm-$dd";
  }

  ///i==0为当天日期，i为未来几天日期 i=1明天日期
  static DateTime getDateTime(int i) {
    int nowdate=DateTime.now().millisecondsSinceEpoch;
    int lj=i*1440*60*1000;
    int iday=nowdate+lj;
    return DateTime.fromMillisecondsSinceEpoch(iday);
  }

  ///i==0为当天日期，i为未来几天日期 i=1明天日期
  static DateTime getlastDateTime(int i) {
    int nowdate=DateTime.now().millisecondsSinceEpoch;
    int lj=i*1440*60*1000;
    int iday=nowdate-lj;
    return DateTime.fromMillisecondsSinceEpoch(iday);
  }

  ///i==0为当天日期，i为未来几天日期 i=1明天日期
  static DateTime getDateTimeday(DateTime day,int i) {
    int nowdate=day.millisecondsSinceEpoch;
    int lj=i*1440*60*1000;
    int iday=nowdate+lj;
    return DateTime.fromMillisecondsSinceEpoch(iday);
  }


  ///获取当前日期返回DateTime
  static String getNowDateTime() {
    String dstr=DateTime.now().toString();
    List<String> darr=dstr.split(".");
    return darr[0];
  }

  ///获取昨天日期返回DateTime
  static DateTime getYesterday() {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch - 24 * 60 * 60 * 1000);
    return dateTime;
  }

  ///获取当前日期返回DateTime
  static DateTime getNowUtcDateTime() {
    return DateTime.now().toUtc();
  }

  ///获取当前日期，返回指定格式
  static String getNowDateTimeFormat(String outFormat) {
    var format = DateFormat(outFormat);
    DateTime date = DateTime.now();
    format.format(date);
    String formatResult = format.format(date);
    return formatResult;
  }

  ///获取当前日期，返回指定格式
  static String getUtcDateTimeFormat(String outFormat) {
    var format = DateFormat(outFormat);
    DateTime date = DateTime.now().toUtc();
    format.format(date);
    String formatResult = format.format(date);
    return formatResult;
  }

  ///格式化时间戳
  ///timeSamp:毫秒值
  ///format:"yyyy年MM月dd hh:mm:ss"  "yyy?MM?dd  hh?MM?dd" "yyyy:MM:dd"......
  ///结果： 2019?08?04  02?08?02
  static getFormatData(int time,String format) {
    var dataFormat = DateFormat(format);
    var dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    PhoneUtil.applog ("转换后日期：$dateTime");
    String formatResult = dataFormat.format(dateTime);
    return formatResult;
  }

  static String getLocStrtoFormatDataStr(String time) {
    int timeing=JsonUtil.strtoint(time);
    return getLocFormatDataStr(timeing);
  }

  static String getFormatDataStr(int time) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    String dstr=dateTime.toString();
    List<String> darr=dstr.split(".");
    return darr[0];
  }
  static String getLocFormatDataStr(int time) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    String dstr=dateTime.toLocal().toString();
    List<String> darr=dstr.split(".");
    return darr[0];
  }

  ///格式化
  ///timeSamp:毫秒值
  ///format:"yyyy年MM月dd hh:mm:ss"  "yyy?MM?dd  hh?MM?dd" "yyyy:MM:dd"......
  ///结果： 2019?08?04  02?08?02
  static getFormatStrToStr(String date, String intFormat, String outFormat) {
    var formatInt = DateFormat(intFormat);
    var formatOut =  DateFormat(outFormat);
    DateTime dateTime = formatInt.parse(date);
    String formatResult = formatOut.format(dateTime);
    return formatResult;
  }

  ///格式化 国际时区转为本地
  ///timeSamp:毫秒值
  ///format:"yyyy年MM月dd hh:mm:ss"  "yyy?MM?dd  hh?MM?dd" "yyyy:MM:dd"......
  ///结果： 2019?08?04  02?08?02
  static getFormatUtcToLocal(String date, String intFormat, String outFormat) {
    var formatInt =  DateFormat(intFormat);
    var formatOut =  DateFormat(outFormat);
    DateTime dateTime = formatInt.parse(date);
    var timezoneOffset = dateTime.timeZoneOffset.inHours;
    String formatResult =
    formatOut.format(dateTime.add(Duration(hours: timezoneOffset)));
    return formatResult;
  }



  ///格式化时间戳
  ///timeSamp:毫秒值
  ///format:"yyyy年MM月dd hh:mm:ss"  "yyy?MM?dd  hh?MM?dd" "yyyy:MM:dd"......
  ///结果： 2019?08?04  02?08?02
  static getFormatDataString(DateTime date, String outFormat) {
    var format =  DateFormat(outFormat);
    String formatResult = format.format(date);
    return formatResult;
  }

  ///格式化时间戳
  ///timeSamp:毫秒值
  ///format:"yyyy年MM月dd hh:mm:ss"  "yyy?MM?dd  hh?MM?dd" "yyyy:MM:dd"......
  ///结果： 2019?08?04  02?08?02
  static getFormatUtcToLocalStr(DateTime date, String outFormat) {
    var format = DateFormat(outFormat);
    var timezoneOffset = date.timeZoneOffset.inHours;
    String formatResult = format.format(date.add(Duration(hours: timezoneOffset)));
    return formatResult;
  }

  ///1.获取从某一天开始到某一天结束的所有的中间日期，例如输入 startTime:2019:07:31  endTime:2019:08:31  就会返回所有的中间天数。
  ///startTime和endTime格式如下都可以
  ///使用:    List<String> mdata=DateUtils.instance.getTimeBettwenStartTimeAndEnd(startTime:"2019-07-11",endTime:"2019-08-29",format:"yyyy年MM月dd");
  ///结果:[2019年07月11, 2019年07月12, 2019年07月13, 2019年07月14, 2019年07月15, 2019年07月16, 2019年07月17, 2019年07月18, 2019年07月19, 2019年07月20, 2019年07月21, 2019年07月22, 2019年07月23, 2019年07月24, 2019年07月25, 2019年07月26, 2019年07月27, 2019年07月28, 2019年07月29, 2019年07月30, 2019年07月31, 2019年08月01, 2019年08月02, 2019年08月03, 2019年08月04, 2019年08月05, 2019年08月06, 2019年08月07, 2019年08月08, 2019年08月09, 2019年08月10, 2019年08月11, 2019年08月12, 2019年08月13, 2019年08月14, 2019年08月15, 2019年08月16, 2019年08月17, 2019年08月18, 2019年08月19, 2019年08月20, 2019年08月21, 2019年08月22, 2019年08月23, 2019年08月24, 2019年08月25, 2019年08月26, 2019年08月27, 2019年08月28, 2019年08月29]
  static List<String> getTimeBetweenStartTimeAndEnd(
      String startTime, String endTime, String format) {
    List<String> mDataList=[];
    //记录往后每一天的时间搓，用来和最后一天到做对比。这样就能知道什么时候停止了。
    int allTimeEnd = 0;
    //记录当前到个数(相当于天数)
    int currentFlag = 0;
    DateTime startData = DateTime.parse(startTime);
    DateTime endData = DateTime.parse(endTime);
    var mothFormatFlag = DateFormat(format);
    while (endData.millisecondsSinceEpoch > allTimeEnd) {
      allTimeEnd =
          startData.millisecondsSinceEpoch + currentFlag * 24 * 60 * 60 * 1000;
      var dateTime = DateTime.fromMillisecondsSinceEpoch(
          startData.millisecondsSinceEpoch + currentFlag * 24 * 60 * 60 * 1000);
      String nowMoth = mothFormatFlag.format(dateTime);
      mDataList.add("'$nowMoth'");
      currentFlag++;
    }
    return mDataList;
  }

  ///1.获取从某一天开始到某一天结束的所有的中间日期，例如输入 startTime:2019:07:31  endTime:2019:08:31  就会返回所有的中间天数。
  ///startTime和endTime格式如下都可以
  ///使用:    List<String> mdata=DateUtils.instance.getTimeBettwenStartTimeAndEnd(startTime:"2019-07-11",endTime:"2019-08-29",format:"yyyy年MM月dd");
  ///结果:[2019年07月11, 2019年07月12, 2019年07月13, 2019年07月14, 2019年07月15, 2019年07月16, 2019年07月17, 2019年07月18, 2019年07月19, 2019年07月20, 2019年07月21, 2019年07月22, 2019年07月23, 2019年07月24, 2019年07月25, 2019年07月26, 2019年07月27, 2019年07月28, 2019年07月29, 2019年07月30, 2019年07月31, 2019年08月01, 2019年08月02, 2019年08月03, 2019年08月04, 2019年08月05, 2019年08月06, 2019年08月07, 2019年08月08, 2019年08月09, 2019年08月10, 2019年08月11, 2019年08月12, 2019年08月13, 2019年08月14, 2019年08月15, 2019年08月16, 2019年08月17, 2019年08月18, 2019年08月19, 2019年08月20, 2019年08月21, 2019年08月22, 2019年08月23, 2019年08月24, 2019年08月25, 2019年08月26, 2019年08月27, 2019年08月28, 2019年08月29]
  static List<String> getRangeTime(
      DateTime startData, DateTime endData, String format) {
    List<String> mDataList=[];
    //记录往后每一天的时间搓，用来和最后一天到做对比。这样就能知道什么时候停止了。
    int allTimeEnd = 0;
    //记录当前到个数(相当于天数)
    int currentFlag = 0;
    var mothFormatFlag =  DateFormat(format);
    while (endData.millisecondsSinceEpoch > allTimeEnd) {
      allTimeEnd =
          startData.millisecondsSinceEpoch + currentFlag * 24 * 60 * 60 * 1000;
      var dateTime = DateTime.fromMillisecondsSinceEpoch(
          startData.millisecondsSinceEpoch + currentFlag * 24 * 60 * 60 * 1000);
      String nowMoth = mothFormatFlag.format(dateTime);
      mDataList.add("'$nowMoth'");
      currentFlag++;
    }
    return mDataList;
  }

  ///获取两个日期之间间隔天数
  static int getRangeDayNumber(DateTime startData, DateTime endData) {
    return startData.difference(endData).inDays;
  }





  ///获取前n天日期、后n天日期
  ///传入starTime格式 2012-02-27 13:27:00 或者 "2012-02-27等....
  ///dayNumber：从startTime往后面多少天你需要输出
  ///format:获取到的日期格式。"yyyy年MM月dd" "yyyy-MM-dd" "yyyy年" "yyyy年MM月" "yyyy年\nMM月dd"  等等
  ///使用：DateUtils.instance.getOldDate(startTime:"2019-07-11",dayNumber:10,format:"yyyy年MM月dd");
  ///结果:2019年07月21
  static String getOldDateToStr(
      DateTime startData, int dayNumber, String format) {
    //记录往后每一天的时间搓，用来和最后一天到做对比。这样就能知道什么时候停止了。
    var mothFormatFlag = DateFormat(format);
    var dateTime = DateTime.fromMillisecondsSinceEpoch(
        startData.millisecondsSinceEpoch + dayNumber * 24 * 60 * 60 * 1000);
    String nowMoth = mothFormatFlag.format(dateTime);
    return nowMoth;
  }

  ///获取前n天日期、后n天日期
  ///传入starTime格式 2012-02-27 13:27:00 或者 "2012-02-27等....
  ///dayNumber：从startTime往后面多少天你需要输出
  ///format:获取到的日期格式。"yyyy年MM月dd" "yyyy-MM-dd" "yyyy年" "yyyy年MM月" "yyyy年\nMM月dd"  等等
  ///使用：DateUtils.instance.getOldDate(startTime:"2019-07-11",dayNumber:10,format:"yyyy年MM月dd");
  ///结果:2019年07月21
  static DateTime getOldDate(DateTime startTime, int dayNumber) {
    //记录往后每一天的时间搓，用来和最后一天到做对比。这样就能知道什么时候停止了。
    var dateTime =  DateTime.fromMillisecondsSinceEpoch(
        startTime.millisecondsSinceEpoch + dayNumber * 24 * 60 * 60 * 1000);
    return dateTime;
  }

  ///获取某一个月的最后一天。
  ///我们能提供和知道的条件有:(当天的时间,)
  ///timeSamp:时间戳 单位（毫秒）
  ///format:想要的格式  "yyyy年MM月dd hh:mm:ss"  "yyy?MM?dd  hh?MM?dd" "yyyy:MM:dd"
  static DateTime getEndMonthDate(int year, int month) {
    var dataFormat =  DateFormat();
    var dateTime = DateTime.fromMillisecondsSinceEpoch(month);
    var dataNextMonthData =  DateTime(year, month + 1, 1);
    int nextTimeSamp =
        dataNextMonthData.millisecondsSinceEpoch - 24 * 60 * 60 * 1000;
    //取得了下一个月1号码时间戳
    var dateTimeeee = DateTime.fromMillisecondsSinceEpoch(nextTimeSamp);
    String formatResult = dataFormat.format(dateTimeeee);
    return dateTimeeee;
  }


  // 获取星期
  static int getnowWeek() {
    var week = DateTime.now().weekday;
    return week;
  }
  // 获取星期
  static String getWeekinttostr(int i) {
    String w="";
    switch (i.toString()) {
      case '1':
        w = '一';
        break;
      case '2':
        w = '二';
        break;
      case '3':
        w = '三';
        break;
      case '4':
        w = '四';
        break;
      case '5':
        w = '五';
        break;
      case '6':
        w = '六';
        break;
      case '7':
        w = '日';
        break;
    }
    return '周$w';
  }

  // 获取星期
  static String getWeek(DateTime date) {
    var week = date.weekday;
    String w = '';
    switch (week.toString()) {
      case '1':
        w = '一';
        break;
      case '2':
        w = '二';
        break;
      case '3':
        w = '三';
        break;
      case '4':
        w = '四';
        break;
      case '5':
        w = '五';
        break;
      case '6':
        w = '六';
        break;
      case '7':
        w = '日';
        break;
    }
    return '周$w';
  }

  static String getCustomTimeZone() {
    int hour = DateTime.now().timeZoneOffset.inHours;
    if (hour.abs() < 10) {
      if (hour < 0) {
        return "-0${hour.abs()}:00";
      } else {
        return "+0$hour:00";
      }
    } else {
      if (hour < 0) {
        return "$hour:00";
      } else {
        return "+$hour:00";
      }
    }
  }

  static sleepwaittime(int w){
    sleep(Duration(milliseconds: w));
  }
  static getDatalongws(){
    return DateTime.now().microsecondsSinceEpoch;  // 微秒
  }
  static getDatalonghs(){
    num hm=DateTime.now().millisecondsSinceEpoch;  //毫秒
    return hm;  // 毫秒
  }

  //封装时间戳对象
  static String getGMTDataMapstr(){
    // print("toUTC time: 格林威治时间对象"+DateTime.now().toUtc().toString());
    //print("toUTC time: 格林威治时间戳 微妙："+DateTime.now().toUtc().microsecondsSinceEpoch.toString());  // 微秒);
    // print("toUTC time: 格林威治时间戳 毫秒："+DateTime.now().toUtc().millisecondsSinceEpoch.toString());  // 微秒);
    // print("toLocal time: 本地时区时间对象"+DateTime.now().toLocal().toString());
    // print("toLocal time: 本地时区时间戳"+DateTime.now().toLocal().millisecondsSinceEpoch.toString());
    // print("toIso8601 time: 本地时区时间字符串"+DateTime.now().toIso8601String());
    // print("timeZoneOffset time 当前时区值:"+DateTime.now().timeZoneOffset.toString());
    Map map=HashMap();
    //格林威治时间戳  毫秒/微妙
    map.putIfAbsent("UTCdate", () => DateTime.now().toUtc().millisecondsSinceEpoch.toString());
    map.putIfAbsent("UTCdatelong", () => DateTime.now().toUtc().microsecondsSinceEpoch.toString());
    //本地时区值（与格林威治时差）
    map.putIfAbsent("ZoneOff", () => DateTime.now().timeZoneOffset.toString());
    //本地发送时间戳
    map.putIfAbsent("LOCdate", () => DateTime.now().toLocal().millisecondsSinceEpoch.toString());
    return JsonUtil.maptostr(map);  // 毫秒
  }
  //返回格林威治时间戳毫秒
  static int getUTCint(){
    return DateTime.now().toUtc().millisecondsSinceEpoch;
  }

  //返回格林威治时间戳微妙
  static int getUTClong(){
    return DateTime.now().toUtc().microsecondsSinceEpoch;  // 微秒
  }


  //返回格林威治时间戳
  static String getUTCstr(){
    return DateTime.now().toUtc().millisecondsSinceEpoch.toString();
  }

  static getZone(){   //获得本地时区
    return DateTime.now().timeZoneName;
  }

  static String getlastinttoYYYYMMDD(int i){
    //之前几天的日期字符串
    DateTime lastdate=getlastDateTime(i);
    String year=lastdate.year.toString();
    String mon=lastdate.month.toString();
    if(lastdate.month<10){
      mon="0$mon";
    }
    String day=lastdate.day.toString();
    if(lastdate.day<10){
      day="0$day";
    }
    return year+mon+day;
  }
  static String getlastinttoYYMMDDStr(int i){
    //之前几天的日期字符串
    DateTime lastdate=getlastDateTime(i);
    String year=lastdate.year.toString();
    String mon=lastdate.month.toString();
    if(lastdate.month<10){
      mon="0$mon";
    }
    String day=lastdate.day.toString();
    if(lastdate.day<10){
      day="0$day";
    }
    return "$year-$mon-$day";
  }

  static String getYYYYMMDD(){
    String year=DateTime.now().year.toString();
    String mon=DateTime.now().month.toString();
    if(DateTime.now().month<10){
      mon="0$mon";
    }
    String day=DateTime.now().day.toString();
    if(DateTime.now().day<10){
      day="0$day";
    }
    return year+mon+day;
  }

  static String getYYYYMONDAY(){
    String year=DateTime.now().year.toString();
    String mon=DateTime.now().month.toString();
    String day=DateTime.now().day.toString();
    return year+mon+day;
  }
  //返回简约时间，如1-59分钟，1-23小时，1-28天，后续采用标准日期格式
  static String getSimple(date){
    num hm=DateTime.now().millisecondsSinceEpoch;  //毫秒
    num sc=hm-date;
    num jd=sc/1000/60;
    if (jd<1) return "1分钟";  //返回分钟
    if (jd<60) return "${jd.toInt()}分钟";  //返回分钟
    jd=jd/60;
    if (jd<=23) return "${jd.toInt()}小时";  //返回小时
    jd=jd/24;
    if (jd<=28) return "${jd.toInt()}天";  //返回天数
    return getFormatDataStr(date);   //返回标准日期

  }
  //返回简约时间，如1-59分钟，1-23小时，1-28天，后续采用标准日期格式
  static String getUtcSimple(date){
    num hm=DateTime.now().toUtc().millisecondsSinceEpoch;  //毫秒
    num sc=hm-date;
    num jd=sc/1000/60;
    if (jd<1) return ("在线");  //返回分钟
    if (jd<60) return "${jd.toInt()}""分钟";  //返回分钟
    jd=jd/60;
    if (jd<=23) return "${jd.toInt()}""小时";  //返回小时
    jd=jd/24;
    if(jd.toInt()==0) jd=1;
    if(jd>=9) return "9""天";  //返回天数
    if (jd<=28) return "${jd.toInt()}""天";  //返回天数
    return getFormatDataStr(date);   //返回标准日期

  }
  //返回utc时间对象解析，并返回map
  static Map getutcmap(Map map){
    String utcstr=map["UTC"];
    Map tmap=JsonUtil.strtoMap(utcstr);
    return tmap;
  }
  //返回utc时间对象解析，并返回格林威治微妙
  static int getutcdatelong(Map map){
    String utcstr=map["UTC"];
    //PhoneUtil.applog("解析 utc时间对象:"+utcstr);
    Map tmap=JsonUtil.strtoMap(utcstr);
    int d=Tools.strtoint(tmap["UTCdatelong"]);
    return d;
  }
  static int getYear(){
    return DateTime.now().year;
  }
  static int getMon(){
    return DateTime.now().month;
  }
  static int gettoday(){
    return DateTime.now().day;
  }
  //日期开始时间戳
  static int getstartdataint(String datestr){
    DateTime? nowdate= DateTime.tryParse(datestr);
    int nowdateint=-1;
    if(nowdate!=null){
      return nowdate.millisecondsSinceEpoch;
    }
    return nowdateint;
  }

  //获得当期年 index的数组 status=false 之前年份，true 后年份
  static List<Map> getyearWidget(int index) {
    bool status=true;
    if(index<0) {
      status = false;
      index=-index;
    }
    List<Map> yarr=[];
    int nowyear=getYear();
    for (int i=0;i<index;i++) {
      int nextyear=0;
      if(status){
        nextyear=nowyear+1;
      }else{
        nextyear=nowyear-1;
      }
      String str = nextyear.toString();
      Map map=HashMap();
      map.putIfAbsent("str", () => str);
      map.putIfAbsent("value", () => str);
      yarr.add(map);
    }
    return yarr;
  }

  static getmonWidget() {
    List<Map> marr=[];
    for (int i = 1; i < 13; i++) {
      String value = i.toString();
      if (i < 10) {
        value = "0$i";
      }
      Map map=HashMap();
      map.putIfAbsent("str", () => value);
      map.putIfAbsent("value", () => value);
      marr.add(map);
    }
    return marr;
  }

  static getdayWidget() {
    List<Map> marr=[];
    for (int i = 1; i < 32; i++) {
      String value = i.toString();
      if (i < 10) {
        value = "0$i";
      }
      Map map=HashMap();
      map.putIfAbsent("str", () => value);
      map.putIfAbsent("value", () => value);
      marr.add(map);
    }
    return marr;
  }


}

class UTCmapParse{
  int UTCdate=-1;
  int UTCdatelong=-1;
  int ZoneOff=-1;
  int LOCdate=-1;
  Map map;
  UTCmapParse(this.map);
  parse(){
    if(map.containsKey("UTCdate"))UTCdate=Tools.strtoint(map["UTCdate"]);
    if(map.containsKey("UTCdatelong"))UTCdate=Tools.strtoint(map["UTCdatelong"]);
    if(map.containsKey("ZoneOff"))UTCdate=Tools.strtoint(map["ZoneOff"]);
    if(map.containsKey("LOCdate"))UTCdate=Tools.strtoint(map["LOCdate"]);
  }
  parsestr(){
    if(map.containsKey("UTCdate"))Tools.strtoint(UTCdate=map["UTCdate"]);
    if(map.containsKey("UTCdatelong"))Tools.strtoint(UTCdate=map["UTCdatelong"]);
    if(map.containsKey("ZoneOff"))Tools.strtoint(UTCdate=map["ZoneOff"]);
    if(map.containsKey("LOCdate"))Tools.strtoint(UTCdate=map["LOCdate"]);
  }
}

