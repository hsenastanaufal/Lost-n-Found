import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/lost_item.dart';
import '../../services/firestore_service.dart';
import '../../services/cloudinary_service.dart';

class ReportFormPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final String reportType; // 'hilang' or 'ditemukan'

  const ReportFormPage({
    super.key,
    required this.currentUser,
    required this.reportType,
  });

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  XFile? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() => _selectedImage = picked);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih Sumber Foto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(Icons.camera_alt_outlined, 'Kamera', () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }),
                _buildSourceOption(Icons.photo_library_outlined, 'Galeri', () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.red, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      if (_selectedImage != null) {
        imageUrl = await CloudinaryService.uploadImage(_selectedImage!);
      }

      final isHilang = widget.reportType == 'hilang';
      final prefix = isHilang ? 'DICARI' : 'DITEMUKAN';

      final newItem = LostItem(
        id: '',
        name: _nameController.text.trim(),
        description: '$prefix: ${_descriptionController.text.isEmpty ? 'Tidak ada deskripsi' : _descriptionController.text.trim()}',
        location: _locationController.text.trim(),
        date: DateTime.now(),
        status: 'pending',
        type: widget.reportType,
        reporterEmail: widget.currentUser['email'] ?? '',
        reporterPhone: widget.currentUser['phone'] ?? '',
        imageUrl: imageUrl,
      );

      await FirestoreService.addItem(newItem);

      await FirestoreService.notifyAdmins(
        title: 'Laporan Baru Masuk',
        message: 'Ada laporan ${widget.reportType} baru: ${newItem.name}. Mohon segera tinjau.',
        type: 'new_report',
      );

      if (!mounted) return;
      _nameController.clear();
      _locationController.clear();
      _descriptionController.clear();
      setState(() => _selectedImage = null);
      FocusScope.of(context).unfocus();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Laporan Berhasil'),
          content: const Text(
              'Terima kasih atas laporan Anda. Laporan sedang menunggu persetujuan Admin sebelum dipublikasikan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Tutup'),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim laporan: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHilang = widget.reportType == 'hilang';
    final themeColor = isHilang ? Colors.red : Colors.teal;
    final gradientColors = isHilang
        ? [const Color(0xFFD32F2F), const Color(0xFF9A0007)]
        : [const Color(0xFF00796B), const Color(0xFF004D40)]; 
    final title = isHilang ? 'Lapor Kehilangan' : 'Lapor Temuan';
    final subtitle = isHilang
        ? 'Isi formulir ini jika Anda kehilangan barang di area kampus.'
        : 'Isi formulir ini jika Anda menemukan barang milik orang lain.';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: gradientColors[0],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.12), spreadRadius: 1, blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Detail Barang',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: themeColor)),
                    const SizedBox(height: 8),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _selectedImage != null ? themeColor.withValues(alpha: 0.05) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedImage != null ? themeColor : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: kIsWeb
                                          ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                                          : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey.shade400),
                                        const SizedBox(height: 12),
                                        Text('Unggah Foto Barang',
                                            style: TextStyle(color: Colors.grey.shade600)),
                                      ],
                                    ),
                            ),
                          ),
                          if (_selectedImage != null)
                            TextButton.icon(
                              onPressed: () => setState(() => _selectedImage = null),
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              label: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                            ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nama Barang',
                              hintText: 'Cth: Dompet Hitam',
                              prefixIcon: Icon(Icons.inventory_2_outlined, color: Colors.grey.shade600),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: themeColor, width: 2)),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Nama barang tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: isHilang ? 'Lokasi Hilang Terakhir' : 'Lokasi Penemuan',
                              hintText: 'Cth: TULT Lantai 3',
                              prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey.shade600),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: themeColor, width: 2)),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Lokasi tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Deskripsi / Ciri-ciri',
                              hintText: 'Jelaskan secara detail...',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 48.0),
                                child: Icon(Icons.description_outlined, color: Colors.grey.shade600),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: themeColor, width: 2)),
                            ),
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                shadowColor: themeColor.withValues(alpha: 0.5),
                              ),
                              onPressed: _isLoading ? null : _submitReport,
                              child: _isLoading
                                  ? const SizedBox(width: 24, height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : Text(
                                      isHilang ? 'Kirim Laporan Kehilangan' : 'Kirim Laporan Temuan',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
