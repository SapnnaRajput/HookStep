import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../utils/get_api_key.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<NavigateToNextPageEvent>((event, emit) async {
      await Future.delayed(const Duration(milliseconds: 2000));

      // Check for login status from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('id');
      String? uid = prefs.getString('uid');

      await GetAPIDataRepository.fetchApiKey();





      // If any of the login-related values are present, navigate to MasterPage
      if (token != null || id != null || uid != null) {
        emit(SplashNavigateToMaster());
      } else {
        // Otherwise, navigate to the onboarding screen
        emit(SplashNavigateToOnboarding());
      }
    });
  }
}
