// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // case TargetPlatform.iOS:
      //   return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAqr2XNU0WZjpZs4i1NdCkLKdjs9sqRbfw",
    authDomain: "capstone-imnotjervis.firebaseapp.com",
    projectId: "capstone-imnotjervis",
    storageBucket: "capstone-imnotjervis.firebasestorage.app",
    messagingSenderId: "888685584223",
    appId: "1:888685584223:web:8ec008dde0737d2748e0ea",
    //measurementId: 'YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDj5iruru7r_9ll0W2FzKHT3b0AN_gOgwg',
    projectId: 'capstone-imnotjervis',
    storageBucket: 'capstone-imnotjervis.firebasestorage.app',
    messagingSenderId: '888685584223',
    appId: '1:888685584223:android:379c72012bfc6b9348e0ea',
  );


}
