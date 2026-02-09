import 'package:analyzer/dart/element/element.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
import 'package:weaver_builder/src/type_checkers.dart';

void writeSessions({required StringBuffer buffer, required LibraryElement library}) {
  for (final classElement in library.classes) {
    if (!weaverSessionTypeChecker.hasAnnotationOfExact(classElement)) continue;

    // checkForDuplicateSessionNames(library.classes);
    final annotation = weaverSessionTypeChecker.firstAnnotationOfExact(classElement);
    final reader = ConstantReader(annotation);
    final rawSessionName = reader.read('name').stringValue;
    final sessionName = rawSessionName.replaceAll('Session', '').replaceAll('session', '').replaceAll(' ', '');

    if (sessionName.isEmpty) {
      throw InvalidGenerationSource('Session name "$rawSessionName" is invalid, nor can it be "session" or "Session"');
    }
    final sessionClassName = '${sessionName.pascalCase}OnWeaver';

    final sessionExtensionGetterName = '${sessionName.camelCase}Session';

    buffer.writeln('''
        class $sessionClassName {
          final Weaver weaverInstance;
          $sessionClassName(this.weaverInstance);

          /// Registers given [instance] of object under given [name] under session: "$sessionName" 
          void register<T extends Object>(final T instance, {final String? name}) {
            weaverInstance.register<T>(instance, name: name, session: '$sessionName');
          }

          /// Removes all dependency objects registered under given [session] name.
          void clear(){
            weaverInstance.clearSession('$sessionName');
          }
        }
      ''');

    buffer.writeln('''
        extension Session${sessionClassName}X on Weaver{
          $sessionClassName get $sessionExtensionGetterName => $sessionClassName(this);
        }
      ''');
  }
}
