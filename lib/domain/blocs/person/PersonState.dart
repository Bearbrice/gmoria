import 'package:equatable/equatable.dart';
import 'package:gmoria/domain/models/Person.dart';

abstract class PersonState extends Equatable {
  const PersonState();

  @override
  List<Object> get props => [];
}

class PersonLoading extends PersonState {}

class PersonLoaded extends PersonState {
  final List<Person> person;

  const PersonLoaded([this.person = const []]);

  @override
  List<Object> get props => [person];

  @override
  String toString() => 'PersonLoaded { person: $person }';
}

class SinglePersonLoaded extends PersonState {
  final Person person;

  const SinglePersonLoaded(this.person);

  @override
  List<Object> get props => [person];

  @override
  String toString() => 'PersonLoaded { person: $person }';
}

class UserListPersonLoaded extends PersonState {
  final List<Person> person;

  const UserListPersonLoaded([this.person = const []]);

  @override
  List<Object> get props => [person];

  @override
  String toString() => 'PersonLoaded { person: $person }';
}


class PersonAdded extends PersonState {
  final String id;

  const PersonAdded(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'PersonAdded { id: $id }';
}

class PersonLoadNotLoaded extends PersonState {}
