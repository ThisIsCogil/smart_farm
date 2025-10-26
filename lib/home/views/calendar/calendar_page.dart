import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Map<String, String>> dailyTasks = [
    {
      'title': 'Menyiram Tanaman',
      'subtitle': 'Catatan tambahan...',
    },
    {
      'title': 'Memberi Pupuk',
      'subtitle': 'Catatan tambahan...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Calendar Container
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              cellMargin: EdgeInsets.all(4),
              defaultTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              outsideTextStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFF6D4C3D),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF6D4C3D).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            headerStyle: HeaderStyle(
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
        
        // Daily Task Section
        Container(
          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
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
                    'Daily Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // Button tambah di header Daily Task
                  GestureDetector(
                    onTap: _showAddTaskDialog,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF6D4C3D),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Task List
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: dailyTasks.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFFAF8F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dailyTasks[index]['title']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                dailyTasks[index]['subtitle']!,
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
                              setState(() {
                                dailyTasks.removeAt(index);
                              });
                            }
                          },
                          itemBuilder: (context) => [
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
        
        // TAMBAHAN: Extra spacing agar halaman bisa discroll
        // Ini akan membuat konten lebih panjang sehingga scroll detection aktif
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
      ],
    );
  }

  void _showAddTaskDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Tambah Task Baru'),
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
              SizedBox(height: 12),
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    dailyTasks.add({
                      'title': titleController.text,
                      'subtitle': subtitleController.text.isEmpty
                          ? 'Catatan tambahan...'
                          : subtitleController.text,
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6D4C3D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Tambah', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}