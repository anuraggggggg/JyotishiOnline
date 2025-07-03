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
    apiKey: "AIzaSyAyiZi-oi6QilI2X-7hNcCgtbmRT2WLAhs",
    authDomain: "astroway-diploy.firebaseapp.com",
    projectId: "astroway-diploy",
    storageBucket: "astroway-diploy.appspot.com",
    messagingSenderId: "381086206621", //381086206621
    appId: "1:381086206621:android:b5c7542da161358d32e274",
    measurementId: "G-KBPRBBZRYC",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDsrsuJ2tx83rRPdTrAUKQRNhmmCTbEzxA",
    appId: "1:381086206621:ios:50ef1a4a2bd8342b32e274",
    messagingSenderId: "381086206621",
    projectId: "astroway-diploy",
    storageBucket: "astroway-diploy.appspot.com",
    iosBundleId: 'com.astrowaydiploy.user',
    measurementId: "G-KBPRBBZRYC",
  );

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyAyiZi-oi6QilI2X-7hNcCgtbmRT2WLAhs",
      authDomain: "astroway-diploy.firebaseapp.com",
      databaseURL: "https://astroway-diploy-default-rtdb.firebaseio.com",
      projectId: "astroway-diploy",
      storageBucket: "astroway-diploy.appspot.com",
      messagingSenderId: "381086206621",
      appId: "1:381086206621:web:f09b5db876e2323d32e274",
      measurementId: "G-XY1LD81J6X");
}
