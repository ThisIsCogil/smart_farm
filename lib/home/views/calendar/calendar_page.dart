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

class _CalendarScreenState extends State<CalendarScreen> {
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

  @override
  void initState() {
    super.initState();
    _loadMonthSummary(_focusedDay);
    _loadTasksForDay(_selectedDay);
  }

  String _dateKey(DateTime day) =>
      DateFormat('yyyy-MM-dd').format(DateTime(day.year, day.month, day.day));

  /// Ambil daftar tanggal dalam 1 bulan yang punya task
  Future<void> _loadMonthSummary(DateTime month) async {
    try {
      final client = Supabase.instance.client;

      final firstDay =
          DateTime(month.year, month.month, 1); // awal bulan
      final lastDay =
          DateTime(month.year, month.month + 1, 0); // akhir bulan

      final res = await client
          .from('tasks')
          .select('task_date')
          .gte('task_date', DateFormat('yyyy-MM-dd').format(firstDay))
          .lte('task_date', DateFormat('yyyy-MM-dd').format(lastDay));

      final Map<String, int> countMap = {};
      for (final row in res as List) {
        final dateStr = row['task_date']?.toString();
        if (dateStr == null) continue;
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

  @override
  Widget build(BuildContext context) {
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
              // === Kalender ===
              Container(
                margin: const EdgeInsets.all(16),
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
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                    // TableCalendar butuh list, isi boleh apa saja
                    return List.filled(count, 'task');
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return const SizedBox.shrink();
                      return Positioned(
                        bottom: 0,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6D4C3D),
                            borderRadius: BorderRadius.circular(3),
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
                      color: Color(0xFF6D4C3D),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: const Color(0xFF6D4C3D).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: false,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6D4C3D),
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Color(0xFF8B6F47),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Color(0xFF8B6F47),
                    ),
                    headerPadding: EdgeInsets.only(bottom: 16),
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
              ),

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
                        Text(
                          'Daily Task (${DateFormat('dd MMM yyyy').format(_selectedDay)})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showAddTaskDialog,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF6D4C3D),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Belum ada task untuk tanggal ini.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
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
                              color: const Color(0xFFFAF8F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isDone,
                                  activeColor: const Color(0xFF6D4C3D),
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
                                          color: Colors.grey[600],
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

              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Tambah Task Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Task',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleController,
                decoration: InputDecoration(
                  labelText: 'Catatan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;

                try {
                  final client = Supabase.instance.client;
                  final dateStr = _dateKey(_selectedDay);

                  final inserted = await client
                      .from('tasks')
                      .insert({
                        'title': titleController.text,
                        'note': subtitleController.text.isEmpty
                            ? null
                            : subtitleController.text,
                        'task_date': dateStr,
                      })
                      .select()
                      .single();

                  setState(() {
                    dailyTasks.add(inserted);
                    final key = dateStr;
                    _tasksCountByDate[key] = ( _tasksCountByDate[key] ?? 0) + 1;
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
                backgroundColor: const Color(0xFF6D4C3D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  const Text('Tambah', style: TextStyle(color: Colors.white)),
            ),
          ],
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

      final dateStr = _dateKey(_selectedDay);
      setState(() {
        dailyTasks.removeAt(index);
        final current = _tasksCountByDate[dateStr] ?? 0;
        if (current <= 1) {
          _tasksCountByDate.remove(dateStr);
        } else {
          _tasksCountByDate[dateStr] = current - 1;
        }
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
      await client
          .from('tasks')
          .update({'is_done': newValue})
          .eq('id', id);

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
