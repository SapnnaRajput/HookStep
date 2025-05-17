import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/theam_manager.dart';
import '../../utils/want_text.dart';
import '../../utils/widget/general_button/general_button.dart';
import '../login_screen/login_screen.dart';
import 'onboarding_bloc/onboarding_bloc.dart';
import 'onboarding_bloc/onboarding_event.dart';
import 'onboarding_bloc/onboarding_state.dart';
import 'onboarding_content.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc()..add(PageChangedEvent(0)), // Set the initial state
      child: OnboardingView(),
    );
  }
}

class OnboardingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final bloc = BlocProvider.of<OnboardingBloc>(context);

    return Scaffold(
      backgroundColor: colorWhite,
      body: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          int currentPage = (state is OnboardingPageChanged) ? state.currentPage : 0;

          return Stack(
            children: [
              // Main PageView
              PageView.builder(
                scrollDirection: Axis.horizontal,
                controller: bloc.pageController,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  bloc.add(PageChangedEvent(index));
                },
                itemBuilder: (context, index) {
                  return SizedBox( // Remove Expanded and use SizedBox
                    height: height,
                    width: width,
                    child: Image.asset(
                      contents[index].image,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),

              // Page Indicator
              Padding(
                padding: EdgeInsets.only(
                  top: height * 0.85,
                  right: width * 0.08,
                  left: width * 0.08,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(contents.length, (dotIndex) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: width * 0.008),
                      width: dotIndex == currentPage ? width * 0.045 : width * 0.03,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.05),
                        color: dotIndex == currentPage ? colorMainTheme : colorGrey,
                      ),
                    );
                  }),
                ),
              ),

              // Conditional Navigation Buttons
              if (currentPage < contents.length - 1) // Not the last page
                Padding(
                  padding: EdgeInsets.only(left: width * 0.04, right: width * 0.06, top: height * 0.9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip Button
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreeen()),
                          );
                        },
                        child: WantText("Skip", width * 0.045, FontWeight.w500, colorBlack),
                      ),
                      // Next Button
                      GestureDetector(
                        onTap: () {
                          bloc.pageController.nextPage(
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: CircleAvatar(
                          radius: width * 0.055,
                          backgroundColor: colorBlack,
                          child: Icon(Icons.navigate_next, color: colorWhite),
                        ),
                      ),
                    ],
                  ),
                ),

              // Let's Start Button on Last Page
              if (currentPage == contents.length - 1)
                Padding(
                  padding: EdgeInsets.only(left: width * 0.06, right: width * 0.06, top: height * 0.9),
                  child: GeneralButton(
                    Width: width,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreeen()),
                      );
                    },
                    label: "Let's Start >",
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
