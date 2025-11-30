import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  /// Task untuk tanggal yang sedang dipilih
  List<Map<String, dynamic>> dailyTasks = [];

  /// Map untuk memberi titik di kalender
  /// key = 'yyyy-MM-dd', value = jumlah task di tanggal itu
  Map<String, int> _tasksCountByDate = {};

  bool _isLoadingTasks = false;

  /// Realtime channel Supabase
  RealtimeChannel? _tasksChannel;

  /// Animasi reload kalender
  late final AnimationController _reloadController;
  bool _isReloadingCalendar = false;

  @override
  void initState() {
    super.initState();
    _reloadController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _loadMonthSummary(_focusedDay);
    _loadTasksForDay(_selectedDay);
    _setupRealtime();
  }

  @override
  void dispose() {
    _tasksChannel?.unsubscribe();
    _reloadController.dispose();
    super.dispose();
  }

  String _dateKey(DateTime day) =>
      DateFormat('yyyy-MM-dd').format(DateTime(day.year, day.month, day.day));

  /// Normalisasi semua tipe nilai tanggal (String/DateTime) ke 'yyyy-MM-dd'
  String _normalizeDateKey(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) {
      return DateFormat('yyyy-MM-dd').format(
        DateTime(value.year, value.month, value.day),
      );
    }
    final raw = value.toString();
    // Kalau format ISO (ada 'T'), parse dulu
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('yyyy-MM-dd').format(
        DateTime(dt.year, dt.month, dt.day),
      );
    } catch (_) {
      // fallback: ambil bagian pertama sebelum spasi
      return raw.split(' ').first;
    }
  }

  /// Setup realtime listener untuk tabel tasks
  void _setupRealtime() {
    final client = Supabase.instance.client;

    _tasksChannel = client
        .channel('public:tasks')
        // INSERT
        ..onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'tasks',
          callback: (payload) {
            final newRow = payload.newRecord;
            if (newRow == null) return;

            final dateStr = _normalizeDateKey(newRow['task_date']);
            if (dateStr.isEmpty) return;

            final selectedKey = _dateKey(_selectedDay);

            // Kalau task baru untuk tanggal yang sedang dilihat
            if (dateStr == selectedKey) {
              setState(() {
                final existingIndex =
                    dailyTasks.indexWhere((t) => t['id'] == newRow['id']);

                if (existingIndex == -1) {
                  dailyTasks.add(Map<String, dynamic>.from(newRow));
                } else {
                  // update kalau sudah ada
                  dailyTasks[existingIndex] = {
                    ...dailyTasks[existingIndex],
                    ...newRow,
                  };
                }
              });
            }

            // Recalculate ringkasan bulan supaya dot selalu up-to-date
            _loadMonthSummary(_focusedDay);
          },
        )
        // UPDATE
        ..onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'tasks',
          callback: (payload) {
            final newRow = payload.newRecord;
            if (newRow == null) return;

            final dateStr = _normalizeDateKey(newRow['task_date']);
            if (dateStr.isEmpty) return;

            final selectedKey = _dateKey(_selectedDay);

            if (dateStr == selectedKey) {
              final index =
                  dailyTasks.indexWhere((t) => t['id'] == newRow['id']);
              if (index != -1) {
                setState(() {
                  dailyTasks[index] = {
                    ...dailyTasks[index],
                    ...newRow,
                  };
                });
              }
            }
            // UPDATE tidak mengubah count, jadi tidak wajib panggil _loadMonthSummary
          },
        )
        // DELETE
        ..onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'tasks',
          callback: (payload) {
            final oldRow = payload.oldRecord;
            if (oldRow == null) return;

            final dateStr = _normalizeDateKey(oldRow['task_date']);
            if (dateStr.isEmpty) return;

            final selectedKey = _dateKey(_selectedDay);

            // Kalau task yang dihapus ada di tanggal yang sedang dibuka
            if (dateStr == selectedKey) {
              setState(() {
                dailyTasks.removeWhere((t) => t['id'] == oldRow['id']);
              });
            }

            // Recalculate ringkasan bulan supaya dot hilang kalau hari kosong
            _loadMonthSummary(_focusedDay);
          },
        )
        ..subscribe();
  }

  /// Ambil daftar tanggal dalam 1 bulan yang punya task
  Future<void> _loadMonthSummary(DateTime month) async {
    try {
      final client = Supabase.instance.client;

      final firstDay = DateTime(month.year, month.month, 1); // awal bulan
      final lastDay = DateTime(month.year, month.month + 1, 0); // akhir bulan

      final res = await client
          .from('tasks')
          .select('task_date')
          .gte('task_date', DateFormat('yyyy-MM-dd').format(firstDay))
          .lte('task_date', DateFormat('yyyy-MM-dd').format(lastDay));

      final Map<String, int> countMap = {};
      for (final row in res as List) {
        final raw = row['task_date'];
        final dateStr = _normalizeDateKey(raw);
        if (dateStr.isEmpty) continue;
        countMap[dateStr] = (countMap[dateStr] ?? 0) + 1;
      }

      setState(() {
        _tasksCountByDate = countMap;
      });
    } catch (e) {
      debugPrint('Gagal load ringkasan bulan: $e');
    }
  }

  Future<void> _loadTasksForDay(DateTime day) async {
    setState(() {
      _isLoadingTasks = true;
    });

    try {
      final client = Supabase.instance.client;
      final dateStr = _dateKey(day);

      final res = await client
          .from('tasks')
          .select()
          .eq('task_date', dateStr)
          .order('created_at', ascending: true);

      setState(() {
        dailyTasks = (res as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Gagal load tasks: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat task: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTasks = false;
        });
      }
    }
  }

  /// 🔄 Reload kalender + task harian dengan animasi
  Future<void> _reloadCalendar() async {
    if (_isReloadingCalendar) return;

    setState(() {
      _isReloadingCalendar = true;
    });
    _reloadController.repeat();

    try {
      await _loadMonthSummary(_focusedDay);
      await _loadTasksForDay(_selectedDay);
    } finally {
      _reloadController.stop();
      _reloadController.reset();
      if (mounted) {
        setState(() {
          _isReloadingCalendar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF6D4C3D);
    const softBrown = Color(0xFFFAF8F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          top: true,
          bottom: true,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 16),

              // ====== KARTU KALENDER: HEADER + RELOAD + TABLECALENDAR ======
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ==== HEADER DI DALAM CARD ====
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Kalender Tugas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: brown,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Lihat jadwal tugas dan aktivitas.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _isReloadingCalendar ? null : _reloadCalendar,
                          child: RotationTransition(
                            turns: _reloadController,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: brown,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: brown.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.refresh,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(color: Colors.grey[200], height: 1),
                    const SizedBox(height: 8),

                    // ==== TABLE CALENDAR ====
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = DateTime(
                            selectedDay.year,
                            selectedDay.month,
                            selectedDay.day,
                          );
                          _focusedDay = focusedDay;
                        });
                        _loadTasksForDay(selectedDay);
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                        _loadMonthSummary(focusedDay);
                      },
                      eventLoader: (day) {
                        final count = _tasksCountByDate[_dateKey(day)] ?? 0;
                        return List.filled(count, 'task');
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.isEmpty) return const SizedBox.shrink();
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: brown,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        cellMargin: const EdgeInsets.all(4),
                        defaultTextStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        weekendTextStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        outsideTextStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 15,
                        ),
                        todayDecoration: const BoxDecoration(
                          color: brown,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: brown.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true, // supaya teks bulan benar2 di tengah
                        titleTextStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: brown,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: Color(0xFF8B6F47),
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: Color(0xFF8B6F47),
                        ),
                        headerPadding: EdgeInsets.only(bottom: 8),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        weekendStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // === Daftar Task Harian ===
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Task (${DateFormat('dd MMM yyyy').format(_selectedDay)})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Checklist tugas.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _showAddTaskDialog,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: brown,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: brown.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_isLoadingTasks)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (dailyTasks.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: softBrown,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: brown,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Belum ada task untuk tanggal ini.\nTekan tombol + untuk menambahkan.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: brown,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dailyTasks.length,
                        itemBuilder: (context, index) {
                          final task = dailyTasks[index];
                          final title = task['title']?.toString() ?? '';
                          final note = task['note']?.toString() ??
                              'Catatan tambahan...';
                          final isDone = (task['is_done'] as bool?) ?? false;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: softBrown,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isDone,
                                  activeColor: brown,
                                  onChanged: (val) {
                                    _toggleTaskDone(task, index, val ?? false);
                                  },
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDone
                                              ? Colors.grey[500]
                                              : Colors.black87,
                                          decoration: isDone
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        note,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _deleteTask(task['id'], index);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline, size: 18),
                                          SizedBox(width: 8),
                                          Text('Hapus'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            ],
          ),
        ),
      ),
    );
  }

  // ====== ADD TASK DIALOG & AKSI TASK TETAP SAMA (boleh pakai versi modernmu) ======
  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();

    const primary = Colors.brown;
    const border = Color(0xFFE5E5E5);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.add_circle_outline, color: primary, size: 26),
                    SizedBox(width: 10),
                    Text(
                      'Tambah Task Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul Task',
                    labelStyle: const TextStyle(color: Colors.black54),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primary, width: 1.6),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subtitleController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Catatan (opsional)',
                    labelStyle: const TextStyle(color: Colors.black54),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primary, width: 1.6),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;

                        try {
                          final client = Supabase.instance.client;
                          final dateStr = _dateKey(_selectedDay);

                          final inserted = await client
                              .from('tasks')
                              .insert({
                                'title': titleController.text.trim(),
                                'note': subtitleController.text.trim().isEmpty
                                    ? null
                                    : subtitleController.text.trim(),
                                'task_date': dateStr,
                              })
                              .select()
                              .single();

                          setState(() {
                            dailyTasks.add(inserted);
                          });

                          Navigator.of(dialogContext).pop();
                        } catch (e) {
                          debugPrint('Gagal menambah task: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menambah task: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteTask(dynamic id, int index) async {
    if (id == null) {
      setState(() {
        dailyTasks.removeAt(index);
      });
      return;
    }

    try {
      final client = Supabase.instance.client;
      await client.from('tasks').delete().eq('id', id);

      setState(() {
        dailyTasks.removeAt(index);
      });
    } catch (e) {
      debugPrint('Gagal menghapus task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus task: $e')),
        );
      }
    }
  }

  Future<void> _toggleTaskDone(
      Map<String, dynamic> task, int index, bool newValue) async {
    final id = task['id'];
    if (id == null) return;

    try {
      final client = Supabase.instance.client;
      await client.from('tasks').update({'is_done': newValue}).eq('id', id);

      setState(() {
        dailyTasks[index] = {
          ...dailyTasks[index],
          'is_done': newValue,
        };
      });
    } catch (e) {
      debugPrint('Gagal update status task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status task: $e')),
        );
      }
    }
  }
}
