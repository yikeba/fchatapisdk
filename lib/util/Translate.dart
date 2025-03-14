
import 'package:country_currency_pickers/countries.dart';
import 'package:country_currency_pickers/country.dart';
import 'package:country_currency_pickers/utils/typedefs.dart';
import 'package:fchatapi/webapi/StripeUtil/CookieStorage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:language_picker/language_picker_dropdown.dart';
import 'package:language_picker/languages.dart';
import 'package:translator/translator.dart';
import 'JsonUtil.dart';
import 'PhoneUtil.dart';
import 'SignUtil.dart';

class Translate {
  static String language = "cn";
  static String ios2lang="zh";
  static List translateList = []; //服务器读取的翻译内容
  static String countrystr="";  //国家名称
  static Country? nowcountry;
  static Language? nowlanguage;
  static final translator = GoogleTranslator();


  static initTra() {
    //初始化语言环境
    language = WidgetsBinding.instance.window.locale.languageCode;
    PhoneUtil.applog("读取当期语言设置$language");
    String? nc=WidgetsBinding.instance.window.locale.countryCode;
    if(nc!=null) {
      nowcountry = getCounty(nc);
      countrystr = nowcountry!.name!;
    }
    gettranslatesupport();
    try {
      reaeloctra(); //读取本地翻译数据
    }catch(e){
      PhoneUtil.applog("读取翻译信息失败");
    }
  }

  static Country? getCounty(String code2) {
    List<Country> countries = countryList.where(acceptAllCountries).toList();
    for (Country ct in countries) {
      if (code2 == ct.isoCode?.toLowerCase() ||
          code2 == ct.isoCode!.toUpperCase()) {
        PhoneUtil.applog("系统国家信息${ct.name}");
        PhoneUtil.applog("系统货币信息 代码:${ct.currencyCode} 货币名称${ct.currencyName}");
        return ct;
      }
    }
    for (Country ct in countries) {
      if (code2 == "US") {
        return ct;
      }
    }
    return null;
  }

  static show(String str) {
    if (str.isEmpty) {
      PhoneUtil.applog("没有翻译内容");
      return "";
    }
    String lang = language;
    if (language == "cn" || language.contains("zh")) {
      if (language.contains("tw")) {
        lang = "zh-tw";
      } else {
        lang = "zh-cn";
      }
      if (ischinese(str)) return str;
    }
    String md5 = SignUtil.MD5str(str);
    for (Map map in translateList) {
      if (map.containsValue(md5)) {
        if (map.containsKey(lang)) {
          String rec= map[lang];
          return rec;
        }
      }
    }
    try {
      translator.translate(str, from: "auto", to: lang).then((result) {
        String value = result.text;
        Map map = {};
        map.putIfAbsent(lang, () => value);
        map.putIfAbsent("md5", () => md5);
        translateList.add(map);
        saveloctra();
      }).catchError((e) {
        PhoneUtil.applog("catch err翻译错误${e.toString()}");
      });
    }catch(e){
      PhoneUtil.applog("翻译错误${e.toString()}");
    }
    return str;
  }
  static saveloctra(){
    //PhoneUtil.applog("本地保存翻译$translateList");
    CookieStorage.saveToCookie("fchat.tra", JsonUtil.listtostr(translateList));
  }

  static reaeloctra()  {
    String? rec=CookieStorage.getCookie("fchat.tra");
    if(rec!=null){
      //PhoneUtil.applog("读取本地临时存储翻译成功$rec");
      translateList=JsonUtil.strotList(rec);
    }
  }

  static getcnortw(){
    String lang;
    if(language.contains("tw")){
      lang = "zh-tw";
    }else {
      lang = "zh-cn";
    }
    return lang;
  }

