import 'package:example/app/models/shoe.dart';
import 'package:example/app/stores/home_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';
import 'package:flutter_weaver/flutter_weaver.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RequireDependencies(
      weaver: weaver,
      dependencies: [DependencyKey(type: HomeStore)],
      builder: (context, child, isReady) {
        if (!isReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final homeStore = weaver.get<HomeStore>();
        return StoreBuilder(
          store: homeStore,
          builder: (context, store, child) {
            if (homeStore.shoes.operation == Operation.read) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (homeStore.shoes.hasFailure) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Shoes'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                    ),
                  ],
                ),
                body: Center(
                  child: Text('Error: ${homeStore.shoes.failure.message}'),
                ),
              );
            }

            final shoes = homeStore.shoes.value ?? [];

            return Scaffold(
              appBar: AppBar(
                title: const Text('Shoes'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/profile');
                    },
                  ),
                ],
              ),
              body: shoes.isEmpty
                  ? const Center(child: Text('No shoes available'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: shoes.length,
                      itemBuilder: (context, index) {
                        final shoe = shoes[index];
                        return _ShoeCard(shoe: shoe);
                      },
                    ),
            );
          },
        );
      },
    );
  }
}

class _ShoeCard extends StatelessWidget {
  final Data<Shoe> shoe;

  const _ShoeCard({required this.shoe});

  @override
  Widget build(BuildContext context) {
    return WhenData(
      data: shoe,
      onValue: (context, data) {
        final shoe = data.value;
        return ShadCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: shoe.imageUrls.isNotEmpty
                      ? Image.network(
                          shoe.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.image, size: 48),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(Icons.shopping_bag, size: 48),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shoe.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shoe.brand,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${shoe.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
