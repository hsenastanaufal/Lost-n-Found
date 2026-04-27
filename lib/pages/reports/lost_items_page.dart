import 'package:flutter/material.dart';
import '../../models/lost_item.dart';
import '../../services/firestore_service.dart';
import '../../widgets/item_list_tile.dart';
import 'item_detail_page.dart';

class LostItemsPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const LostItemsPage({super.key, required this.currentUser});

  @override
  State<LostItemsPage> createState() => _LostItemsPageState();
}

class _LostItemsPageState extends State<LostItemsPage> {
  String _searchQuery = '';
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          Container(
            height: 180,
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
                  padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Papan Laporan Publik',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.12), spreadRadius: 1, blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Cari barang atau lokasi...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Barang Hilang', 'hilang'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Temuan', 'ditemukan'),
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<List<LostItem>>(
                    stream: FirestoreService.getItemsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.red));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                      }

                      final allItems = snapshot.data ?? [];
                      final items = allItems.where((item) {
                        final isApproved = item.status == 'approved';
                        final matchesSearch =
                            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            item.location.toLowerCase().contains(_searchQuery.toLowerCase());
                        final matchesType = _filterType == 'all' || item.type == _filterType;
                        return isApproved && matchesSearch && matchesType;
                      }).toList();

                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('Tidak ada barang yang sesuai.',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ItemListTile(
                            item: item,
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => ItemDetailPage(item: item, currentUser: widget.currentUser)));
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    final Color selectedColor = value == 'hilang' || value == 'all' ? Colors.red : const Color(0xFFFFA000);
    final Color bgSelectedColor = value == 'hilang' || value == 'all' ? Colors.red.shade50 : const Color(0xFFFFF8E1);
    
    return GestureDetector(
      onTap: () => setState(() => _filterType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? bgSelectedColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? selectedColor : Colors.grey.shade300, width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? selectedColor : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13)),
      ),
    );
  }
}
