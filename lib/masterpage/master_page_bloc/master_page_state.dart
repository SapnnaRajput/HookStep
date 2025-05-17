import 'package:equatable/equatable.dart';

class MasterPageState extends Equatable {
  final int selectedIndex;
  const MasterPageState(this.selectedIndex);
  @override
  List<Object> get props => [selectedIndex];
}

class ReadingSmsMessages extends MasterPageState {
  const ReadingSmsMessages(int selectedIndex) : super(selectedIndex);
}

class FilteringSmsMessages extends MasterPageState {
  const FilteringSmsMessages(int selectedIndex) : super(selectedIndex);
}

class SmsMessagesFiltered extends MasterPageState {
  final List<Map<String, String>> filteredMessages;
  const SmsMessagesFiltered(this.filteredMessages, int selectedIndex) : super(selectedIndex);
  @override
  List<Object> get props => [filteredMessages, selectedIndex];
}

class SmsProcessCompleted extends MasterPageState {
  const SmsProcessCompleted(int selectedIndex) : super(selectedIndex);
}

class TransactionSavedSuccessfully extends MasterPageState {
  const TransactionSavedSuccessfully(int selectedIndex) : super(selectedIndex);
}