  static bool ischinese(String str) {
    RegExp exp = RegExp('r["\u4e00-\u9fa5"]');
    return exp.hasMatch(str);
  }
  static List<Language> gettranslatesupport(){
    //谷歌翻译支付的语言
    Map _langs = {
      // 'auto': 'Automatic',
      'af': 'Afrikaans',
      'sq': 'Albanian',
      'am': 'Amharic',
      'ar': 'Arabic',
      'hy': 'Armenian',
      'az': 'Azerbaijani',
      'eu': 'Basque',
      'be': 'Belarusian',
      'bn': 'Bengali',
      'bs': 'Bosnian',
      'bg': 'Bulgarian',
      'ca': 'Catalan',
      'ceb': 'Cebuano',
      'ny': 'Chichewa',
      'zh-cn': 'China',
      'zh-tw': 'Republic of China',
      'co': 'Corsican',
      'hr': 'Croatian',
      'cs': 'Czech',
      'da': 'Danish',
      'nl': 'Dutch',
      'en': 'English',
      'eo': 'Esperanto',
      'et': 'Estonian',
      'tl': 'Filipino',
      'fi': 'Finnish',
      'fr': 'French',
      'fy': 'Frisian',
      'gl': 'Galician',
      'ka': 'Georgian',
      'de': 'German',
      'el': 'Greek',
      'gu': 'Gujarati',
      'ht': 'Haitian Creole',
      'ha': 'Hausa',
      'haw': 'Hawaiian',
      'iw': 'Hebrew',
      'hi': 'Hindi',
      'hmn': 'Hmong',
      'hu': 'Hungarian',
      'is': 'Icelandic',
      'ig': 'Igbo',
      'id': 'Indonesian',
      'ga': 'Irish',
      'it': 'Italian',
      'ja': 'Japanese',
      'jw': 'Javanese',
      'kn': 'Kannada',
      'kk': 'Kazakh',
      'km': 'Khmer',
      'ko': 'Korean',
      'ku': 'Kurdish (Kurmanji)',
      'ky': 'Kyrgyz',
      'lo': 'Lao',
      'la': 'Latin',
      'lv': 'Latvian',
      'lt': 'Lithuanian',
      'lb': 'Luxembourgish',
      'mk': 'Macedonian',
      'mg': 'Malagasy',
      'ms': 'Malay',
      'ml': 'Malayalam',
      'mt': 'Maltese',
      'mi': 'Maori',
      'mr': 'Marathi',
      'mn': 'Mongolian',
      'my': 'Myanmar (Burmese)',
      'ne': 'Nepali',
      'no': 'Norwegian',
      'ps': 'Pashto',
      'fa': 'Persian',
      'pl': 'Polish',
      'pt': 'Portuguese',
      'pa': 'Punjabi',
      'ro': 'Romanian',
      'ru': 'Russian',
      'sm': 'Samoan',
      'gd': 'Scots Gaelic',
      'sr': 'Serbian',
      'st': 'Sesotho',
      'sn': 'Shona',
      'sd': 'Sindhi',
      'si': 'Sinhala',
      'sk': 'Slovak',
      'sl': 'Slovenian',
      'so': 'Somali',
      'es': 'Spanish',
      'su': 'Sundanese',
      'sw': 'Swahili',
      'sv': 'Swedish',
      'tg': 'Tajik',
      'ta': 'Tamil',
      'te': 'Telugu',
      'th': 'Thai',
      'tr': 'Turkish',
      'uk': 'Ukrainian',
      'ur': 'Urdu',
      'uz': 'Uzbek',
      'ug': 'Uyghur',
      'vi': 'Vietnamese',
      'cy': 'Welsh',
      'xh': 'Xhosa',
      'yi': 'Yiddish',
      'yo': 'Yoruba',
      'zu': 'Zulu'
    };
    List<Language> arr=[];
    _langs.forEach((key, value) {
        arr.add(Language(key,value,""));
        if(key==language){
          nowlanguage = Language(key,value,"");
        }
    });
    if(nowlanguage==null){
      nowlanguage = Language( 'zh-cn','China',"");
    }
    return arr;
  }




}


class TitleMenuLanguage extends StatelessWidget {
  void Function(String value) callback;
  TitleMenuLanguage({Key? key,required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
            width: 100,
            alignment: Alignment.centerLeft,
            child: Text(
              Translate.show("Language") + ":",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // 背景色（可根据需求调整）
                borderRadius: BorderRadius.circular(8), // 圆角边框
                border: Border.all(color: Colors.black, width: 1.5), // 白色边框
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5), // 让边框和内容有间距
              child: LanguagePickerDropdown(
                initialValue: Translate.nowlanguage!,
                languages: Translate.gettranslatesupport(),
                onValuePicked: (Language language) {
                  Translate.language = language.isoCode;
                  callback(language.isoCode);
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );

  }
}
