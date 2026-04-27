import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lost_item.dart';

class ItemListTile extends StatelessWidget {
  final LostItem item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;

  const ItemListTile({
    super.key,
    required this.item,
    required this.onTap,
    this.onDelete,
    this.onApprove,
  });

  Future<void> _contactReporter(BuildContext context, LostItem item) async {
    final String phone = item.reporterPhone;
    
    if (phone.isNotEmpty) {
      String formattedPhone = phone;
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '62${formattedPhone.substring(1)}';
      }
      
      final Uri waUrl = Uri.parse('https://wa.me/$formattedPhone?text=Halo,%20saya%20menghubungi%20terkait%20laporan%20${Uri.encodeComponent(item.name)}%20di%20aplikasi%20Lost%20&%20Found%20TelU.');
      
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka aplikasi WhatsApp.')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nomor WhatsApp pelapor tidak tersedia.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color iconBgColor;
    Color iconColor;
    IconData iconData;

    if (item.status == 'pending') {
      iconBgColor = Colors.orange.shade50;
      iconColor = Colors.orange;
      iconData = Icons.hourglass_empty;
    } else if (item.type == 'hilang') {
      iconBgColor = Colors.red.shade50;
      iconColor = Colors.red;
      iconData = Icons.outbox_rounded;
    } else {
      iconBgColor = const Color(0xFFFFF8E1); // Light Amber
      iconColor = const Color(0xFFFFA000); // Amber
      iconData = Icons.move_to_inbox_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    iconData, 
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row (Badges)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.type == 'hilang' ? Colors.red.shade50 : const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.type == 'hilang' ? 'Barang Hilang' : 'Barang Temuan',
                              style: TextStyle(
                                color: item.type == 'hilang' ? Colors.red.shade700 : const Color(0xFFFF8F00),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (item.status == 'pending')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Pending',
                                style: TextStyle(color: Colors.orange.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (item.isResolved)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Selesai',
                                style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Title
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Location & Date
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            '${item.date.day}/${item.date.month}/${item.date.year}',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                      if (!item.isResolved) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _contactReporter(context, item),
                            icon: const Icon(Icons.chat, size: 14),
                            label: const Text('Hubungi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Trailing Actions
                if (onApprove != null || onDelete != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (onApprove != null)
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: onApprove,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(bottom: 8),
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: onDelete,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

