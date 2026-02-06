import 'package:flutter/material.dart';

import '../cubits/admin_cubit.dart';
import '../cubits/user_cubit.dart';
import '../models/shoes.dart';
import '../di/di_setup.dart';
import '../widgets/primary_button.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late AdminCubit _adminCubit;
  late UserCubit _userCubit;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _adminCubit = weaver.get<AdminCubit>();
    _userCubit = weaver.get<UserCubit>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _addShoes() async {
    final price = double.tryParse(_priceController.text);

    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        price == null ||
        price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields with valid values'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final shoes = Shoes(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      price: price,
      imageUrl: _imageUrlController.text.isEmpty
          ? 'https://via.placeholder.com/150'
          : _imageUrlController.text,
    );

    try {
      await _adminCubit.addShoes(shoes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shoes added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Clear form
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _imageUrlController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add shoes: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_userCubit.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(
          child: Text('Access denied. Admin only.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Add Shoes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add New Shoes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                hintText: 'Enter shoes name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'Enter shoes description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                hintText: 'Enter price (e.g., 99.99)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
                border: OutlineInputBorder(),
                hintText: 'Enter image URL',
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Add Shoes',
              isLoading: _adminCubit.isLoading,
              onPressed: _addShoes,
            ),
          ],
        ),
      ),
    );
  }
}
