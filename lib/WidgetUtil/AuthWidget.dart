import 'package:fchatapi/util/DeviceInfo.dart';
import 'package:fchatapi/webapi/StripeUtil/CookieStorage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../Util/PhoneUtil.dart';
import '../util/Translate.dart';

class EmailAuthWidget extends StatefulWidget {
  final Function(String email) onLoginSuccess;
  String email;

  EmailAuthWidget({Key? key, required this.email, required this.onLoginSuccess})
      : super(key: key);

  @override
  _EmailAuthWidgetState createState() => _EmailAuthWidgetState();
}

class _EmailAuthWidgetState extends State<EmailAuthWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? email;

  @override
  void initState() {
    super.initState();
    if (widget.email.isNotEmpty) {
      email = widget.email;
    } else {
      email = CookieStorage.getCookie("email") ?? Translate.show("发送邮箱");
    }
  }

  @override
  void dispose() {
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
          clientId: FirebaseConfig.clientId,
          redirectUri: Uri.parse(FirebaseConfig.redirectUri),
        ),
      );

      PhoneUtil.applog(
          "Apple 凭据获取成功: identityToken=${credential.identityToken}, authCode=${credential.authorizationCode}");

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
        title: const Text("登录失败", style: TextStyle(fontSize: 18 * 0.9)),
        content: Text(error, style: const TextStyle(fontSize: 14 * 0.9)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("确定", style: TextStyle(fontSize: 14 * 0.9)),
          ),
        ],
      ),
    );
  }

  Widget getAuth() {
    return Card(
      elevation: 4,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white, width: 1), // 直接在 Card 设置白色边框
      ),
      child: Container(
        padding: const EdgeInsets.all(4.0),
        color: Colors.transparent,
        child: _getAuthIcon(),
      ),
    );
  }

  TextEditingController emailController = TextEditingController();

  Widget _iniputEmail() {
    if (email == Translate.show("发送邮箱")) {
      return Expanded(
        flex: 2, // 占 50% 宽度（flex 总和为 4，flex: 2 占 50%）
        child: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email, size: 20, color: Colors.grey),
            hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          style: const TextStyle(fontSize: 16 * 0.9, color: Colors.grey),
          onChanged: (value) {
            PhoneUtil.applog("输入的内容：$value");
            if (RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              widget.onLoginSuccess(value);
              email = value;
              CookieStorage.saveToCookie("email", value);
            }
          },
        ),
      );

    } else {
      return Expanded(
        flex: 2, // 占 50% 宽度
        child: Text(
          email!,
          style: const TextStyle(fontSize: 16 * 0.9, color: Colors.black54),
        ),
      );
    }
  }

  Widget _getAuthIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Apple 登录按钮（只显示 logo）
        if (widget.email.isEmpty) ...[
          const SizedBox(width: 10,),
          Container(
            width: 40 * 0.8, // 按钮宽度缩小 20%
            height: 40 * 0.8, // 按钮高度缩小 20%
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8 * 0.8),
              border: Border.all(color: Colors.grey),
            ),
            child: IconButton(
              onPressed: _signInWithApple,
              icon: Image.asset(
                "assets/img/apple.png",
                width: 20 , // 图标大小缩小 20%
                height: 20 ,
                package: 'fchatapi',
              ),
              color: Colors.white,
            ),
          ),
          // Google 登录按钮（只显示 logo）
          const SizedBox(width: 10,),
          Container(
            width: 40 * 0.8,
            height: 40 * 0.8,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8 * 0.8),
              border: Border.all(color: Colors.grey),
            ),
            child: IconButton(
              onPressed: _signInWithGoogle,
              icon: Image.asset(
                "assets/img/google.png",
                width: 20 ,
                height: 20 ,
                package: 'fchatapi',
              ),
            ),
          ),
        ],
        SizedBox(width: 15,),
        // 输入邮箱
        _iniputEmail(),
        const SizedBox(width: 10,),
      ],
    );
  }

  signLogin() {
    if (widget.email.isNotEmpty) return;
    if (DeviceInfo.isIos() || DeviceInfo.isMac()) {
      _signInWithApple();
    } else {
      _signInWithGoogle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return getAuth();
  }
}

class FirebaseConfig {
  static String apiKey = "";
  static String authDomain = "";
  static String projectId = "";
  static String storageBucket = "";
  static String messagingSenderId = "";
  static String appId = "";
  static String measurementId = "";

  static String clientId = "";
  static String redirectUri = "";

  static FirebaseOptions get webConfig {
    return FirebaseOptions(
      apiKey: apiKey,
      authDomain: authDomain,
      projectId: projectId,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
      appId: appId,
      measurementId: measurementId,
    );
  }
}