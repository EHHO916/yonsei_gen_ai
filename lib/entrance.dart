import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mbti_test.dart';
import 'mmtic_test.dart';
import 'ecr_test.dart';
import 'main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class EntranceScreen extends StatefulWidget {
  final GoogleSignInAccount? googleUser;

  const EntranceScreen({Key? key, this.googleUser}) : super(key: key);

  @override
  _EntranceScreenState createState() => _EntranceScreenState();
}

class _EntranceScreenState extends State<EntranceScreen> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller1.addListener(_updateButtonState);
    _controller2.addListener(_updateButtonState);
    _controller3.addListener(_updateButtonState);
    _controller4.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  bool _isValidMBTI() {
    final first = _controller1.text.toUpperCase();
    final second = _controller2.text.toUpperCase();
    final third = _controller3.text.toUpperCase();
    final fourth = _controller4.text.toUpperCase();

    return (first == 'E' || first == 'I') &&
        (second == 'N' || second == 'S') &&
        (third == 'T' || third == 'F') &&
        (fourth == 'P' || fourth == 'J');
  }

  void _updateButtonState() {
    setState(() {});
  }

  void _onContinue() {
    if (_isValidMBTI()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MMTICCodeScreen(googleUser: widget.googleUser)),
      );
    }
  }

  void _fillMBTIFields(String mbtiResult) {
    if (mbtiResult.length == 4) {
      setState(() {
        _controller1.text = mbtiResult[0];
        _controller2.text = mbtiResult[1];
        _controller3.text = mbtiResult[2];
        _controller4.text = mbtiResult[3];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('MBTI를 입력해주세요', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('개인의 성격 유형을 16가지로 분류하여\n자기 이해와 대인관계 개선에 도움을 주는 성격 유형 검사', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCodeField(_controller1, ['E', 'I']),
                _buildCodeField(_controller2, ['N', 'S']),
                _buildCodeField(_controller3, ['T', 'F']),
                _buildCodeField(_controller4, ['P', 'J']),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isValidMBTI() ? _onContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isValidMBTI() ? const Color(0xFF664FF6) : Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Continue', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CombinedScreen()),
                );

                if (result != null && result is String) {
                  _fillMBTIFields(result);
                }
              },
              child: const Text(
                '검사하기',
                style: TextStyle(color: Color(0xFF664FF6), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeField(TextEditingController controller, List<String> validChars) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24),
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF664FF6), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: TextInputType.text,
        inputFormatters: [
          UpperCaseTextFormatter(),
          FilteringTextInputFormatter.allow(RegExp('[' + validChars.join() + ']')),
        ],
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}

class MMTICCodeScreen extends StatefulWidget {
  final GoogleSignInAccount? googleUser;

  const MMTICCodeScreen({Key? key, this.googleUser}) : super(key: key);

  @override
  _MMTICCodeScreenState createState() => _MMTICCodeScreenState();
}

class _MMTICCodeScreenState extends State<MMTICCodeScreen> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller1.addListener(_updateButtonState);
    _controller2.addListener(_updateButtonState);
    _controller3.addListener(_updateButtonState);
    _controller4.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool _isValidMMTIC() {
    final first = _controller1.text.toUpperCase();
    final second = _controller2.text.toUpperCase();
    final third = _controller3.text.toUpperCase();
    final fourth = _controller4.text.toUpperCase();

    return (first == 'E' || first == 'I') &&
        (second == 'N' || second == 'S') &&
        (third == 'T' || third == 'F') &&
        (fourth == 'P' || fourth == 'J');
  }

  void _onSubmitMMTIC() {
    if (_isValidMMTIC()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GoalSelectionScreen(googleUser: widget.googleUser)),
      );
    }
  }

  void _fillMMTICFields(String mbtiResult) {
    if (mbtiResult.length == 4) {
      setState(() {
        _controller1.text = mbtiResult[0];
        _controller2.text = mbtiResult[1];
        _controller3.text = mbtiResult[2];
        _controller4.text = mbtiResult[3];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('MMTIC를 입력해주세요', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('아동 및 청소년의 성격 유형을 분석하여\n학습 스타일과 대인관계 특성을 이해하도록 돕는 성격 유형 검사', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCodeField(_controller1, ['E', 'I']),
                _buildCodeField(_controller2, ['N', 'S']),
                _buildCodeField(_controller3, ['T', 'F']),
                _buildCodeField(_controller4, ['P', 'J']),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isValidMMTIC() ? _onSubmitMMTIC : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isValidMMTIC() ? const Color(0xFF664FF6) : Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Continue', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CombinedScreen2()),
                );

                if (result != null && result is String) {
                  _fillMMTICFields(result);
                }
              },
              child: const Text(
                '검사하기',
                style: TextStyle(color: Color(0xFF664FF6), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeField(TextEditingController controller, List<String> validChars) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24),
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF664FF6), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: TextInputType.text,
        inputFormatters: [
          UpperCaseTextFormatter(),
          FilteringTextInputFormatter.allow(RegExp('[' + validChars.join() + ']')),
        ],
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class GoalSelectionScreen extends StatefulWidget {
  final GoogleSignInAccount? googleUser;

  const GoalSelectionScreen({Key? key, this.googleUser}) : super(key: key);

  @override
  _GoalSelectionScreenState createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? _selectedGoal;

  void _onSelectGoal(String goal) {
    setState(() {
      _selectedGoal = goal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '애착 유형을 선택해주세요',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '부모와 자녀의 애착 유형과 상호작용 패턴을 분석하여\n건강한 양육 및 관계 개선에 도움을 주는 심리 검사',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildGoalOption(
              '안정 애착',
              isSelected: _selectedGoal == '안정 애착',
            ),
            const SizedBox(height: 16),
            _buildGoalOption(
              '몰입 애착',
              isSelected: _selectedGoal == '몰입 애착',
            ),
            const SizedBox(height: 16),
            _buildGoalOption(
              '거부형 회피 애착',
              isSelected: _selectedGoal == '거부형 회피 애착',
            ),
            const SizedBox(height: 16),
            _buildGoalOption(
              '공포형(두려움) 회피 애착',
              isSelected: _selectedGoal == '공포형(두려움) 회피 애착',
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(googleUser: widget.googleUser),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4DFF),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 159),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "검사 완료",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CombinedScreen3()),
                );

                if (result != null && result is String) {
                  setState(() {
                    _selectedGoal = result;
                  });
                }
              },
              child: const Text(
                '검사하기',
                style: TextStyle(color: Color(0xFF664FF6), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(String text, {required bool isSelected}) {
    return GestureDetector(
      onTap: () => _onSelectGoal(text),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF664FF6) : Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? const Color(0xFF664FF6) : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
