import 'dart:convert';
import 'dart:io';
import 'diagnosis_history_page.dart'; // sesuaikan path kalau beda folder
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ==== TAMBAHAN: import Supabase ====
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  bool _isLoading = false;
  Map<String, dynamic>? _predictionResult;

  // ====== KONFIGURASI SERVER (SharedPreferences) ======
  static const String _prefsKey = 'server_url';

  /// base URL server (tanpa /predict)
  String _serverBaseUrl = 'http://10.0.2.2:8000'; // default (emulator)

  String get _predictUrl => '$_serverBaseUrl/predict';

  @override
  void initState() {
    super.initState();
    _loadServerConfig();
  }

  Future<void> _loadServerConfig({bool showMessage = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);

    if (!mounted) return;

    setState(() {
      if (saved != null && saved.isNotEmpty) {
        _serverBaseUrl = saved;
      }
    });

    if (showMessage && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfigurasi server diperbarui')),
      );
    }
  }
  // ===================================================

  /// Detail penyakit: deskripsi & penanganan.
  /// SESUAIKAN dengan label_name dari labels.json di server.
  final Map<String, Map<String, String>> _diseaseDetails = {
    'Healthy': {
      'description':
          'Daun kopi dalam kondisi sehat, tidak ditemukan gejala penyakit yang signifikan.',
      'treatment':
          'Lanjutkan perawatan rutin: penyiraman teratur, pemupukan sesuai jadwal, dan monitoring berkala.'
    },
    'Miner': {
      'description':
          'Serangan leaf miner ditandai dengan pola garis berkelok pada daun akibat larva yang memakan jaringan daun.',
      'treatment':
          'Potong daun yang parah, gunakan insektisida selektif bila perlu, dan jaga kebersihan lingkungan tanaman.'
    },
    'Phoma': {
      'description':
          'Infeksi Phoma menyebabkan bercak cokelat kehitaman yang dapat meluas dan menyebabkan gugurnya daun.',
      'treatment':
          'Buang bagian tanaman yang terinfeksi, perbaiki drainase, hindari penyiraman berlebihan, dan gunakan fungisida bila disarankan.'
    },
    'Rust': {
      'description':
          'Penyakit karat daun (coffee leaf rust) ditandai bercak kuning/oranye di permukaan daun.',
      'treatment':
          'Buang daun yang terinfeksi, tingkatkan sirkulasi udara, gunakan fungisida sesuai anjuran, dan jaga kelembapan tidak terlalu tinggi.'
    },
  };

  // ====== FUNGSI SUPABASE: UPLOAD GAMBAR & SIMPAN RIWAYAT ======

  /// Upload gambar daun ke Supabase Storage (bucket: leaf-images)
  /// dan mengembalikan public URL untuk disimpan di DB.
  Future<String> _uploadLeafImageToSupabase(File file) async {
    final client = Supabase.instance.client;

    final fileName = 'leaf_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bytes = await file.readAsBytes();

    // upload binary ke bucket leaf-images
    await client.storage.from('leaf-images').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    // ambil public URL (atau pakai signed URL kalau mau lebih aman)
    final publicUrl = client.storage.from('leaf-images').getPublicUrl(fileName);

    return publicUrl;
  }

  /// Simpan hasil deteksi ke tabel leaf_diagnoses di Supabase.
  /// TIDAK pakai auth, jadi tidak ada user_id.
  Future<void> _saveDiagnosisToSupabase({
    required String imageUrl,
    required Map<String, dynamic> prediction,
  }) async {
    final client = Supabase.instance.client;

    await client.from('leaf_diagnoses').insert({
      'image_url': imageUrl,
      'label_index': prediction['label_index'],
      'label_name': prediction['label_name'],
      'confidence': prediction['confidence'],
      'probabilities': prediction['probabilities'],
      // kolom lain seperti device_name / notes bisa ditambah di sini kalau ada
    });
  }

  // ===============================================================

  Future<void> _openCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _predictionResult = null; // reset hasil lama
        });
        debugPrint('Image captured: ${image.path}');
        await _predictDisease(); // otomatis kirim ke API setelah ambil foto
      }
    } catch (e) {
      debugPrint('Error opening camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka kamera')),
        );
      }
    }
  }

  Future<void> _openGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _predictionResult = null; // reset hasil lama
        });
        debugPrint('Image selected: ${image.path}');
        await _predictDisease(); // otomatis kirim ke API setelah pilih galeri
      }
    } catch (e) {
      debugPrint('Error opening gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka galeri')),
        );
      }
    }
  }

  Future<void> _predictDisease() async {
    if (_selectedImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih gambar terlebih dahulu')),
        );
      }
      return;
    }

    if (_serverBaseUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server belum dikonfigurasi. Atur dari Dashboard.'),
          ),
        );
      }
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final uri = Uri.parse(_predictUrl);
      debugPrint('Mengirim ke: $_predictUrl');

      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'file', // HARUS sama dengan request.files["file"] di Flask
            _selectedImage!.path,
          ),
        );

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        debugPrint('Prediction result: $data');

        // ====== LANGKAH BARU: SIMPAN KE SUPABASE ======
        try {
          // 1. Upload gambar ke Supabase Storage
          final imageUrl = await _uploadLeafImageToSupabase(_selectedImage!);

          // 2. Insert hasil prediksi + image_url ke tabel leaf_diagnoses
          await _saveDiagnosisToSupabase(
            imageUrl: imageUrl,
            prediction: data,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hasil deteksi berhasil disimpan ke database.'),
              ),
            );
          }
        } catch (e) {
          debugPrint('Gagal menyimpan ke Supabase: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Deteksi berhasil, tapi gagal simpan ke database: $e'),
              ),
            );
          }
        }
        // ===============================================

        setState(() {
          _predictionResult = data;
        });
      } else {
        debugPrint(
            'Error from API: ${streamedResponse.statusCode} - $responseBody');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal memproses gambar. Kode: ${streamedResponse.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan saat deteksi')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prediction = _predictionResult;
    String? labelName;
    double? confidencePercent;
    String? description;
    String? treatment;

    if (prediction != null) {
      labelName = prediction['label_name']?.toString();
      final conf = prediction['confidence'];
      if (conf is num) {
        confidencePercent = conf * 100.0;
      }
      if (labelName != null && _diseaseDetails.containsKey(labelName)) {
        description = _diseaseDetails[labelName]!['description'];
        treatment = _diseaseDetails[labelName]!['treatment'];
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          top: true,
          bottom: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight + 50,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Disease Diagnosis',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Use Camera or Upload Photo',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Server: $_serverBaseUrl',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              onPressed: () =>
                                  _loadServerConfig(showMessage: true),
                              tooltip: 'Reload server dari pengaturan',
                            ),
                          ],
                        ),
                      ),

                      // Scan Leaf Card (Camera)
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Illustration
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5E6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/scan_camera.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Text and Button
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Scan Leaf',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Use Camera to diagnose\nthe Disease',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _openCamera,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5D4037),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Scan Here',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Upload File Card (Gallery)
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Text and Button
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Upload File',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Upload file from your device',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _openGallery,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5D4037),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Upload Here',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Illustration
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8EAF6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/upload_file.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Recently Added (placeholder)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DiagnosisHistoryPage(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recently Added',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'View More',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Preview selected image
                      if (_selectedImage != null)
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selected Image',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Loading indicator
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),

                      // Hasil diagnosis
                      if (prediction != null && labelName != null)
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Diagnosis Result',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Penyakit: $labelName',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (confidencePercent != null)
                                Text(
                                  'Akurasi: ${confidencePercent.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              const SizedBox(height: 12),
                              if (description != null) ...[
                                const Text(
                                  'Deskripsi:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              if (treatment != null) ...[
                                const Text(
                                  'Penanganan:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  treatment,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
