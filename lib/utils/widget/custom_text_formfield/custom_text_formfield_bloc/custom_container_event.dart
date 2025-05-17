abstract class FormFieldEvent {}

class FormFieldChanged extends FormFieldEvent {
  final String value;

  FormFieldChanged({required this.value});
}
