import 'package:equatable/equatable.dart';


abstract class MasterPageEvent extends Equatable {
  const MasterPageEvent();
}

class UpdateIndex extends MasterPageEvent {
  final int index;
  const UpdateIndex(this.index);
  @override
  List<Object> get props => [index];
}

