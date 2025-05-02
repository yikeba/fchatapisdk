
class WebCommand{
  static const String sapplogin="sapplogin";
  static const String readfile="readfile";  //读取ui即产品数据
  static const String writeUIdata="writeUIdata";  //写入ui数据（服务器端不接受，app端验证）
  static const String upfile="upfile";  //写入ui数据（服务器端不接受，app端验证）
  static const String upfilepublic="upfilepublic";  //写入ui数据（服务器端不接受，app端验证）
  static const String upData="upData";  //写入ui数据（服务器端不接受，app端验证）
  static const String upDatapublic="upDatapublic";  //写入ui数据（服务器端不接受，app端验证）
  static const String readMD="readMD";  //读取目录所有文件
  static const String readMDthb="readMDthb";   //读取目录文件名称和路径
  static const String readGroup="readGroup";  //读取客服群聊信息
  static const String sendMsg="sendMsg";  //通过服务器群发消息给客户
  static const String delfile="delfile";  //删除指定文件
  static const String paymentorder="paymentorder";  //如提交系统支付流水单
  static const String ABApay="ABApay";  //如提交系统支付流水单
  static const String stripepay="stripepay"; //提交信用卡支付
  static const String stripeorder="stripeorder"; //提交信用卡订单支付
  static const String payidQuery="payidQuery";  //查询订单是否支付
  static const String readstripekey="readstripekey";  //读取stripekey
  static const String createWebPaymentIntent="createWebPaymentIntent";  //服务器创建支付PaymentIntent
  static const String createWebPayUrl="createWebPayUrl";  //服务器创建stripe 跳转支付
  static const String verifyPay="verifyPay";  //验证支付是否成功
  static const String weblogin="weblogin";  //web扫码登录
  static const String  chatService="chatService";  //更新服务号资料
  static const String  autodeployapp="autodeployapp";  //自动部署web app
  static const String  expresszto="expresszto";  //中通接口，创建订单
  static const String  email="email";  //发送email
  static const String  searchCHATid="searchCHATid";  //返回用户基本信息
  static const String  moneymanagement="moneymanagement";  //资金管理读取服务号资金




}