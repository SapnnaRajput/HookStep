import 'package:dancebuddy/splash/splash_bloc/splash_bloc.dart';
import 'package:dancebuddy/splash/splash_bloc/splash_event.dart';
import 'package:dancebuddy/splash/splash_bloc/splash_state.dart';
import 'package:dancebuddy/utils/gradient_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/onboarding_screen/onboarding_screens.dart';
import '../masterpage/masterpage.dart';
import '../utils/theam_manager.dart';
import '../utils/want_text.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => SplashBloc()..add(NavigateToNextPageEvent()),
        child: const SplashView(),
      ),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToOnboarding) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OnboardingScreen()),
          );
        } else if (state is SplashNavigateToMaster) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MasterPage()),
          );
        }
      },
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.4,
            ),
            SizedBox(
              height: height * 0.22,
              width: height * 0.25,
              child: Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.fill,
              ),
            ),
            // SizedBox(
            //   height: height * 0.01,
            // ),  SizedBox(
            //   height:width * 0.07,
            //   // width: height * 0.25,
            //   child: Image.asset(
            //     "assets/images/hookstep.png",
            //     fit: BoxFit.fill,
            //   ),
            // ),
            // // GradientText("HookStep", width * 0.07, FontWeight.bold),

            // SizedBox(
            //   height: width * 0.02,
            // ),
            // WantText(
            //   "⁃•⦿ VIDEO PROSSING ⦿•⁃",
            //   width * 0.035,
            //   FontWeight.w500,
            //   colorSubTittle,
            // ),
          ],
        ),
      ),
    );
  }
}