import 'package:flutter_weaver/flutter_weaver.dart';

import 'api/admin_api.dart';
import 'api/shoes_api.dart';
import 'api/user_api.dart';
import 'cubits/admin_cubit.dart';
import 'cubits/login_cubit.dart';
import 'cubits/shoes_cubit.dart';
import 'cubits/user_cubit.dart';
import 'services/notification_service.dart';

// Export the global weaver instance
export 'package:flutter_weaver/flutter_weaver.dart'
    show weaver, inject, injectAsync;

/// Initialize and register all app dependencies
void setupAppDependencies() {
  // Register APIs (order matters - dependencies first)
  weaver.register(ShoesApi());
  weaver.register(UserApi(weaver.get<ShoesApi>()));
  weaver.register(AdminApi(weaver.get<ShoesApi>()));

  // Register Services
  weaver.register(NotificationService());

  // Register Cubits
  weaver.register(UserCubit(weaver.get<UserApi>()));
  weaver.register(ShoesCubit(weaver.get<ShoesApi>()));
  weaver.register(AdminCubit(weaver.get<AdminApi>()));
  weaver.register(LoginCubit(weaver.get<UserApi>(), weaver.get<UserCubit>()));
}
