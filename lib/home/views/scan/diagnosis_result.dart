import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class DiagnosisResultPage extends StatefulWidget {
  final String? diagnosisId; // UUID di Supabase
  final File imageFile;
  final Map<String, dynamic> prediction;
  final String? description;
  final String? treatment;

  const DiagnosisResultPage({
    super.key,
    required this.diagnosisId,
    required this.imageFile,
    required this.prediction,
    required this.description,
    required this.treatment,
  });

  @override
  State<DiagnosisResultPage> createState() => _DiagnosisResultPageState();
}

class _DiagnosisResultPageState extends State<DiagnosisResultPage> {
  bool _isAskingAI = false;
  String? _aiAnswer;

  // ================== UPDATE NOTES DI SUPABASE (UUID) ==================
  Future<void> _updateNotesInSupabase(String notes) async {
    if (widget.diagnosisId == null) {
      debugPrint('❌ Diagnosis ID NULL, notes tidak bisa di-update.');
      return;
    }

    debugPrint('➡ Update notes untuk ID: ${widget.diagnosisId}');
    debugPrint('➡ Notes: $notes');

    try {
      final client = Supabase.instance.client;

      final result = await client
          .from('leaf_diagnoses')
          .update({'notes': notes})
          .eq('id', widget.diagnosisId!) // UUID di Supabase
          .select()
          .maybeSingle();

      debugPrint('✅ RESULT UPDATE NOTES: $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Penjelasan AI disimpan ke notes.')),
        );
      }
    } catch (e) {
      debugPrint('❌ ERROR UPDATE NOTES: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan notes: $e')),
        );
      }
    }
  }

  // ================== GEMINI: JELASKAN PENYAKIT & SIMPAN KE NOTES ==================
  Future<void> _explainWithGemini() async {
    final labelName = widget.prediction['label_name']?.toString() ?? '-';

    const geminiApiKey = String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: 'YOUR_GEMINI_API_KEY',
    );

    if (geminiApiKey == 'YOUR_GEMINI_API_KEY' || geminiApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'GEMINI_API_KEY belum diset. Gunakan --dart-define=GEMINI_API_KEY=...',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isAskingAI = true;
      _aiAnswer = null;
    });

    try {
      // Prompt hemat kuota, singkat 1 paragraf
      final prompt = """
Jelaskan penyakit daun kopi '$labelName' dalam 2–3 kalimat saja. Sertakan gejala utama dan saran penanganan sederhana untuk petani rumahan. Jawaban singkat, jelas, dan langsung ke inti.
""";

      const geminiModel = 'gemini-flash-latest';

      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey',
      );

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      });

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      String resultText;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        final parts =
            candidates?[0]?['content']?['parts'] as List<dynamic>? ?? [];
        final text = parts.map((p) => p['text'] ?? '').join('\n');
        resultText = text.isEmpty ? '(AI tidak memberikan jawaban)' : text;
      } else if (response.statusCode == 429) {
        // Kuota habis → fallback pakai deskripsi lokal
        resultText = """
Kuota Gemini habis. Berikut penjelasan singkat berdasarkan data aplikasi:

${widget.description ?? 'Tidak ada deskripsi.'}

Penanganan: ${widget.treatment ?? 'Tidak ada data penanganan.'}
""";

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Kuota Gemini habis — menggunakan penjelasan offline.'),
            ),
          );
        }
      } else {
        debugPrint('Gemini error: ${response.statusCode} - ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Gagal menghubungi Gemini: ${response.statusCode}'),
            ),
          );
        }
        return;
      }

      debugPrint('AI ANSWER: $resultText');

      // Set ke UI
      setState(() {
        _aiAnswer = resultText;
      });

      // SIMPAN KE SUPABASE (kolom notes)
      await _updateNotesInSupabase(resultText);
    } catch (e) {
      debugPrint('Gemini Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kesalahan saat memproses AI: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAskingAI = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelName = widget.prediction['label_name']?.toString() ?? '-';

    final conf = widget.prediction['confidence'];
    final confPercent =
        (conf is num ? (conf * 100.0) : 0.0).toStringAsFixed(2);

    final severity = widget.prediction['severity_percent'];
    final severityText =
        (severity is num ? severity.toStringAsFixed(2) : null);

    const brown = Color(0xFF6D4C41);
    const green = Color(0xFF27AE60);
    final bg = Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: brown,
        foregroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        title: const Text(
          'Hasil Diagnosis',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== KARTU GAMBAR & LABEL =====
              Card(
                elevation: 1.5,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    // Gambar + badge
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.file(
                            widget.imageFile,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.eco_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  labelName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.insights_rounded,
                                  size: 16,
                                  color: brown,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$confPercent%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: brown,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ringkasan Diagnosis',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Model mendeteksi daun sebagai "$labelName" dengan tingkat keyakinan $confPercent%.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ===== TINGKAT KEPARAHAN PENYAKIT =====
              if (severityText != null) ...[
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: brown,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tingkat Keparahan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          labelName == 'Healthy'
                              ? 'Daun dalam kondisi sehat, tidak ditemukan area kerusakan yang signifikan.'
                              : 'Perkiraan area daun yang sudah terdampak penyakit sekitar $severityText% dari keseluruhan daun.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ===== DESKRIPSI & PENANGANAN =====
              if (widget.description != null || widget.treatment != null) ...[
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.description != null) ...[
                          Row(
                            children: const [
                              Icon(
                                Icons.article_outlined,
                                size: 18,
                                color: brown,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Deskripsi Singkat',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (widget.treatment != null) ...[
                          Row(
                            children: const [
                              Icon(
                                Icons.medical_services_outlined,
                                size: 18,
                                color: green,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Saran Penanganan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.treatment!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ===== TOMBOL GEMINI =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAskingAI ? null : _explainWithGemini,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brown,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 1,
                  ),
                  icon: _isAskingAI
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isAskingAI
                        ? 'Meminta penjelasan AI...'
                        : 'Minta Penjelasan Singkat dari AI',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // ===== HASIL AI (NOTES) =====
              if (_aiAnswer != null) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.notes_outlined,
                              size: 18,
                              color: brown,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '(tersimpan sebagai notes)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _aiAnswer!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
