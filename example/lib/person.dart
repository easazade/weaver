import 'package:weaver/weaver.dart';

@AutoToString()
class Person {
  final String firstName;
  final String lastName;
  final int age;
  final bool isActive;

  Person({
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.isActive,
  });
}
