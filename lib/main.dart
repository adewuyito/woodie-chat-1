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
      title: 'Lash Studio Assistant',
      theme: ThemeData(
        primaryColor: Color(0xFFE91E63),
        scaffoldBackgroundColor: Color(0xFF0D1421),
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
          'text': 'Hello beautiful! 💕 Welcome to our lash studio. I can help you with lash extensions, pricing, booking appointments, and aftercare tips. What would you like to know?'
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
          _controller.text = "How much do lash extensions cost?";
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1421),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1421),
              Color(0xFF162447),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFE91E63).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.face_retouching_natural,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Assistant',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Online • Ready to help',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF74B9FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF2D3748).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Messages Container
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A2E).withOpacity(0.4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    border: Border.all(
                      color: Color(0xFF2D3748).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    padding: EdgeInsets.all(20),
                    itemBuilder: (_, index) {
                      final msg = messages[index];
                      final isUser = msg['sender'] == 'user';
                      final isTyping = msg['sender'] == 'typing';
                      
                      if (isTyping) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            margin: EdgeInsets.only(bottom: 16, right: 80),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF2D3748).withOpacity(0.8),
                                  Color(0xFF4A5568).withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                bottomLeft: Radius.circular(4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _buildPulseAnimation(),
                          ),
                        );
                      }
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isUser) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Color(0xFF6C5CE7),
                                child: Icon(
                                  Icons.psychology_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: isUser 
                                    ? LinearGradient(
                                        colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Color(0xFF2D3748).withOpacity(0.8),
                                          Color(0xFF4A5568).withOpacity(0.6),
                                        ],
                                      ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: isUser ? Radius.circular(20) : Radius.circular(4),
                                    bottomRight: isUser ? Radius.circular(4) : Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isUser 
                                        ? Color(0xFF6C5CE7).withOpacity(0.3)
                                        : Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  msg['text'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            if (isUser) ...[
                              SizedBox(width: 8),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Color(0xFF74B9FF),
                                child: Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Input Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A2E).withOpacity(0.6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFF2D3748).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Voice Button
                    GestureDetector(
                      onTap: _toggleListening,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: _isListening 
                            ? LinearGradient(
                                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                              )
                            : LinearGradient(
                                colors: [
                                  Color(0xFF2D3748).withOpacity(0.8),
                                  Color(0xFF4A5568).withOpacity(0.6),
                                ],
                              ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _isListening 
                                ? Color(0xFFFF6B6B).withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    
                    // Text Input
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF2D3748).withOpacity(0.4),
                              Color(0xFF4A5568).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Color(0xFF6C5CE7).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _sendMessage(),
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    
                    // Send Button
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6C5CE7).withOpacity(0.4),
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPulseAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (index) {
              final animationValue = Curves.easeInOut.transform(
                (_animationController.value - (index * 0.2)).clamp(0.0, 1.0),
              );
              
              return Container(
                width: 8,
                height: 8 + (8 * animationValue),
                margin: EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
