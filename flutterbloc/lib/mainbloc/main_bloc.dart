import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterbloc/mainbloc/main_bloc_event.dart';
import 'package:flutterbloc/mainbloc/main_bloc_state.dart';

class AppBloc extends Bloc<AppBlocEvent, AppState> {
  int counter = 0;

  AppBloc() : super(InitialState()) {
    on<IncreamentCounter>((event, emit) {

      counter =counter+1;

      emit(UpdatedState(count: counter));

    });
  }
}
