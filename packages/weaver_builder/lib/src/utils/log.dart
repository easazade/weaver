// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:weaver_builder/src/utils/verbose_logs.dart';

class Log {
  static void redText(dynamic object) {
    if (verboseLogs) print("\x1B[31m${object}\x1B[0m");
  }

  static void greenText(dynamic object) {
    if (verboseLogs) print("\x1B[32m${object}\x1B[0m");
  }

  static void yellowText(dynamic object) {
    if (verboseLogs) print("\x1B[33m${object}\x1B[0m");
  }

  static void orangeText(dynamic object) {
    if (verboseLogs) print("\x1B[34m${object}\x1B[0m");
  }

  static void magentaText(dynamic object) {
    if (verboseLogs) print("\x1B[35m${object}\x1B[0m");
  }

  static void cyanText(dynamic object) {
    if (verboseLogs) print("\x1B[36m${object}\x1B[0m");
  }

  static void whiteText(dynamic object) {
    if (verboseLogs) print("\x1B[37m${object}\x1B[0m");
  }

  static void whiteTextRedBg(dynamic object) {
    if (verboseLogs) print('\x1B[41m\x1B[37m${object}\x1B[0m');
  }

  static void whiteTextBlueBg(dynamic object) {
    if (verboseLogs) print('\x1B[44m\x1B[37m${object}\x1B[0m');
  }

  static void resetTextColors(dynamic object) {
    if (verboseLogs) print("\x1B[0m${object}\x1B[0m");
  }
}
