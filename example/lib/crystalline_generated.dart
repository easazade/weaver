// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, duplicate_import, unused_import

import 'package:flutter_crystalline/flutter_crystalline.dart';

import 'package:example/app/stores/auth_store.dart';
import 'package:example/app/api/user_api.dart';
import 'package:example/app/models/user.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'dart:core';

class SharedState {
  static SharedState? _instance;

  static SharedState get instance {
    _instance ??= SharedState();
    return _instance!;
  }

  final user = $$userSharedProperty;
}
