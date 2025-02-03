// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDPaWdB166UpYfm4UPX_FBoG0q3ZGmm_Go',
    appId: '1:39799101733:android:2b1379b221c0729f0b22cc',
    messagingSenderId: '39799101733',
    projectId: 'marlinda-c26cd',
    storageBucket: 'marlinda-c26cd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBLpnNvT_RkdfgwTGael44wDGI2H6lug5Q',
    appId: '1:39799101733:ios:0fc89e79d79b1f770b22cc',
    messagingSenderId: '39799101733',
    projectId: 'marlinda-c26cd',
    storageBucket: 'marlinda-c26cd.firebasestorage.app',
    androidClientId: '39799101733-3540abkpvr9a451t3itrcvt8us3pgbv6.apps.googleusercontent.com',
    iosClientId: '39799101733-qg9t17nm6o7hnqdibs96i94ugjent3nn.apps.googleusercontent.com',
    iosBundleId: 'com.example.rakhsa.RunnerTests',
  );
}
