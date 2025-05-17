import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'master_page_event.dart';
import 'master_page_state.dart';

class MasterPageBloc extends Bloc<MasterPageEvent, MasterPageState> {


  MasterPageBloc() : super(const MasterPageState(0)) {
    on<UpdateIndex>(_onUpdateIndex);

  }

  Future<void> _onUpdateIndex(
      UpdateIndex event, Emitter<MasterPageState> emit) async {
    emit(MasterPageState(event.index));

      }




}
