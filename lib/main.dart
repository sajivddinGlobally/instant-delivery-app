/*
import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/firebaseOption.dart';
import 'package:delivery_mvp_app/CustomerScreen/start.screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'CustomerScreen/notificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  await Hive.initFlutter();
  await Hive.openBox("folder");

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> getToken() async {
    // Permission request करें (iOS/Android पर जरूरी)
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: true, // iOS के लिए provisional permission
          carPlay: true,
        );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
      return;
    }

    // FCM Token निकालें
    String? token = await FirebaseMessaging.instance.getToken();
    // setState(() {
    //   _fcmToken = token;
    // });
    log('FCM Token: $token'); // Console में print होगा
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    getToken();
    var box = Hive.box("folder");
    var token = box.get("token");
    log("=====================================");
    log(token ?? "No token found");

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF092325),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: ScreenUtilInit(
        designSize: Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // TRY THIS: Try running your application with "flutter run". You'll see
              // the application has a purple toolbar. Then, without quitting the app,
              // try changing the seedColor in the colorScheme below to Colors.green
              // and then invoke "hot reload" (save your changes or press the "hot
              // reload" button in a Flutter-supported IDE, or press "r" if you used
              // the command line to start the app).
              //
              // Notice that the counter didn't reset back to zero; the application
              // state is not lost during the reload. To reset the state, use hot
              // restart instead.
              //
              // This works for code too, not just values: Most code changes can be
              // tested with just a hot reload.
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: StartScreen(),
          );
        },
      ),
    );
  }
}
*/
import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/firebaseOption.dart';
import 'package:delivery_mvp_app/CustomerScreen/start.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/notificationService.dart'; // Assuming PickupScreen is in a similar path; adjust import as needed
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'CustomerScreen/Newscreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize NotificationService (singleton)
  await NotificationService().init();
  await Hive.initFlutter();
  await Hive.openBox("folder");
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    // Set up navigation callback after the first frame to ensure navigator is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = NotificationService();
      service.setNavigationCallback((deliveryId) {
        // Navigate to PickupScreen with deliveryId
        // If using named routes, use: navigatorKey.currentState?.pushNamed('/pickup', arguments: deliveryId);
        // For now, using direct push; adjust as per your routing setup
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => PickupScreenNotification( deliveryId: deliveryId,), // Pass deliveryId as needed
          ),
        );
      });
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var box = Hive.box("folder");
    var token = box.get("token");
    log("=====================================");
    log(token ?? "No token found");

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF092325),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: ScreenUtilInit(
        designSize: Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            navigatorKey: navigatorKey, // Attach the global navigator key
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: StartScreen(),
            // If using named routes, add here:
            // routes: {
            //   '/pickup': (context) => PickupScreen(deliveryId: ModalRoute.of(context)?.settings.arguments as String? ?? ''),
            // },
          );
        },
      ),
    );
  }
}


