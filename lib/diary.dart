import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryHome extends StatefulWidget {
  @override
  _DiaryHomeState createState() => _DiaryHomeState();
}

class _DiaryHomeState extends State<DiaryHome> {
  DateTime selectedDay = DateTime.now(); // 선택된 날짜
  DateTime focusedDay = DateTime.now(); // 화면에 보이는 달력 기준 날짜
  CalendarFormat calendarFormat = CalendarFormat.week; // 기본은 주간 보기

  // 날짜별 이모지 저장
  final Map<DateTime, String> emojiByDate = {};

  final Map<String, String> emotionEmojis = {
    'Angry': '😡',
    'Sad': '😢',
    'Tired': '😴',
    'Neutral': '😐',
    'Funny': '😂',
    'Inspired': '✨',
    'Happy': '😊',
  };

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
        child: Padding(
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
                      Navigator.pop(context); // 다이얼로그 닫기
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
                  Navigator.pop(context); // 다이얼로그 닫기
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
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
            Navigator.pop(context); // 뒤로 가기 버튼
          },
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: GestureDetector(
        onLongPress: toggleCalendarFormat, // 길게 누르면 포맷 전환
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 캘린더 부분
            Container(
              color: Colors.transparent, // 터치 가능한 배경
              child: TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: focusedDay, // 오늘 날짜가 속한 주를 기본으로 보여줌
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                onDaySelected: (newSelectedDay, newFocusedDay) {
                  setState(() {
                    selectedDay = newSelectedDay;
                    focusedDay = newFocusedDay; // 포커스를 새로운 날짜로 업데이트
                  });
                  showEmojiSelectionDialog(); // 날짜 클릭 시 이모지 선택 다이얼로그 호출
                },
                calendarFormat: calendarFormat, // 포맷 동적 변경
                availableCalendarFormats: const {
                  CalendarFormat.week: 'Week',
                  CalendarFormat.month: 'Month',
                },
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
                // 날짜에 따라 커스텀 표시
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    if (emojiByDate.containsKey(day)) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              emojiByDate[day]!,
                              style: const TextStyle(fontSize: 32),
                            ),
                            Text(
                              "${day.day}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }
                    return null; // 기본 스타일로 표시
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${day.day}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${day.day}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    "Content Area", // 이곳에 다른 콘텐츠 추가 가능
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}