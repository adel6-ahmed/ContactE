import 'package:flutter/material.dart';
import 'package:sad/shared/theme/colors.dart';
import 'package:sad/shared/theme/texet.dart';
import 'package:lottie/lottie.dart';
import '../services/chat_gpt_service.dart';

class ChatBotScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onClose;
  final bool isEmbedded;

  const ChatBotScreen({
    super.key,
    required this.isDarkMode,
    required this.onClose,
    this.isEmbedded = false,
  });

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();
  bool _useChatGpt = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isTextFieldFocused = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
    
    // إضافة مستمع لحقل الكتابة
    _focusNode.addListener(() {
      setState(() {
        _isTextFieldFocused = _focusNode.hasFocus;
      });
    });
    
    // رسالة ترحيبية تلقائية
    _addBotMessage('مرحباً! أنا برادي 🤖\nكيف يمكنني مساعدتك في تطبيق ContactE اليوم؟');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({
        'text': text,
        'sender': 'bot',
        'time': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({
        'text': text,
        'sender': 'user',
        'time': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();
    _getBotResponse(message);
    _focusNode.unfocus();
  }

  void _getBotResponse(String userMessage) async {
    setState(() {
      _isTyping = true;
    });

    try {
      String response;
      
      if (_useChatGpt) {
        response = await ChatGptService.getChatResponse(userMessage, _messages);
      } else {
        response = ChatGptService.getFallbackResponse(userMessage);
      }

      setState(() {
        _isTyping = false;
      });

      _addBotMessage(response);
    } catch (e) {
      setState(() {
        _isTyping = false;
      });
      
      final fallbackResponse = ChatGptService.getFallbackResponse(userMessage);
      _addBotMessage(fallbackResponse);
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) 
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Lyellow,
                boxShadow: [
                  BoxShadow(
                    color: Lyellow.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/teapot.png',
                  fit: BoxFit.contain,
                  color: Ldark,
                ),
              ),
            ),
          if (!isUser) const SizedBox(width: 12),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser
                    ? Lyellow
                    : Colors.white,
                borderRadius: BorderRadius.circular(22).copyWith(
                  bottomLeft: isUser ? const Radius.circular(22) : const Radius.circular(6),
                  bottomRight: isUser ? const Radius.circular(6) : const Radius.circular(22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser ? Ldark : Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(message['time']),
                    style: TextStyle(
                      fontSize: 11,
                      color: isUser ? Ldark.withOpacity(0.6) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 12),
          if (isUser)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Ldark,
                border: Border.all(color: Lyellow, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.person_rounded, color: Lyellow, size: 20),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Lyellow,
              boxShadow: [
                BoxShadow(
                  color: Lyellow.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/teapot.png',
                fit: BoxFit.contain,
                color: Ldark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(22),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(22),
                topLeft: Radius.circular(22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/typing.json',
                  width: 30,
                  height: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _useChatGpt ? 'برادي يكتب...' : 'جارٍ المعالجة...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleChatGptMode() {
    setState(() {
      _useChatGpt = !_useChatGpt;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _useChatGpt ? '🔄 تم التبديل إلى الوضع الذكي' : '⚡ تم التبديل إلى الوضع السريع',
          style: TextStyle(color: Ldark, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Lyellow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildInputField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isTextFieldFocused 
            ? Colors.white.withOpacity(0.12)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _isTextFieldFocused 
              ? Lyellow.withOpacity(0.6)
              : Colors.white.withOpacity(0.2),
          width: _isTextFieldFocused ? 2 : 1,
        ),
        boxShadow: [
          if (_isTextFieldFocused)
            BoxShadow(
              color: Lyellow.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: Row(
        children: [
          // زر الإرفاق
          IconButton(
            onPressed: () {
              // وظيفة إرسال الملفات
            },
            icon: Icon(
              Icons.attach_file_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          
          const SizedBox(width: 4),
          
          // زر الإيموجي
          IconButton(
            onPressed: () {
              // إضافة emoji picker
            },
            icon: Icon(
              Icons.emoji_emotions_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // حقل النص
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                isDense: true,
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          
          const SizedBox(width: 8),
          
          // زر الإرسال
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _messageController.text.trim().isNotEmpty ? 45 : 0,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Lyellow,
              boxShadow: [
                BoxShadow(
                  color: Lyellow.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _messageController.text.trim().isNotEmpty ? _sendMessage : null,
                borderRadius: BorderRadius.circular(30),
                child: Icon(
                  Icons.send_rounded,
                  color: Ldark,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Ldark,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Lyellow,
              boxShadow: [
                BoxShadow(
                  color: Lyellow.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                'assets/teapot.png',
                fit: BoxFit.contain,
                color: Ldark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'برادي المساعد',
                  style: h3Bold.copyWith(
                    color: Lyellow,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _useChatGpt ? Colors.green : Colors.orange,
                        boxShadow: [
                          BoxShadow(
                            color: (_useChatGpt ? Colors.green : Colors.orange).withOpacity(0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _useChatGpt ? 'الذكي (متصل بالشبكة)' : 'المحلي (سريع)',
                      style: title2.copyWith(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // زر تبديل الوضع
          IconButton(
            onPressed: _toggleChatGptMode,
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
              child: Icon(
                _useChatGpt ? Icons.auto_awesome_rounded : Icons.bolt_rounded,
                color: Lyellow,
                size: 22,
              ),
            ),
          ),
          
          // زر الإغلاق
          IconButton(
            onPressed: widget.onClose,
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Lyellow,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Ldark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Lyellow,
              boxShadow: [
                BoxShadow(
                  color: Lyellow.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/teapot.png',
                fit: BoxFit.contain,
                color: Ldark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'برادي المساعد',
                  style: h3Bold.copyWith(
                    color: Lyellow,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _useChatGpt ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _useChatGpt ? 'متصل - جاهز للمساعدة' : 'وضع سريع',
                      style: title2.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // زر تبديل الوضع
          IconButton(
            onPressed: _toggleChatGptMode,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
              child: Icon(
                _useChatGpt ? Icons.auto_awesome_rounded : Icons.bolt_rounded,
                color: Lyellow,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/chat-bot.json',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 20),
          Text(
            'مرحباً! أنا برادي 🤖',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'كيف يمكنني مساعدتك في تطبيق ContactE اليوم؟\nاسألني عن أي شيء يتعلق بالتطبيق',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 25),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickQuestion('كيف أضيف جهة اتصال؟'),
              _buildQuickQuestion('ما هي المجموعات؟'),
              _buildQuickQuestion('كيف أبحث عن أصدقاء؟'),
              _buildQuickQuestion('شرح إعدادات الحساب'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestion(String question) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _messageController.text = question;
          _sendMessage();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            question,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              height: widget.isEmbedded 
                  ? MediaQuery.of(context).size.height - 200
                  : MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Ldark,
                borderRadius: widget.isEmbedded
                    ? BorderRadius.circular(25)
                    : const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 8,
                    offset: const Offset(0, -15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  if (!widget.isEmbedded) _buildHeader(),
                  if (widget.isEmbedded) _buildEmbeddedHeader(),
                  
                  // Messages Area
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Ldark,
                            const Color(0xFF1a1f1e),
                            const Color(0xFF151918),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                        borderRadius: widget.isEmbedded 
                            ? const BorderRadius.vertical(top: Radius.circular(25))
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _messages.isEmpty && !_isTyping
                            ? _buildEmptyState()
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: _messages.length + (_isTyping ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _messages.length && _isTyping) {
                                    return _buildTypingIndicator();
                                  }
                                  return _buildMessageBubble(_messages[index]);
                                },
                              ),
                      ),
                    ),
                  ),

                  // Input Area
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, widget.isEmbedded ? 80 : 20),
                    decoration: BoxDecoration(
                      color: Ldark,
                      border: widget.isEmbedded 
                          ? null
                          : Border(
                              top: BorderSide(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                      boxShadow: [
                        if (!widget.isEmbedded)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                      ],
                    ),
                    child: _buildInputField(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}