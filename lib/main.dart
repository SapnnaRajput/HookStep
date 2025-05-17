import 'dart:io';

import 'package:dancebuddy/home_screen/home_screen.dart';
import 'package:dancebuddy/masterpage/masterpage.dart';
import 'package:dancebuddy/splash/splash.dart';
import 'package:dancebuddy/splash/splash_bloc/splash_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

void main()async {WidgetsFlutterBinding.ensureInitialized();
// await Firebase.initializeApp(
//   name: "hookstep-fade4",
//   options: const FirebaseOptions(
//     apiKey:  "AIzaSyCBG5HwN91k52aBqvhecGtABLLkulTn6tI",
//     appId: "1:735030885817:android:447f64461fdebdc1448a68",
//     messagingSenderId: "735030885817",
//     projectId: "hookstep-fade4",
//   ),
// );
//
// final FirebaseOptions firebaseOptions = (Platform.isIOS || Platform.isMacOS)
//     ? const FirebaseOptions(
//   apiKey:  "AIzaSyCBG5HwN91k52aBqvhecGtABLLkulTn6tI",
//   appId: "1:735030885817:ios:2e28eca7b7064ca7448a68",
//   messagingSenderId: "735030885817",
//   projectId: "hookstep-fade4",
// )
//     : const FirebaseOptions(
//   apiKey:  "AIzaSyCBG5HwN91k52aBqvhecGtABLLkulTn6tI",
//   appId: "1:735030885817:android:447f64461fdebdc1448a68",
//   messagingSenderId: "735030885817",
//   projectId: "hookstep-fade4",
// );
//
//
// await Firebase.initializeApp(name: 'hookstep', options: firebaseOptions);
SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown
]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'HookStep',
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(providers: [
        BlocProvider(create: (_) => SplashBloc()),
      ],
        child: ShowCaseWidget(
          builder: (context) => SplashScreen(),
        )
      ),
    );
  }
}

