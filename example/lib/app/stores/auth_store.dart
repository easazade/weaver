import 'package:example/app/models/user.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

part 'auth_store.crystalline.dart';

@store()
abstract class _AuthStore extends Store {
  final user = Data<User>();

  Future<void> login({
    required String username,
    required String password,
  }) async {
    user.failure = null;
    user.operation = Operation.read;
    publish();

    
  }
}
