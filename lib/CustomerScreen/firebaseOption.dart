import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAX-DNcknidZS4yF39jn-XIwZO0aKLDEB0',
    appId: '1:1015566366361:android:77e73796aab2a4843f2a08',
    messagingSenderId: '1015566366361',
    projectId: 'mmp--mymarketplace',
    storageBucket: 'mmp--mymarketplace.firebasestorage.app"',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-messaging-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
    iosBundleId: 'your-ios-bundle-id',
  );

}