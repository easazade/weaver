// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:example/person.dart';
import 'package:example/model.dart';

extension PersonAutoToString on Person {
  String autoToString() {
    return 'Person(firstName: $firstName, lastName: $lastName, age: $age, isActive: $isActive)';
  }
}

extension ModelAutoToString on Model {
  String autoToString() {
    return 'Model(name: $name, age: $age)';
  }
}
