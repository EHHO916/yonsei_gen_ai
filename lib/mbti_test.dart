import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CombinedScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MBTI TEST',
          style: TextStyle(
            color: Color(0xFF090A0A),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white,
                    Color(0xFFF8E1E7),
                    Color(0xFFD1C4E9),
                    Color(0xFFE8EAF6),
                  ],
                  stops: [0.0, 0.5, 0.75, 0.9, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), // 둥근 모서리 설정
                    child: ValueListenableBuilder<double>(
                      valueListenable: progressNotifier,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.grey[300],
                          color: const Color(0xFF6A4DFF),
                          minHeight: 6, // 높이 조정
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Expanded(
                  child: MBTITestScreen(cardHeight: 300),
                ),
                const SizedBox(height: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);

class MBTITestScreen extends StatefulWidget {
  final double cardHeight;

  const MBTITestScreen({Key? key, this.cardHeight = 300.0}) : super(key: key);

  @override
  _MBTITestScreenState createState() => _MBTITestScreenState();
}

class _MBTITestScreenState extends State<MBTITestScreen> {
  List<String> questions = [];
  int currentIndex = 0;
  List<String?> selectedAnswers = []; // 각 질문에 대한 선택된 답변을 저장하는 리스트

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    progressNotifier.value = 0.0; // 초기화 시 인디케이터를 0으로 설정
  }

  Future<void> _loadQuestions() async {
    final fileContent = await rootBundle.loadString('assets/mbtiQ/mbti_q.txt');
    setState(() {
      questions = fileContent.split('\n').where((line) => line.isNotEmpty).toList();
      selectedAnswers = List<String?>.filled(questions.length, null); // 질문 개수와 동일한 길이로 초기화
    });
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        progressNotifier.value = (currentIndex + 1) / questions.length;
      });
    }
  }

  void _previousQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        progressNotifier.value = (currentIndex + 1) / questions.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: widget.cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  questions.isNotEmpty ? questions[currentIndex] : 'Loading...',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildOption("아주 그렇다", Colors.green[300]!)),
                Expanded(child: _buildOption("그렇다", Colors.green[200]!)),
                Expanded(child: _buildOption("보통", Colors.grey)),
                Expanded(child: _buildOption("아니다", Colors.purple[200]!)),
                Expanded(child: _buildOption("아주 아니다", Colors.purple[300]!)),
              ],
            ),
            const SizedBox(height: 130),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _previousQuestion,
                    tooltip: "이전 질문",
                  ),
                  if (currentIndex == questions.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        // Add the desired functionality for the 결과보기 button
                        print("결과보기 버튼이 클릭되었습니다.");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6A4DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("결과보기", style: TextStyle(color: Colors.white),),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String label, Color color) {
    if (currentIndex >= selectedAnswers.length) return Container();
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnswers[currentIndex] = label; // 선택한 답변을 현재 질문 인덱스에 저장
        });
        Future.delayed(const Duration(milliseconds: 300), () => _nextQuestion());
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (selectedAnswers[currentIndex] != null && selectedAnswers[currentIndex] == label)
                  ? color
                  : Colors.transparent, // 저장된 답변과 비교하여 색상 채우기
              border: Border.all(color: color, width: 2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}