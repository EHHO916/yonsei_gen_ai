import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryHome extends StatefulWidget {
  @override
  _DiaryHomeState createState() => _DiaryHomeState();
}

class LinePainter extends CustomPainter {
  final double lineHeight;

  LinePainter({required this.lineHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]! // 줄 색상
      ..strokeWidth = 1.0; // 줄 두께

    for (double y = 0; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DiaryHomeState extends State<DiaryHome> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.week;

  final Map<DateTime, String> emojiByDate = {};
  final TextEditingController _textEditingController = TextEditingController();

  static const double lineHeight = 24.0; // 한 줄의 높이
  static const int visibleLines = 5; // 보이는 줄 수
  final double containerHeight = lineHeight * visibleLines; // 컨테이너 높이

  final List<Map<String, dynamic>> toDoList = [
    {"title": "산책하기", "done": false},
    {"title": "책 읽기", "done": false},
    {"title": "장 보기", "done": false},
    {"title": "운동하기", "done": false},
    {"title": "일기 쓰기", "done": false},
  ];

  final Map<String, String> emotionEmojis = {
    'Angry': '😡',
    'Sad': '😢',
    'Tired': '😴',
    'Neutral': '😐',
    'Funny': '😂',
    'Inspired': '✨',
    'Happy': '😊',
  };

  final ScrollController _contentScrollController = ScrollController(); // 스크롤 컨트롤러 추가

  @override
  void dispose() {
    _contentScrollController.dispose(); // 메모리 누수를 방지하기 위해 dispose
    super.dispose();
  }

  void toggleCalendarFormat() {
    setState(() {
      if (calendarFormat == CalendarFormat.week) {
        calendarFormat = CalendarFormat.month; // 한 달 보기로 변경
      } else {
        calendarFormat = CalendarFormat.week; // 주간 보기로 복구
      }
    });
    HapticFeedback.lightImpact(); // 햅틱 반응 추가
  }

  void showEmojiSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select an Emoji for ${selectedDay.toLocal().toIso8601String().substring(0, 10)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: emotionEmojis.entries
                    .map(
                      (entry) => GestureDetector(
                    onTap: () {
                      setState(() {
                        emojiByDate[selectedDay] = entry.value; // 선택한 이모지를 저장
                      });
                      Navigator.pop(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.value,
                          style: const TextStyle(fontSize: 40),
                        ),
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "닫기",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParentDiary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        controller: _contentScrollController,
        slivers: [
          // 캘린더 부분
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                onDaySelected: (newSelectedDay, newFocusedDay) {
                  setState(() {
                    selectedDay = newSelectedDay;
                    focusedDay = newFocusedDay;
                  });
                  showEmojiSelectionDialog();
                },
                calendarFormat: calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    calendarFormat = format;
                  });
                },
                availableCalendarFormats: const {
                  CalendarFormat.week: 'Week',
                  CalendarFormat.month: 'Month',
                },
                calendarStyle: const CalendarStyle(
                  cellMargin: EdgeInsets.symmetric(vertical: 8),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: true,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
          // 일기 및 To-Do List 부분
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "오늘의 일기",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: containerHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(double.infinity, containerHeight),
                          painter: LinePainter(lineHeight: lineHeight),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: _textEditingController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              hintText: '오늘 있었던 일을 기록해주세요',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "To-Do List",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: toDoList.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        title: Text(
                          toDoList[index]['title'],
                          style: TextStyle(
                            decoration: toDoList[index]['done']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: toDoList[index]['done'] ? Colors.grey : Colors.black,
                          ),
                        ),
                        value: toDoList[index]['done'],
                        onChanged: (value) {
                          setState(() {
                            toDoList[index]['done'] = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
          child: ElevatedButton(
            onPressed: () {
              // 저장 기능 추가 가능
              print("일기 및 To-Do List 저장");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A4DFF),
              padding: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "저장하기",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}