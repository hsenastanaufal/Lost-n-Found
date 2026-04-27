import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/lost_item.dart';
import '../../services/firestore_service.dart';
import '../../services/cloudinary_service.dart';
import '../../widgets/item_list_tile.dart';
import '../reports/item_detail_page.dart';

class AdminPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const AdminPage({super.key, required this.currentUser});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile? _selectedImage;
  bool _isAddingItem = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) setState(() => _selectedImage = picked);
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

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isAddingItem = true);
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await CloudinaryService.uploadImage(_selectedImage!);
      }
      final newItem = LostItem(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.isEmpty ? 'Tidak ada deskripsi.' : _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        date: DateTime.now(),
        status: 'approved',
        type: 'hilang',
        reporterEmail: widget.currentUser['email'] ?? 'admin@telkomuniversity.ac.id',
        reporterPhone: widget.currentUser['phone'] ?? '',
        imageUrl: imageUrl,
      );
      await FirestoreService.addItem(newItem);
      if (!mounted) return;
      _nameController.clear();
      _locationController.clear();
      _descriptionController.clear();
      setState(() => _selectedImage = null);
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil ditambahkan!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingItem = false);
    }
  }

  Future<void> _deleteItem(String id) async {
    await FirestoreService.deleteItem(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil dihapus!')),
    );
  }

  Future<void> _approveItem(LostItem item) async {
    await FirestoreService.approveItem(item.id);

    await FirestoreService.sendNotification(
      userId: item.reporterEmail,
      title: 'Laporan Disetujui',
      message: 'Laporan Anda "${item.name}" telah disetujui dan sekarang tayang publik.',
      type: 'report_approved',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Laporan disetujui dan sekarang tayang publik!'), backgroundColor: Colors.green),
    );
  }

  void _editAnnouncement() {
    String current = '';
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (context) => StreamBuilder<String>(
        stream: FirestoreService.getAnnouncementStream(),
        builder: (ctx, snap) {
          if (ctrl.text.isEmpty && snap.hasData) ctrl.text = snap.data!;
          return AlertDialog(
            title: const Text('Edit Pusat Informasi'),
            content: TextField(
              controller: ctrl,
              decoration: const InputDecoration(hintText: 'Masukkan pengumuman baru...', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final nav = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  await FirestoreService.updateAnnouncement(ctrl.text);
                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Pusat Informasi berhasil diperbarui!'), backgroundColor: Colors.green),
                  );
                },
                child: const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('Admin Panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFD32F2F),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_notifications),
              tooltip: 'Edit Pusat Informasi',
              onPressed: _editAnnouncement,
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Kelola Laporan'),
              Tab(text: 'Tambah Data'),
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: 60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFF9A0007)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
            ),
            SafeArea(
              child: TabBarView(
                children: [
                  StreamBuilder<List<LostItem>>(
                    stream: FirestoreService.getItemsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.red));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final allItems = snapshot.data ?? [];
                      final pendingItems = allItems.where((i) => i.status == 'pending').toList();
                      final approvedItems = allItems.where((i) => i.status == 'approved').toList();

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (pendingItems.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Menunggu Persetujuan (${pendingItems.length})',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: pendingItems.length,
                                itemBuilder: (context, index) {
                                  final item = pendingItems[index];
                                  return ItemListTile(
                                    item: item,
                                    onTap: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => ItemDetailPage(item: item, currentUser: widget.currentUser))),
                                    onApprove: () => _approveItem(item),
                                    onDelete: () => _deleteItem(item.id),
                                  );
                                },
                              ),
                              const SizedBox(height: 32),
                              const Divider(),
                              const SizedBox(height: 16),
                            ],
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Laporan Aktif (Publik)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: pendingItems.isEmpty ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            approvedItems.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32.0),
                                      child: Text('Tidak ada data.', style: TextStyle(color: Colors.grey)),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: approvedItems.length,
                                    itemBuilder: (context, index) {
                                      final item = approvedItems[index];
                                      return ItemListTile(
                                        item: item,
                                        onTap: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => ItemDetailPage(item: item, currentUser: widget.currentUser))),
                                        onDelete: () => _deleteItem(item.id),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      );
                    },
                  ),

                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
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
                          const Text('Tambah Laporan Manual',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
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
                                      color: _selectedImage != null ? Colors.red.withValues(alpha: 0.05) : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: _selectedImage != null ? Colors.red : Colors.grey.shade300, width: 2),
                                    ),
                                    child: _selectedImage != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: kIsWeb
                                                ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                                                : Image.file(File(_selectedImage!.path), fit: BoxFit.cover))
                                        : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey.shade400),
                                              const SizedBox(height: 12),
                                              Text('Unggah Foto Barang', style: TextStyle(color: Colors.grey.shade600)),
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
                                    prefixIcon: Icon(Icons.inventory_2_outlined, color: Colors.grey.shade600),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 2)),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Nama barang tidak boleh kosong' : null,
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _locationController,
                                  decoration: InputDecoration(
                                    labelText: 'Lokasi Penemuan / Hilang',
                                    prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey.shade600),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 2)),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Lokasi tidak boleh kosong' : null,
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: 'Deskripsi (Opsional)',
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(bottom: 32.0),
                                      child: Icon(Icons.description_outlined, color: Colors.grey.shade600),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 2)),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      shadowColor: Colors.red.withValues(alpha: 0.5),
                                    ),
                                    onPressed: _isAddingItem ? null : _addItem,
                                    child: _isAddingItem
                                        ? const SizedBox(width: 24, height: 24,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                        : const Text('Tambah Data',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
