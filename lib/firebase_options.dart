import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyBycKhgXLiiLssmcC3crMVjuoTq5aOqsZI',
        authDomain: 'campusboard-sabanci.firebaseapp.com',
        projectId: 'campusboard-sabanci',
        storageBucket: 'campusboard-sabanci.firebasestorage.app',
        messagingSenderId: '280857147242',
        appId: '1:280857147242:web:c3df5f80ad3610b5ac9713',
        measurementId: 'G-R8B6KRML2Y',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return null;
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  static bool get isConfigured => currentPlatform != null;
}
