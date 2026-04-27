import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class CloudinaryService {
  // ── ⚠️  ISI DENGAN KREDENSIAL CLOUDINARY ANDA ────────────
  // Daftar gratis di: https://cloudinary.com
  // Lalu buat Upload Preset dengan mode "Unsigned":
  //   Dashboard → Settings → Upload → Add upload preset
  // ── Konfigurasi Cloudinary ────────────────────────────────
  static const String _cloudName = 'dvpovj1oc';        // ✅ Cloud Name
  static const String _uploadPreset = 'Lost n Found';  // ✅ Upload Preset (Unsigned)

  static const String _baseUrl = 'https://api.cloudinary.com/v1_1';

  /// Upload gambar ke Cloudinary dari XFile (works on Android & Web).
  /// Mengembalikan URL aman (https) gambar yang sudah diupload.
  /// Melempar [Exception] jika gagal.
  static Future<String> uploadImage(XFile imageFile) async {
    final uri = Uri.parse('$_baseUrl/$_cloudName/image/upload');
    final bytes = await imageFile.readAsBytes();

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['secure_url'] as String;
    } else {
      final error = json.decode(response.body);
      throw Exception(
        'Cloudinary upload gagal: ${error['error']?['message'] ?? response.statusCode}',
      );
    }
  }
}
