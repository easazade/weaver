# weaver_builder

Code generation for [weaver](https://pub.dev/packages/weaver): scopes, switch scopes, named dependencies, and session extensions.

Add it as a **dev_dependency** next to `build_runner`, run `dart run build_runner build`, and use the annotations documented in the main [Weaver README](https://github.com/easazade/weaver#readme) (or the `weaver` / `flutter_weaver` package readme on pub.dev).

Flutter apps depend on **`flutter_weaver`** (which re-exports `weaver`); point `weaver_builder` at the same major/minor as your `weaver` / `flutter_weaver` version.
