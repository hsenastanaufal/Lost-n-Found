import 'package:flutter/material.dart';
import '../../models/lost_item.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const ProfilePage({super.key, required this.currentUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String email = currentUser['email'] ?? '';
    final String name = currentUser['name'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 280,
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
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Profil Saya',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade900.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // User Info
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: StreamBuilder<List<LostItem>>(
                      stream: FirestoreService.getUserItemsStream(email),
                      builder: (context, snapshot) {
                        final userItems = snapshot.data ?? [];
                        final totalReported = userItems.length;
                        final totalResolved = userItems.where((i) => i.isResolved).length;
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                spreadRadius: 1,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Total Laporan', totalReported.toString(), Colors.blue.shade700, Icons.assignment_outlined),
                              Container(width: 1, height: 40, color: Colors.grey.shade200),
                              _buildStatItem('Telah Selesai', totalResolved.toString(), Colors.green.shade700, Icons.check_circle_outline),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Informasi Pribadi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.red),
                                onPressed: _editProfile,
                              )
                            ],
                          ),
                          const Divider(),
                          _buildInfoRow(Icons.account_balance_outlined, 'Fakultas', currentUser['fakultas'] ?? '-'),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.school_outlined, 'Jurusan', currentUser['jurusan'] ?? '-'),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.phone_outlined, 'No WhatsApp', currentUser['phone'] ?? '-'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Menu Items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        _buildMenuTile(Icons.help_outline, 'Bantuan & Dukungan'),
                        const SizedBox(height: 48),
                        
                        // Modern Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _logout(context),
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Keluar',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
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

  Widget _buildMenuTile(IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  void _editProfile() {
    final nameController = TextEditingController(text: currentUser['name']);
    final fakultasController = TextEditingController(text: currentUser['fakultas']);
    final jurusanController = TextEditingController(text: currentUser['jurusan']);
    final phoneController = TextEditingController(text: currentUser['phone']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                ),
                TextField(
                  controller: fakultasController,
                  decoration: const InputDecoration(labelText: 'Fakultas'),
                ),
                TextField(
                  controller: jurusanController,
                  decoration: const InputDecoration(labelText: 'Jurusan'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'No WhatsApp'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final uid = currentUser['uid'] as String? ?? '';
                if (uid.isNotEmpty) {
                  await FirestoreService.updateUser(uid, {
                    'name': nameController.text.trim(),
                    'fakultas': fakultasController.text.trim(),
                    'jurusan': jurusanController.text.trim(),
                    'phone': phoneController.text.trim(),
                  });

                  // Kirim notifikasi konfirmasi update profil
                  await FirestoreService.sendNotification(
                    userId: currentUser['email'] ?? '',
                    title: 'Profil Diperbarui',
                    message: 'Profil Anda telah berhasil diperbarui.',
                    type: 'profile_update',
                  );
                }
                setState(() {
                  currentUser['name'] = nameController.text;
                  currentUser['fakultas'] = fakultasController.text;
                  currentUser['jurusan'] = jurusanController.text;
                  currentUser['phone'] = phoneController.text;
                });
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

