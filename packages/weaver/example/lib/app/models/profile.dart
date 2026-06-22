import 'package:dart_mappable/dart_mappable.dart';

part 'profile.mapper.dart';

@MappableClass()
class Profile with ProfileMappable {
  final String userId;
  final List<String> orderIds;
  final List<String> favoriteShoeIds;
  final String? profileImageUrl;

  Profile({
    required this.userId,
    this.orderIds = const [],
    this.favoriteShoeIds = const [],
    this.profileImageUrl,
  });
}
