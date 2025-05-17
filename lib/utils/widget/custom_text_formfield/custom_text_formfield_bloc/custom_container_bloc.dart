import 'package:bloc/bloc.dart';
import 'custom_container_event.dart';
import 'custom_container_state.dart';

class FormFieldBloc extends Bloc<FormFieldEvent, FormFieldBlocState> {
  final bool Function(String) validator;
  final String errorMessage;

  FormFieldBloc({required this.validator, required this.errorMessage})
      : super(FormFieldBlocState(value: '', error: null)) {
    on<FormFieldChanged>((event, emit) {
      if (validator(event.value)) {
        emit(state.copyWith(value: event.value, error: errorMessage));
      } else {
        emit(state.copyWith(value: event.value, error: null));
      }
    });
  }
}
