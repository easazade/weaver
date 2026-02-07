import '../models/profile.dart';

class ProfileApi {
  // Fake profile instances
  static final Profile _regularUserProfile = Profile(
    userId: 'user-1',
    orderIds: ['order-1', 'order-2'],
    favoriteShoeIds: ['shoe-1', 'shoe-2'],
    profileImageUrl: 'https://example.com/profile1.jpg',
  );

  static final Profile _adminUserProfile = Profile(
    userId: 'admin-1',
    orderIds: ['order-3', 'order-4', 'order-5'],
    favoriteShoeIds: ['shoe-1', 'shoe-3'],
    profileImageUrl: 'https://example.com/admin-profile.jpg',
  );

  /// Get profile by user ID
  Future<Profile?> getProfileByUserId(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (userId == 'user-1') {
      return _regularUserProfile;
    } else if (userId == 'admin-1') {
      return _adminUserProfile;
    }
    return null;
  }
}
