import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CombinedScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MMTIC TEST',
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
                const Expanded(
                  child: MMTICTestScreen(cardHeight: 300),
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

class MMTICTestScreen extends StatefulWidget {
  final double cardHeight;

  const MMTICTestScreen({Key? key, this.cardHeight = 300.0}) : super(key: key);

  @override
  _MMTICTestScreenState createState() => _MMTICTestScreenState();
}

class _MMTICTestScreenState extends State<MMTICTestScreen> {
  List<String> questions = [];
  int currentIndex = 0;
  List<int?> selectedAnswers = [];
  Map<String, double> scores = {
    "E": 0,
    "I": 0,
    "S": 0,
    "N": 0,
    "T": 0,
    "F": 0,
    "J": 0,
    "P": 0,
  };

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    progressNotifier.value = 0.0;
  }

  Future<void> _loadQuestions() async {
    final fileContent = await rootBundle.loadString('assets/Q/mmtic_q.txt');
    setState(() {
      questions = fileContent.split('\n').where((line) => line.isNotEmpty).toList();
      selectedAnswers = List<int?>.filled(questions.length, null);
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

  String _calculateMBTIResult() {
    // 점수와 질문 수를 초기화
    scores = {
      "E": 0,
      "I": 0,
      "S": 0,
      "N": 0,
      "T": 0,
      "F": 0,
      "J": 0,
      "P": 0,
    };

    Map<String, int> dimensionQuestionCount = {
      "E": 0,
      "I": 0,
      "S": 0,
      "N": 0,
      "T": 0,
      "F": 0,
      "J": 0,
      "P": 0,
    };

    // 점수 계산
    for (int i = 0; i < selectedAnswers.length; i++) {
      if (selectedAnswers[i] == null) continue;

      // 현재 질문의 성향과 반대 성향 가져오기
      String dimension = _getDimensionForQuestion(i); // 현재 질문 성향
      String oppositeDimension = _getOppositeDimension(dimension); // 반대 성향

      // 현재 성향의 가중치
      double weight = _weightedScore(selectedAnswers[i]!);

      // 반대 성향의 가중치
      double oppositeWeight = 2.0 - weight;

      // 점수 누적
      scores[dimension] = (scores[dimension] ?? 0) + weight;
      scores[oppositeDimension] = (scores[oppositeDimension] ?? 0) + oppositeWeight;

      // 차원별 질문 수 증가
      dimensionQuestionCount[dimension] = (dimensionQuestionCount[dimension]! + 1);
      dimensionQuestionCount[oppositeDimension] = (dimensionQuestionCount[oppositeDimension]! + 1);
    }

    // 최종 MBTI 계산
    String mbti = (scores["E"]! > scores["I"]! ? "E" : "I") +
        (scores["S"]! > scores["N"]! ? "S" : "N") +
        (scores["T"]! > scores["F"]! ? "T" : "F") +
        (scores["J"]! > scores["P"]! ? "J" : "P");

    // 결과 메시지 생성
    String result = mbti;

    return result;
  }

  String _getDimensionForQuestion(int index) {
    // 질문 번호를 기준으로 MBTI 차원 반환
    if (index >= 0 && index < 10) {
      return index % 2 == 0 ? "E" : "I"; // 1~8번: E와 I
    } else if (index >= 10 && index < 20) {
      return index % 2 == 0 ? "S" : "N"; // 9~16번: S와 N
    } else if (index >= 20 && index < 30) {
      return index % 2 == 0 ? "T" : "F"; // 17~24번: T와 F
    } else if (index >= 30 && index < 50) {
      return index % 2 == 0 ? "J" : "P"; // 25~32번: J와 P
    }
    return "X"; // 예외 처리
  }

  String _getOppositeDimension(String dimension) {
    // 각 차원의 반대 성향 반환
    switch (dimension) {
      case "E":
        return "I";
      case "I":
        return "E";
      case "S":
        return "N";
      case "N":
        return "S";
      case "T":
        return "F";
      case "F":
        return "T";
      case "J":
        return "P";
      case "P":
        return "J";
      default:
        return "X";
    }
  }

  double _weightedScore(int response) {
    // 응답(1~5)을 가중치로 변환
    return {1: 2.0, 2: 1.5, 3: 1.0, 4: 0.5, 5: 0.0}[response]!;
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
            if (currentIndex < questions.length) ...[
              // 질문 화면
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          '자녀의 MMTIC 결과는\n${_calculateMBTIResult()} 입니다!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Column(
                        children: [
                          _buildCombinedBar(
                            "외향(E)", "내향(I)",
                            scores["E"]!, scores["I"]!,
                            leftColor: Colors.blue[200],   // 외향(E)의 색상
                            rightColor: Colors.orange[200], // 내향(I)의 색상
                          ),
                          const SizedBox(height: 16),
                          _buildCombinedBar(
                            "감각(S)", "직관(N)",
                            scores["S"]!, scores["N"]!,
                            leftColor: Colors.green[200],  // 감각(S)의 색상
                            rightColor: Colors.purple[200], // 직관(N)의 색상
                          ),
                          const SizedBox(height: 16),
                          _buildCombinedBar(
                            "사고(T)", "감정(F)",
                            scores["T"]!, scores["F"]!,
                            leftColor: Colors.red[200],    // 사고(T)의 색상
                            rightColor: Colors.cyan[200],   // 감정(F)의 색상
                          ),
                          const SizedBox(height: 16),
                          _buildCombinedBar(
                            "판단(J)", "인식(P)",
                            scores["J"]!, scores["P"]!,
                            leftColor: Colors.teal[200],   // 판단(J)의 색상
                            rightColor: Colors.brown[200],  // 인식(P)의 색상
                          ),
                        ],
                      ),
                      const SizedBox(height: 60), // 버튼과 바 사이의 간격
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            String result = _calculateMBTIResult(); // 검사 결과 계산
                            Navigator.pop(context, result); // 결과 전달하며 이전 화면으로 돌아가기
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A4DFF), // 버튼 색상
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "돌아가기",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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

Widget _buildCombinedBar(
    String leftLabel,
    String rightLabel,
    double leftValue,
    double rightValue, {
      leftColor = Colors.blue,
      rightColor = Colors.red,
    }) {
  // 두 성향의 합으로 비율 계산
  double total = leftValue + rightValue;
  if (total == 0) total = 1;
  double leftPercentage = (leftValue / total) * 100;
  double rightPercentage = (rightValue / total) * 100;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // 성향 텍스트 표시
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$leftLabel: ${leftPercentage.toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            "$rightLabel: ${rightPercentage.toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      const SizedBox(height: 4),
      // 하나의 Bar로 성향 표시
      Row(
        children: [
          // 왼쪽 성향 Bar
          Expanded(
            flex: (leftValue / total * 100).round(), // 왼쪽 비율에 따른 Flex 값
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: leftColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
            ),
          ),
          // 오른쪽 성향 Bar
          Expanded(
            flex: (rightValue / total * 100).round(), // 오른쪽 비율에 따른 Flex 값
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: rightColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}