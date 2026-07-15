import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdvisorTwinScreen extends StatefulWidget {
  final String userId;
  const AdvisorTwinScreen({super.key, required this.userId});

  @override
  State<AdvisorTwinScreen> createState() => _AdvisorTwinScreenState();
}

class _AdvisorTwinScreenState extends State<AdvisorTwinScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Q&A advisor states
  final TextEditingController _advisorQC = TextEditingController(text: "How much should I save every month to buy a laptop?");
  String _advisorResponse = "Enter a question above and ask the AI advisor.";

  // Twin Chat states
  final TextEditingController _msgC = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "role": "assistant",
      "content": "Hello Shash! I've synced with your financial genome. You've spent 85% of your food budget this week, and you have subscriptions renewing soon. How can I help you optimize your savings today?"
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // API Call: AI Advisor
  Future<void> _askAdvisor() async {
    final text = _advisorQC.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);
    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/money/advisor'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "question": text,
          "transactions": [],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _advisorResponse = data["answer"] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Advisor failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // API Call: Money Twin Chat
  Future<void> _sendTwinMessage() async {
    final text = _msgC.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _msgC.clear();
      _isLoading = true;
    });

    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    try {
      final history = _messages.sublist(0, _messages.length - 1);
      final response = await http.post(
        Uri.parse('$baseUrl/money/money-twin'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "message": text,
          "chat_history": history,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({"role": "assistant", "content": data["answer"] ?? ""});
        });
      }
    } catch (e) {
      debugPrint("Twin failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Advisor & Money Twin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.greenAccent,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.greenAccent,
          tabs: const [
            Tab(icon: Icon(Icons.psychology), text: "AI Money Twin"),
            Tab(icon: Icon(Icons.forum), text: "Advisor Q&A"),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildTwinChatTab(),
              _buildAdvisorQnATab(),
            ],
          ),
          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(color: Colors.green, backgroundColor: Colors.transparent),
            ),
        ],
      ),
    );
  }

  Widget _buildTwinChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg["role"] == "user";
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                      bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
                      bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
                    ),
                    border: Border.all(color: isUser ? Colors.transparent : Colors.greenAccent.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    msg["content"] ?? "",
                    style: const TextStyle(color: Colors.white, height: 1.3),
                  ),
                ),
              );
            },
          ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF1E293B),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgC,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Ask Money Twin how to cut expenses...",
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: const Color(0xFF0F172A),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendTwinMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.greenAccent,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.black, size: 18),
                onPressed: _sendTwinMessage,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAdvisorQnATab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ASK GENERAL ADVISORY QUESTIONS", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          TextField(
            controller: _advisorQC,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Question",
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _askAdvisor,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Send Question", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Advisor Response:", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_advisorResponse, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
