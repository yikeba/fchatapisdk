import 'package:fchatapi/util/DeviceInfo.dart';
import 'package:fchatapi/webapi/StripeUtil/CookieStorage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../Util/PhoneUtil.dart';

class EmailAuthWidget extends StatefulWidget {
  final Function(String email) onLoginSuccess;

  const EmailAuthWidget({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  _EmailAuthWidgetState createState() => _EmailAuthWidgetState();
}

class _EmailAuthWidgetState extends State<EmailAuthWidget> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? email;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 两个标签：Apple 和 Google
    email = CookieStorage.getCookie("email") ?? "发送邮箱";
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final userCredential = await _auth.signInWithPopup(googleProvider);
      if (userCredential.user != null) {
        PhoneUtil.applog("Google 登录验证成功${userCredential.user!.email}");
        widget.onLoginSuccess(userCredential.user!.email ?? '');
        if (userCredential.user!.email != null) {
          email = userCredential.user!.email;
          CookieStorage.saveToCookie("email", userCredential.user!.email!);
          setState(() {});
        }
      }
    } catch (e) {
      _showErrorDialog("Google 登录失败: $e");
    }
  }

  Future<void> _signInWithApple() async {
    try {
      PhoneUtil.applog("开始 Apple 登录流程");
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.fchatservice.com',
          redirectUri: Uri.parse('https://mall-31447.firebaseapp.com/__/auth/handler'),
        ),
      );

      PhoneUtil.applog("Apple 凭据获取成功: identityToken=${credential.identityToken}, authCode=${credential.authorizationCode}");

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        PhoneUtil.applog("检测到现有用户，尝试重新认证或合并");
        await currentUser.reauthenticateWithCredential(oauthCredential);
      } else {
        final userCredential = await _auth.signInWithCredential(oauthCredential);
        if (userCredential.user != null) {
          widget.onLoginSuccess(userCredential.user!.email ?? '');
          PhoneUtil.applog("Apple 登录成功: email=${userCredential.user!.email}");
          if (userCredential.user!.email != null) {
            email = userCredential.user!.email;
            CookieStorage.saveToCookie("email", userCredential.user!.email!);
            setState(() {});
          }
        }
      }
    } catch (e) {
      PhoneUtil.applog("Apple 登录失败: $e");
      _showErrorDialog("Apple 登录失败: $e");
    }
  }

  void _showErrorDialog(String error) {
    PhoneUtil.applog("登录失败$error");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("登录失败"),
        content: Text(error),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("确定")),
        ],
      ),
    );
  }

  Widget getAuth(){
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _getAuthIcon(),
      ),
    );
  }

  _getAuthIcon(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TabBar 包含 Apple 和 Google 图标
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200], // 背景色
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(
                icon: Image.asset(
                  "assets/img/apple.png",
                  width: 20,
                  height: 20,
                  package: 'fchatapi',
                ), //
                text: "Apple",
              ),
              Tab(
                icon: Image.asset(
                  "assets/img/google.png",
                  width: 20,
                  height: 20,
                  package: 'fchatapi',
                ), // Google 图标（网络图片）
                text: "Google",
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                _signInWithApple(); // 点击 Apple 标签触发登录
              } else if (index == 1) {
                _signInWithGoogle(); // 点击 Google 标签触发登录
              }
            },
          ),
        ),
        const SizedBox(height: 16), // 间距
        // 下方提示文字
        const Text(
          "请给我设备发送订单邮件",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return getAuth();
  }
}

class FirebaseConfig {
  static FirebaseOptions get webConfig {
    return const FirebaseOptions(
      apiKey: "AIzaSyByJBQKGrfLKi2TD6gcjUOKYFQ_7LwYCZo",
      authDomain: "mall-31447.firebaseapp.com",
      projectId: "mall-31447",
      storageBucket: "mall-31447.firebasestorage.app",
      messagingSenderId: "1083324276915",
      appId: "1:1083324276915:web:db7b5729ac853dc01510c6",
      measurementId: "G-VG72GRSJQ4",
    );
  }
}