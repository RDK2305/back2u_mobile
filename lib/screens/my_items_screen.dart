import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/item.dart';
import '../config/routes.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  List<Item> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final token = authService.getToken();
      if (token != null) {
        final api = ApiService();
        final items = await api.getItems(token, type: 'lost');
        final authProvider = Get.find<AuthProvider>();
        final currentUser = authProvider.currentUser.value;
        if (currentUser != null) {
          setState(() {
            _items = items
                .where((item) => item.userId == currentUser.id)
                .toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to load items: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Lost Items')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('You haven\'t reported any lost items'))
          : RefreshIndicator(
              onRefresh: _loadItems,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading:
                          item.displayImageUrl != null
                          ? Image.network(
                              item.displayImageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.category} - ${item.dateLost?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                      ),
                      trailing: Text(item.status),
                      onTap: () {
                        // Show item details
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(item.title),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.description != null)
                                  Text('Description: ${item.description}'),
                                Text('Location: ${item.locationFound}'),
                                if (item.distinguishingFeatures != null)
                                  Text(
                                    'Features: ${item.distinguishingFeatures}',
                                  ),
                                Text('Status: ${item.status}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.reportLost),
        child: const Icon(Icons.add),
      ),
    );
  }
}
