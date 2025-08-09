import 'package:flutter/foundation.dart';

void log(final String message) {
  if (kDebugMode) {
    print(message);
  }
}
