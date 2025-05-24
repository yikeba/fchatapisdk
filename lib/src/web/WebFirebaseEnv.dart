// lib/src/web/WebFirebaseEnv.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../../WidgetUtil/AuthWidget.dart';

class WebFirebaseEnv {
  static Future<void> initenv() async {
    if (!kIsWeb) return;

    await dotenv.load(fileName: "packages/fchatapi/assets/.env");

    FirebaseConfig.apiKey = dotenv.get('firebaseapiKey');
    FirebaseConfig.authDomain = dotenv.get('firebaseauthDomain');
    FirebaseConfig.projectId = dotenv.get('firebaseprojectId');
    FirebaseConfig.storageBucket = dotenv.get('firebasestorageBucket');
    FirebaseConfig.messagingSenderId = dotenv.get('firebasemessagingSenderId');
    FirebaseConfig.appId = dotenv.get('firebaseappId');
    FirebaseConfig.measurementId = dotenv.get('firebasemeasurementId');
    FirebaseConfig.clientId = dotenv.get('clientId');
    FirebaseConfig.redirectUri = dotenv.get('redirectUri');

    await Firebase.initializeApp(options: FirebaseConfig.webConfig);
  }
}
