class FormFieldBlocState {
  final String value;
  final String? error;

  FormFieldBlocState({required this.value, this.error});

  FormFieldBlocState copyWith({String? value, String? error}) {
    return FormFieldBlocState(
      value: value ?? this.value,
      error: error,
    );
  }
}
