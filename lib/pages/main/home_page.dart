import 'package:flutter/material.dart';
import '../../models/lost_item.dart';
import '../../services/firestore_service.dart';
import '../../widgets/menu_card.dart';
import '../reports/lost_items_page.dart';
import '../admin/admin_page.dart';
import '../reports/report_form_page.dart';
import '../reports/history_page.dart';
import '../reports/item_detail_page.dart';
import 'notification_page.dart';
import '../../models/app_notification.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  const HomePage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = currentUser['isAdmin'] ?? false;
    final String userName = currentUser['name'] ?? 'TelUtizen';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Gradient Header
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 60),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD32F2F), Color(0xFF9A0007)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                                ],
                              ),
                              child: Image.asset('assets/cropped-logo_telkom_university.png', height: 35),
                            ),
                            if (isAdmin)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('ADMIN',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text('Halo, $userName! 👋',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text('Pusat Kehilangan & Penemuan\nTelkom University',
                            style: TextStyle(fontSize: 15, color: Colors.white70, height: 1.4)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -20,
                  right: -50,
                  child: Container(width: 150, height: 150,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1))),
                ),
                Positioned(
                  bottom: -30,
                  left: -30,
                  child: Container(width: 120, height: 120,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1))),
                ),
              ],
            ),

            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.12), spreadRadius: 2, blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.campaign_rounded, color: Colors.red.shade700, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pusat Informasi',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900)),
                          const SizedBox(height: 4),
                          StreamBuilder<String>(
                            stream: FirestoreService.getAnnouncementStream(),
                            builder: (context, snapshot) {
                              final text = snapshot.data ?? 'Selamat datang di Lost & Found TelU.';
                              return Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade600));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Menu Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.05,
                children: [
                  MenuCard(
                    title: 'Papan\nLaporan',
                    icon: Icons.list_alt_rounded,
                    color: const Color(0xFFF57C00),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LostItemsPage(currentUser: currentUser))),
                  ),
                  MenuCard(
                    title: 'Lapor\nKehilangan',
                    icon: Icons.search_off_rounded,
                    color: const Color(0xFFD32F2F),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ReportFormPage(currentUser: currentUser, reportType: 'hilang'))),
                  ),
                  MenuCard(
                    title: 'Lapor\nTemuan',
                    icon: Icons.inventory_2_rounded,
                    color: const Color(0xFFFFA000), // Amber/Gold
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ReportFormPage(currentUser: currentUser, reportType: 'ditemukan'))),
                  ),
                  MenuCard(
                    title: 'Riwayat\nSaya',
                    icon: Icons.history_rounded,
                    color: const Color(0xFF7B1FA2),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => HistoryPage(currentUser: currentUser))),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Recent Items — Firestore StreamBuilder
            StreamBuilder<List<LostItem>>(
              stream: FirestoreService.getItemsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }
                final displayItems = snapshot.data!
                    .where((item) => item.status == 'approved')
                    .take(5)
                    .toList();

                if (displayItems.isEmpty) return const SizedBox.shrink();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Laporan Terbaru',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => LostItemsPage(currentUser: currentUser))),
                            child: const Text('Lihat Semua', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: displayItems.length,
                        itemBuilder: (context, index) {
                          final item = displayItems[index];
                          final bool isHilang = item.type == 'hilang';
                          return GestureDetector(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => ItemDetailPage(item: item, currentUser: currentUser))),
                            child: Container(
                              width: 160,
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 12, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Item Image
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      ),
                                      child: item.imageUrl != null
                                          ? ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                              child: Image.network(
                                                item.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stack) => Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                                              ),
                                            )
                                          : Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade300, size: 32),
                                    ),
                                  ),
                                  // Item Info
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isHilang ? Colors.pink.shade50 : const Color(0xFFFFF8E1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              isHilang ? 'Dicari' : 'Ditemukan',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: isHilang ? Colors.pink.shade700 : const Color(0xFFFF8F00),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            item.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on, size: 10, color: Colors.grey.shade500),
                                              const SizedBox(width: 2),
                                              Expanded(
                                                child: Text(
                                                  item.location,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AdminPage(currentUser: currentUser))),
              backgroundColor: Colors.red,
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
              label: const Text('Panel Admin', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}
