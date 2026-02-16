import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/item.dart';

class PublicFoundItemsScreen extends StatefulWidget {
  const PublicFoundItemsScreen({super.key});

  @override
  State<PublicFoundItemsScreen> createState() => _PublicFoundItemsScreenState();
}

class _PublicFoundItemsScreenState extends State<PublicFoundItemsScreen> {
  List<Item> _foundItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoundItems();
  }

  Future<void> _loadFoundItems() async {
    try {
      final authService = AuthService();
      final token = authService.getToken();
      if (token != null) {
        final api = ApiService();
        _foundItems = await api.getItems(token, type: 'found');
      } else {
        // For demo, show some mock data if no token
        _foundItems = [
          Item(
            id: 1,
            title: 'Sample Found Wallet',
            category: 'wallet',
            description: 'Black leather wallet found in library',
            locationFound: 'Library',
            campus: 'Main',
            type: 'found',
            status: 'Open',
            dateFound: DateTime.now().subtract(const Duration(days: 2)),
            userId: 1,
          ),
        ];
      }
    } catch (e) {
      // For demo, show some mock data if API fails
      _foundItems = [
        Item(
          id: 1,
          title: 'Sample Found Wallet',
          category: 'wallet',
          description: 'Black leather wallet found in library',
          locationFound: 'Library',
          campus: 'Main',
          type: 'found',
          status: 'Open',
          dateFound: DateTime.now().subtract(const Duration(days: 2)),
          userId: 1,
        ),
      ];
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Found Items')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _foundItems.isEmpty
          ? const Center(child: Text('No found items available'))
          : ListView.builder(
              itemCount: _foundItems.length,
              itemBuilder: (context, index) {
                final item = _foundItems[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: item.displayImageUrl != null
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
                    subtitle: Text('${item.category} - ${item.location}'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(item.title),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category: ${item.category}'),
                              Text('Location: ${item.location}'),
                              if (item.date != null)
                                Text(
                                  'Date: ${item.date!.toLocal().toString().split(' ')[0]}',
                                ),
                              if (item.description != null)
                                Text('Description: ${item.description}'),
                              if (item.distinguishingFeatures != null)
                                Text(
                                  'Features: ${item.distinguishingFeatures}',
                                ),
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
    );
  }
}
