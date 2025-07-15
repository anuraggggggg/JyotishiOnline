import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // case TargetPlatform.windows:
      //   return web;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCf43So6LDiOrI4x4Lt3uD_KAIi0VFPLu8",
    authDomain: "jyotiuser-173d9.firebaseapp.com",
    projectId: "jyotiuser-173d9",
    storageBucket: "jyotiuser-173d9.firebasestorage.app",
    messagingSenderId: "1049596131961", //381086206621
    appId: "1:1049596131961:android:1701dd36d5fe9213bdb2a8",
    measurementId: "G-B2HHX4PRVW",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDLKSYwB_cM_L2NyWMjBlXYvRHH9iGWlyE",
    appId: "1:611219590951:web:8f1dbb0ef29b36dd81a302",
    messagingSenderId: "611219590951",
    projectId: "jyoti-astrologer",
    storageBucket: "jyoti-astrologer.firebasestorage.app",
    iosBundleId: 'com.astrowaydiploy.user',
    measurementId: "G-KBPRBBZRYC",
  );

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyDLKSYwB_cM_L2NyWMjBlXYvRHH9iGWlyE",
      authDomain: "jyoti-astrologer.firebaseapp.com",
      databaseURL: "https://jyotishiweb-default-rtdb.firebaseio.com/",
      projectId: "jyoti-astrologer",
      storageBucket: "jyoti-astrologer.firebasestorage.app",
      messagingSenderId: "611219590951",
      appId: "1:611219590951:web:8f1dbb0ef29b36dd81a302",
      measurementId: "G-B2HHX4PRVW");
}
