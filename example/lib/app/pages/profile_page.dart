import 'package:example/app/stores/profile_store.dart';
import 'package:example/crystalline_generated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'package:flutter_weaver/flutter_weaver.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RequireDependencies(
      weaver: weaver,
      dependencies: [DependencyKey(type: ProfileStore)],
      builder: (context, child, isReady) {
        if (!isReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profileStore = weaver.get<ProfileStore>();
        final user = SharedState.instance.user.value;

        return StoreBuilder(
          store: profileStore,
          builder: (context, store, _) {
            if (profileStore.profile.operation == Operation.read) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Profile'),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final profile = profileStore.profile.value;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Profile'),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShadCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...[
                              _ProfileRow(
                                label: 'Username',
                                value: user.username,
                              ),
                              const SizedBox(height: 12),
                              _ProfileRow(
                                label: 'Full Name',
                                value: user.fullName,
                              ),
                            ],
                            ...[
                              const SizedBox(height: 12),
                              _ProfileRow(
                                label: 'User ID',
                                value: profile.userId,
                              ),
                              const SizedBox(height: 12),
                              _ProfileRow(
                                label: 'Orders',
                                value: '${profile.orderIds.length}',
                              ),
                              const SizedBox(height: 12),
                              _ProfileRow(
                                label: 'Favorites',
                                value: '${profile.favoriteShoeIds.length}',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
