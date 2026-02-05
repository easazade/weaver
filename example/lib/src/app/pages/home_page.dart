import 'package:example/src/app/models/shoes.dart';
import 'package:flutter/material.dart';

import '../api/user_api.dart';
import '../cubits/shoes_cubit.dart';
import '../cubits/user_cubit.dart';
import '../di.dart';
import '../widgets/shoe_item_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ShoesCubit _shoesCubit;
  late UserCubit _userCubit;
  late UserApi _userApi;

  @override
  void initState() {
    super.initState();
    _shoesCubit = weaver.get<ShoesCubit>();
    _userCubit = weaver.get<UserCubit>();
    _userApi = weaver.get<UserApi>();
    _loadShoes();
  }

  Future<void> _loadShoes() async {
    await _shoesCubit.loadShoes();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _buyShoes(Shoes shoes) async {
    final user = _userCubit.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _userApi.purchaseShoes(user.id, [shoes.id]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${shoes.name} added to your orders!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to purchase: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoes Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
            tooltip: 'Profile',
          ),
          if (_userCubit.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.of(context).pushNamed('/admin');
              },
              tooltip: 'Admin',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _userCubit.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _shoesCubit.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shoesCubit.shoes.isEmpty
          ? const Center(child: Text('No shoes available'))
          : RefreshIndicator(
              onRefresh: _loadShoes,
              child: ListView.builder(
                itemCount: _shoesCubit.shoes.length,
                itemBuilder: (context, index) {
                  final shoes = _shoesCubit.shoes[index];
                  return ShoeItemWidget(
                    shoes: shoes,
                    onBuy: () => _buyShoes(shoes),
                  );
                },
              ),
            ),
    );
  }
}
