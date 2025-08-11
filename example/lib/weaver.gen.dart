import 'package:example/model.dart';
import 'package:example/person.dart';

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations

extension PersonAuto on Person {
  String stringify() =>
      "Person(firstName: $firstName, lastName: $lastName, age: $age, isActive: $isActive)";
}

extension ModelAuto on Model {
  String stringify() => "Model(name: $name, age: $age)";
}
