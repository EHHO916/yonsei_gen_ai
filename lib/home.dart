import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:table_calendar/table_calendar.dart';
import 'diary.dart';

class HomePage extends StatefulWidget {
  final GoogleSignInAccount? googleUser;

  HomePage({required this.googleUser});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // 기본 선택: 홈(가운데)

  final List<Widget> _pages = [
    ProfilePage(), // 왼쪽: 프로필
    HomeContent(), // 가운데: 홈
    ChatPage(),    // 오른쪽: 채팅
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "ParentCare",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF5D0074),
        elevation: 0,
        centerTitle: false, // 제목을 왼쪽 정렬
      ),
      body: Container(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.grey[700],
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          // 왼쪽: 프로필
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: '프로필',
          ),
          // 가운데: 홈
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: '홈',
          ),
          // 오른쪽: 채팅
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble, size: 30,),
            label: '채팅',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          // 사용자 환영 메시지
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "사용자님,",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "오늘도 ParentCare로\n어쩌구 저쩌구 뭐라고 하지",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 일기 쓰러 가기
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryInputPage(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "일기 쓰러 가기 >",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity, // 가로로 꽉 차게
                    padding: const EdgeInsets.all(12.0), // 내부 여백 설정
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // 회색 배경
                      borderRadius: BorderRadius.circular(8), // 둥근 모서리
                    ),
                    child: Text(
                      "육아일기를 쓰고 AI 육아 도우미의 피드백을 받아보세요!",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800], // 텍스트 진한 회색
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          // 달력
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "육아일기 / Todo-list 바로가기 >",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0), // 상자 외부 여백
                    padding: const EdgeInsets.all(10.0), // 상자 내부 여백
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12), // 모서리 둥글게 처리
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: DateTime.now(),
                      calendarFormat: CalendarFormat.month,
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                      ),
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("채팅 화면 구현 중입니다."),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("프로필 화면 구현 중입니다."),
    );
  }
}

class DiaryInputPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  final List<String> _aiSuggestions = [
    "아이와 함께 그림 그리기",
    "아이를 위한 간단한 요리 만들기",
    "하루 30분 산책하기"
  ];

  final List<String> _selectedToDoList = []; // 사용자가 선택한 To-Do List

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),
      appBar: AppBar(
        title: const Text(
          "오늘의 일기",
          style: TextStyle(color: Colors.white,)
        ),
        backgroundColor: const Color(0xFF5D0074),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // 뒤로 가기 버튼 아이콘 색상 설정
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 첫 번째 상자: 일기 작성 입력란
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "오늘의 일기",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      color: Colors.grey[200], // 배경색 설정
                      child: TextField(
                        controller: _controller,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          hintText: "오늘의 육아일기를 작성하세요...",
                          border: InputBorder.none, // TextField의 기본 외곽선 제거
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        ),
                        style: const TextStyle(
                          color: Colors.black, // 텍스트 색상
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 두 번째 상자: AI 피드백
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AI 피드백",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "오늘의 일기에 대한 AI 피드백이 이곳에 표시됩니다.",
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              ),

              // 세 번째 상자: AI 추천 To-Do List
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AI 추천 To-Do List",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _aiSuggestions.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          title: Text(
                            _aiSuggestions[index],
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: _selectedToDoList.contains(_aiSuggestions[index]),
                          onChanged: (bool? value) {
                            if (value == true) {
                              _selectedToDoList.add(_aiSuggestions[index]);
                            } else {
                              _selectedToDoList.remove(_aiSuggestions[index]);
                            }
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 일기 완성하기 버튼
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryHome(), // Diary 화면으로 이동
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D0074),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "일기 완성하러 가기",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
