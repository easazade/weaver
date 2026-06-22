// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'profile.dart';

class ProfileMapper extends ClassMapperBase<Profile> {
  ProfileMapper._();

  static ProfileMapper? _instance;
  static ProfileMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProfileMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Profile';

  static String _$userId(Profile v) => v.userId;
  static const Field<Profile, String> _f$userId = Field('userId', _$userId);
  static List<String> _$orderIds(Profile v) => v.orderIds;
  static const Field<Profile, List<String>> _f$orderIds = Field(
    'orderIds',
    _$orderIds,
    opt: true,
    def: const [],
  );
  static List<String> _$favoriteShoeIds(Profile v) => v.favoriteShoeIds;
  static const Field<Profile, List<String>> _f$favoriteShoeIds = Field(
    'favoriteShoeIds',
    _$favoriteShoeIds,
    opt: true,
    def: const [],
  );
  static String? _$profileImageUrl(Profile v) => v.profileImageUrl;
  static const Field<Profile, String> _f$profileImageUrl = Field(
    'profileImageUrl',
    _$profileImageUrl,
    opt: true,
  );

  @override
  final MappableFields<Profile> fields = const {
    #userId: _f$userId,
    #orderIds: _f$orderIds,
    #favoriteShoeIds: _f$favoriteShoeIds,
    #profileImageUrl: _f$profileImageUrl,
  };

  static Profile _instantiate(DecodingData data) {
    return Profile(
      userId: data.dec(_f$userId),
      orderIds: data.dec(_f$orderIds),
      favoriteShoeIds: data.dec(_f$favoriteShoeIds),
      profileImageUrl: data.dec(_f$profileImageUrl),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Profile fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Profile>(map);
  }

  static Profile fromJson(String json) {
    return ensureInitialized().decodeJson<Profile>(json);
  }
}

mixin ProfileMappable {
  String toJson() {
    return ProfileMapper.ensureInitialized().encodeJson<Profile>(
      this as Profile,
    );
  }

  Map<String, dynamic> toMap() {
    return ProfileMapper.ensureInitialized().encodeMap<Profile>(
      this as Profile,
    );
  }

  ProfileCopyWith<Profile, Profile, Profile> get copyWith =>
      _ProfileCopyWithImpl<Profile, Profile>(
        this as Profile,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProfileMapper.ensureInitialized().stringifyValue(this as Profile);
  }

  @override
  bool operator ==(Object other) {
    return ProfileMapper.ensureInitialized().equalsValue(
      this as Profile,
      other,
    );
  }

  @override
  int get hashCode {
    return ProfileMapper.ensureInitialized().hashValue(this as Profile);
  }
}

extension ProfileValueCopy<$R, $Out> on ObjectCopyWith<$R, Profile, $Out> {
  ProfileCopyWith<$R, Profile, $Out> get $asProfile =>
      $base.as((v, t, t2) => _ProfileCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProfileCopyWith<$R, $In extends Profile, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get orderIds;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get favoriteShoeIds;
  $R call({
    String? userId,
    List<String>? orderIds,
    List<String>? favoriteShoeIds,
    String? profileImageUrl,
  });
  ProfileCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProfileCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Profile, $Out>
    implements ProfileCopyWith<$R, Profile, $Out> {
  _ProfileCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Profile> $mapper =
      ProfileMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get orderIds =>
      ListCopyWith(
        $value.orderIds,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(orderIds: v),
      );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get favoriteShoeIds => ListCopyWith(
    $value.favoriteShoeIds,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(favoriteShoeIds: v),
  );
  @override
  $R call({
    String? userId,
    List<String>? orderIds,
    List<String>? favoriteShoeIds,
    Object? profileImageUrl = $none,
  }) => $apply(
    FieldCopyWithData({
      if (userId != null) #userId: userId,
      if (orderIds != null) #orderIds: orderIds,
      if (favoriteShoeIds != null) #favoriteShoeIds: favoriteShoeIds,
      if (profileImageUrl != $none) #profileImageUrl: profileImageUrl,
    }),
  );
  @override
  Profile $make(CopyWithData data) => Profile(
    userId: data.get(#userId, or: $value.userId),
    orderIds: data.get(#orderIds, or: $value.orderIds),
    favoriteShoeIds: data.get(#favoriteShoeIds, or: $value.favoriteShoeIds),
    profileImageUrl: data.get(#profileImageUrl, or: $value.profileImageUrl),
  );

  @override
  ProfileCopyWith<$R2, Profile, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ProfileCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

