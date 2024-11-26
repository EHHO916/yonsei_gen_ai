import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CombinedScreen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ECR TEST',
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
                    borderRadius: BorderRadius.circular(10),
                    child: ValueListenableBuilder<double>(
                      valueListenable: progressNotifier,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.grey[300],
                          color: const Color(0xFF6A4DFF),
                          minHeight: 6,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ECRTestScreen(
                    onComplete: (result) {
                      Navigator.pop(context, result); // 결과를 반환
                    },
                  ),
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

class ECRTestScreen extends StatefulWidget {
  final void Function(String) onComplete; // 결과를 반환받는 콜백 추가
  final double cardHeight;

  const ECRTestScreen({Key? key, required this.onComplete, this.cardHeight = 300.0}) : super(key: key);

  @override
  _ECRTestScreenState createState() => _ECRTestScreenState();
}

class _ECRTestScreenState extends State<ECRTestScreen> {
  List<String> questions = [];
  int currentIndex = 0;
  List<int?> selectedAnswers = [];
  Map<String, double> scores = {
    "불안": 0.0, // 불안 점수
    "회피": 0.0, // 회피 점수
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadQuestions();
    });
    progressNotifier.value = 0.0;
  }

  Future<void> _loadQuestions() async {
    try {
      print('Trying to load file...');
      final fileContent = await rootBundle.loadString('assets/Q/ecr_q.txt');
      print('File loaded successfully');
      setState(() {
        questions = fileContent.split('\n').where((line) => line.isNotEmpty).toList();
        selectedAnswers = List<int?>.filled(questions.length, null);
      });
    } catch (e) {
      print('Error loading file: $e');
    }
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

  void _calculateScores() {
    scores["불안"] = 0.0;
    scores["회피"] = 0.0;

    final anxietyIndices = [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35];
    final avoidanceIndices = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34];

    for (int i = 0; i < selectedAnswers.length; i++) {
      if (selectedAnswers[i] == null) continue;
      final score = selectedAnswers[i]!;

      if (anxietyIndices.contains(i)) {
        scores["불안"] = (scores["불안"] ?? 0) + score;
      } else if (avoidanceIndices.contains(i)) {
        scores["회피"] = (scores["회피"] ?? 0) + score;
      }
    }
  }

  String _calculateECRResult() {
    _calculateScores();

    final anxietyAvg = scores["불안"]! / 18;
    final avoidanceAvg = scores["회피"]! / 18;

    if (anxietyAvg < 2.33 && avoidanceAvg < 2.61) {
      return "안정 애착";
    } else if (anxietyAvg >= 2.33 && avoidanceAvg < 2.61) {
      return "몰입 애착";
    } else if (anxietyAvg < 2.33 && avoidanceAvg >= 2.61) {
      return "거부형 회피 애착";
    } else {
      return "공포형(두려움) 회피 애착";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      // 질문 로딩 중 상태
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

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
            if (currentIndex < questions.length) ...[
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
                  Expanded(child: _buildOption(1, "아주 그렇다", Colors.green[300]!)),
                  Expanded(child: _buildOption(2, "그렇다", Colors.green[200]!)),
                  Expanded(child: _buildOption(3, "보통", Colors.grey)),
                  Expanded(child: _buildOption(4, "아니다", Colors.purple[200]!)),
                  Expanded(child: _buildOption(5, "아주 아니다", Colors.purple[300]!)),
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
                          setState(() {
                            currentIndex++; // 결과 화면으로 이동
                            progressNotifier.value = 1.0; // 프로그레스 완료 상태
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A4DFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "결과보기",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ] else if (currentIndex == questions.length) ...[
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        '당신의 애착 유형은: ${_calculateECRResult()} 입니다!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          widget.onComplete(_calculateECRResult()); // 결과 반환
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A4DFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "결과 반환",
                          style: TextStyle(color: Colors.white),
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
    );
  }

  Widget _buildOption(int value, String label, Color color) {
    if (currentIndex >= selectedAnswers.length) return Container();
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnswers[currentIndex] = value;
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
              color: (selectedAnswers[currentIndex] != null && selectedAnswers[currentIndex] == value)
                  ? color
                  : Colors.transparent,
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