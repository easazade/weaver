import 'package:weaver/weaver.dart';

@AutoToString()
class Model {
  final String name;
  final int age;

  Model({required this.name, required this.age});
}
