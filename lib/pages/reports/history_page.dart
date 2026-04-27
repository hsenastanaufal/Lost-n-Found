import 'package:flutter/material.dart';
import '../../models/lost_item.dart';
import '../../services/firestore_service.dart';
import '../../widgets/item_list_tile.dart';
import 'item_detail_page.dart';

class HistoryPage extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  const HistoryPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final userEmail = currentUser['email'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFF9A0007)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                  child: Row(
                    children: [
                      if (Navigator.canPop(context))
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        )
                      else
                        const SizedBox(width: 16),
                      const Text(
                        'Riwayat Laporan Saya',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Expanded(
                  child: StreamBuilder<List<LostItem>>(
                    stream: FirestoreService.getUserItemsStream(userEmail),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.red));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                      }

                      final userItems = snapshot.data ?? [];

                      if (userItems.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('Belum ada riwayat laporan.',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: userItems.length,
                        itemBuilder: (context, index) {
                          final item = userItems[index];
                          return ItemListTile(
                            item: item,
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => ItemDetailPage(item: item, currentUser: currentUser)));
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
