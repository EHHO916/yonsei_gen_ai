import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:proto_type/entrance.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'diary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParentCare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'noto',
      ),
      home: StartScreen(),
    );
  }
}
 // SignUp과 SignIn을 눌렀을 때 차이점을 부과해야함
class StartScreen extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<void> _handleGoogleSignIn(BuildContext context, {bool isSignUp = false}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        print('로그인 성공: ${googleUser.displayName}');
        if (isSignUp) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EntranceScreen(googleUser: googleUser)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiaryHome()),
          );
        }
      }
    } catch (error) {
      print('로그인 에러: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Smart Support and\nAdvice for Every Parent',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Empowering Parents with Knowledge\nBecause Every Parent Deserves Support.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleGoogleSignIn(context, isSignUp: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => _handleGoogleSignIn(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: const Text('Sign In', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final GoogleSignInAccount? googleUser;

  const ChatScreen({Key? key, this.googleUser}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _textFieldScrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  String _typingMessage = '';

  Future<void> _sendMessage(String text) async {
    setState(() {
      _messages.add({'text': text, 'sender': 'user'});
    });
    _controller.clear();
    _textFieldScrollController.jumpTo(0.0);

    final response = await _fetchOpenAIResponse(text);
    if (response != null) {
      await _displayTypingEffect(response);
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _displayTypingEffect(String response) async {
    _typingMessage = '';
    for (int i = 0; i < response.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50)); // 글자마다 지연 시간
      setState(() {
        _typingMessage = response.substring(0, i + 1);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      });
    }
    setState(() {
      _messages.add({'text': _typingMessage, 'sender': 'bot'});
      _typingMessage = '';
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<String?> _fetchOpenAIResponse(String prompt) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 100,
      }),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody);
      return data['choices'][0]['message']['content']?.trim();
    } else {
      print('Failed to fetch response: ${response.statusCode}');
      return null;
    }
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignInAccount? googleUser = widget.googleUser;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'ParentCare',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetChat,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // 경계선의 높이
          child: Container(
            color: Colors.grey, // 경계선 색상
            height: 1.0, // 경계선 두께
          ),
        ),
      ),
      drawer: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          googleUser?.photoUrl != null
                              ? CircleAvatar(
                            backgroundImage: NetworkImage(googleUser!.photoUrl!),
                            radius: 30,
                          )
                              : const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.person),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                googleUser?.displayName ?? 'Guest',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                googleUser?.email ?? 'No Email',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text('로그아웃'),
                              content: const Text('정말 로그아웃 하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('취소', style: TextStyle(color: Colors.grey)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('로그아웃', style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogout == true) {
                            await GoogleSignIn().signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => StartScreen()),
                                  (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey[300], thickness: 3),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.black),
                  title: const Text('Home', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Divider(color: Colors.grey[300], thickness: 1),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.black),
                  title: const Text('Profile', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Divider(color: Colors.grey[300], thickness: 1),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.black),
                  title: const Text('Settings', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Divider(color: Colors.grey[300], thickness: 3),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xfff6f6f6),
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(right: 8.0),
                  itemCount: _typingMessage.isNotEmpty ? _messages.length + 1 : _messages.length,
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _typingMessage.isNotEmpty) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 13.0),
                            child: Image.asset(
                              'assets/images/chaticon.png',
                              width: 32,
                              height: 32,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                _typingMessage,
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final message = _messages[index];
                    bool isUser = message['sender'] == 'user';

                    return Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 13.0),
                            child: Image.asset(
                              'assets/images/chaticon.png',
                              width: 32,
                              height: 32,
                            ),
                          ),
                        if (!isUser) const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                            decoration: BoxDecoration(
                              color: isUser ? const Color(0xFF664FF6) : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              message['text'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: isUser ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[300] ?? Colors.grey, // null 안전 처리
                    width: 1.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _textFieldScrollController,
                        scrollDirection: Axis.vertical,
                        reverse: true,
                        child: TextFormField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: '메시지를 입력해주세요.',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                          ),
                          minLines: 1,
                          maxLines: 8, // 최대 5줄까지 확장 가능
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      padding: const EdgeInsets.all(15.0),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          _sendMessage(_controller.text);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}