import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/lost_item.dart';
import '../../services/firestore_service.dart';

class ItemDetailPage extends StatefulWidget {
  final LostItem item;
  final Map<String, dynamic> currentUser;

  const ItemDetailPage({super.key, required this.item, required this.currentUser});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late bool isResolved;

  @override
  void initState() {
    super.initState();
    isResolved = widget.item.isResolved;
  }

  Future<void> _markResolved() async {
    await FirestoreService.markAsResolved(widget.item.id);
    if (!mounted) return;
    setState(() => isResolved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Status barang telah diperbarui menjadi Selesai!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detail Barang', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: widget.item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.item.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator(color: Colors.red));
                          },
                          errorBuilder: (context, error, stack) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey.shade400),
                              Text('Gagal memuat foto', style: TextStyle(color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('Tidak ada foto', style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.item.type == 'hilang' ? Colors.red.shade100 : Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.item.type == 'hilang' ? 'Barang Hilang' : 'Barang Temuan',
                    style: TextStyle(
                      color: widget.item.type == 'hilang' ? Colors.red.shade900 : Colors.teal.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isResolved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Selesai (Dikembalikan)',
                      style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.location_on, 'Lokasi', widget.item.location),
                  const Divider(height: 32),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Tanggal Laporan',
                    '${widget.item.date.day}/${widget.item.date.month}/${widget.item.date.year}',
                  ),
                  const Divider(height: 32),
                  _buildDetailRow(Icons.person, 'Pelapor', widget.item.reporterEmail),
                  const Divider(height: 32),
                  _buildDetailRow(Icons.description, 'Deskripsi', widget.item.description),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (!isResolved)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final String phone = widget.item.reporterPhone;
                    
                    if (phone.isNotEmpty) {
                      String formattedPhone = phone;
                      if (formattedPhone.startsWith('0')) {
                        formattedPhone = '62${formattedPhone.substring(1)}';
                      }
                      
                      final Uri waUrl = Uri.parse('https://wa.me/$formattedPhone?text=Halo,%20saya%20menghubungi%20terkait%20laporan%20${Uri.encodeComponent(widget.item.name)}%20di%20aplikasi%20Lost%20&%20Found%20TelU.');
                      
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
                  },
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text(
                    'Hubungi Pelapor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            if (!isResolved)
              const SizedBox(height: 16),
            if (!isResolved && (widget.currentUser['isAdmin'] == true || widget.currentUser['email'] == widget.item.reporterEmail))
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _markResolved,
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  label: const Text(
                    'Tandai Sudah Selesai/Dikembalikan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.red, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
