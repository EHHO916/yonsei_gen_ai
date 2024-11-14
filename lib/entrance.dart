import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mbti_test.dart';

class EntranceScreen extends StatefulWidget {
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
        MaterialPageRoute(builder: (context) => MMTICCodeScreen()),
      );
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
            const Text('Enter MBTI code', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Enter your MBTI type using four letters, e.g., INFP', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
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
                backgroundColor: _isValidMBTI() ? Colors.purple : Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Continue', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CombinedScreen()),
                );
              },
              child: const Text(
                '검사하기',
                style: TextStyle(color: Colors.purple, fontSize: 16),
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
            borderSide: const BorderSide(color: Colors.purple, width: 2),
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
    // 각 컨트롤러에 리스너를 추가해 입력 값 변경 시 상태 업데이트
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
    setState(() {}); // 버튼 상태 업데이트를 위해 setState 호출
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

  // ##########################################################################
  void _onSubmitMMTIC() {
    final mmticCode = _controller1.text + _controller2.text + _controller3.text + _controller4.text;
    if (_isValidMMTIC()) {
      print("MMTIC 코드 입력 완료: $mmticCode");
      // 다음 화면 또는 처리 작업으로 이동
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
            const Text('Enter MMTIC code', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Enter your MMTIC code using four letters', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
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
                backgroundColor: _isValidMMTIC() ? Colors.purple : Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Continue', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  // ###########################################################
                  MaterialPageRoute(builder: (context) => CombinedScreen()), // 수정하기
                );
              },
              child: const Text(
                '검사하기',
                style: TextStyle(color: Colors.purple, fontSize: 16),
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
            borderSide: const BorderSide(color: Colors.purple, width: 2),
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