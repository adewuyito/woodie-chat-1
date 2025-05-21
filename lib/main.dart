import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Reset database when app starts
  await DBHelper.resetDatabase();
  runApp(ChatbotApp());
}

class ChatbotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Assistant',
      theme: ThemeData(
        primaryColor: Color(0xFF1A237E),
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
      ),
      home: ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  late AnimationController _animationController;
  bool _isListening = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();
    
    // Add initial greeting
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        messages.add({
          'sender': 'bot', 
          'text': 'Hi! I\'m your Smart Home Assistant. How can I help you today?'
        });
      });
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;
    
    setState(() {
      messages.add({'sender': 'user', 'text': input});
    });
    _controller.clear();
    
    // Scroll to bottom
    _scrollToBottom();
    
    // Add thinking delay
    await Future.delayed(Duration(milliseconds: 600));
    
    // Show typing indicator
    setState(() {
      messages.add({'sender': 'typing', 'text': ''});
    });
    
    final response = await DBHelper.getAnswer(input);
    
    // Remove typing and add response
    setState(() {
      messages.removeWhere((element) => element['sender'] == 'typing');
      messages.add({'sender': 'bot', 'text': response!});
    });
    
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });
    
    if (_isListening) {
      // In a real app, this would activate speech recognition
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isListening = false;
          // Simulate received voice input
          _controller.text = "What smart speakers do you have?";
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: Color(0xFF1A237E),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'SMART HOME ASSISTANT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white70),
            onPressed: () {
              // Show help menu
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white70),
            onPressed: () {
              // Show settings
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            color: Color(0xFF1A237E),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.electric_bolt, color: Colors.yellow),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Get 20% off all smart home products with code SMART20',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                padding: EdgeInsets.fromLTRB(16, 26, 16, 16),
                itemBuilder: (_, index) {
                  final msg = messages[index];
                  final isUser = msg['sender'] == 'user';
                  final isTyping = msg['sender'] == 'typing';
                  
                  if (isTyping) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 12, right: 80),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPulseAnimation(),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(
                        bottom: 12,
                        left: isUser ? 80 : 0,
                        right: isUser ? 0 : 80,
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? Color(0xFF1A237E) : Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            color: Color(0xFF121212),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : Color(0xFF1E1E1E),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.white : Colors.blue[200],
                        size: 24,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Color(0xFF333333)),
                    ),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ask about smart home products...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
   ],
      ),
    );
  }
  
  Widget _buildPulseAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          children: List.generate(
            3,
            (index) {
              final animationValue = Curves.easeInOut.transform(
                (_animationController.value - (index * 0.2)).clamp(0.0, 1.0),
              );
              
              return Container(
                width: 8,
                height: 8 + (6 * animationValue),
                margin: EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
        );
      },
    );
  }
}