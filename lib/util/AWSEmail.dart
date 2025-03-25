import 'package:fchatapi/Util/PhoneUtil.dart';
import 'package:fchatapi/util/JsonUtil.dart';
import 'package:fchatapi/webapi/HttpWebApi.dart';
import 'package:fchatapi/webapi/StripeUtil/WebPayUtil.dart';
import 'package:fchatapi/webapi/WebCommand.dart';
import 'package:http/http.dart' as http;

class AWSEmail{
   String email;
   String subject;
   String body;
   Map _map={};
   String htmlBody="";
   AWSEmail(this.email,this.subject,this.body){
     _initEmail();
   }

   _initEmail(){
     _map.clear();
     _map.putIfAbsent("email", ()=> email);
     _map.putIfAbsent("subject", ()=> subject);
     _map.putIfAbsent("body", ()=>body);
   }

   toJson()=> _map;

   @override
  String toString() {
    // TODO: implement toString
    return JsonUtil.maptostr(_map);
  }

  Future<bool> sendMail() async {
     if(email.isEmpty) return false;
     if(body.isEmpty) return false;
     if(subject.isEmpty) return false;
     if(htmlBody.isNotEmpty){
       _map.putIfAbsent("html", ()=> htmlBody);
     }
     PhoneUtil.applog("发送邮件内容:${_map}");
     Map<String,dynamic> sendmap=WebPayUtil.getDataMap(_map, WebCommand.email);
     String rec=await WebPayUtil.httpFchatserver(sendmap);
     RecObj robj=RecObj(rec);
     PhoneUtil.applog("邮件发送返回${robj.data}");
     if(robj.data=="ok"){
       return true;
     }
     return false;
  }


   Future<String> _fetchHtmlContent(String url) async {
     try {
       final response = await http.get(Uri.parse(url));
       if (response.statusCode == 200) {
         return response.body; // 返回 HTML 内容
       } else {
         throw Exception('加载 HTML 内容失败');
       }
     } catch (e) {
       print('加载 HTML 内容时发生错误: $e');
       return '';
     }
   }

   Future<void> EmailWithHtml(String url) async {
     // 从 URL 加载 HTML 内容
     htmlBody = await _fetchHtmlContent(url);

   }
}