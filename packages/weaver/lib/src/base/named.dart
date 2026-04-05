import 'package:weaver/weaver.dart';

/// A class that contains the code generated named
/// dependency objects from @[NamedDependency] annotation.
class WeaverNamed {
  final Weaver weaverInstance;

  /// Creates a [WeaverNamed] wrapper for [weaverInstance].
  ///
  /// Normally use [Weaver.named] instead of calling this constructor directly.
  WeaverNamed({required this.weaverInstance});
}
