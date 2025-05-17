import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final PageController pageController = PageController();
  Timer? _autoScrollTimer;
  bool _isManualScroll = false; // Flag to track manual scrolls
  int _currentPage = 0; // Keep track of the current page internally

  OnboardingBloc() : super(OnboardingInitial()) {
    _startAutoScroll(); // Start auto-scroll on initialization

    on<NextEvent>((event, emit) {
      if (_currentPage < 3) {
        _currentPage++;
        pageController.nextPage(
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        emit(OnboardingPageChanged(_currentPage));
      } else if (_currentPage == 3) {
        _currentPage++; // Ensure we can still move from page 2 to 3
        pageController.nextPage(
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        emit(OnboardingPageChanged(_currentPage));
        _cancelAutoScroll(); // Stop auto-scroll on reaching the last page
      }
    });



    on<PageChangedEvent>((event, emit) {
      _currentPage = event.pageIndex;
      emit(OnboardingPageChanged(_currentPage));
      // Only cancel auto-scroll if the user is manually scrolling
      if (_isManualScroll) {
        _cancelAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!_isManualScroll && _currentPage < 3) { // Allow the scroll to go from 2 to 3
        add(NextEvent());
      } else {
        _cancelAutoScroll(); // Stop the timer on reaching the last page
      }
    });
  }

  void _cancelAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void onManualScrollStart() {
    _isManualScroll = true;
  }

  void onManualScrollEnd() {
    // Allow auto-scroll if we haven't reached the last page yet
    if (_currentPage < 3) {
      _isManualScroll = false;
    }
  }

  @override
  Future<void> close() {
    _cancelAutoScroll();
    return super.close();
  }
}