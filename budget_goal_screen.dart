import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BudgetGoalScreen extends StatefulWidget {
  final String userId;
  const BudgetGoalScreen({super.key, required this.userId});

  @override
  State<BudgetGoalScreen> createState() => _BudgetGoalScreenState();
}

class _BudgetGoalScreenState extends State<BudgetGoalScreen> {
  bool _isLoading = false;

  // Profile data
  int _monthlyIncome = 85000;
  int _monthlyExpenses = 35000;
  int _targetSavingsGoal = 1000000;
  List<String> _profileGoals = [];

  // Local goals detail
  final List<Map<String, dynamic>> _savingsGoals = [
    {"name": "MacBook Pro Purchase", "target": 145000, "saved": 35000, "color": Colors.amberAccent},
    {"name": "Europe Vacation trip", "target": 250000, "saved": 80000, "color": Colors.tealAccent},
    {"name": "Emergency Cushion Reserve", "target": 210000, "saved": 65000, "color": Colors.greenAccent},
  ];

  // Budget category tracking
  final List<Map<String, dynamic>> _budgets = [
    {"category": "Food & Dinings", "limit": 10000, "spent": 8500, "color": Colors.orangeAccent},
    {"category": "App & Web Subscriptions", "limit": 2000, "spent": 1200, "color": Colors.purpleAccent},
    {"category": "Cab & Travel Transits", "limit": 5000, "spent": 4800, "color": Colors.redAccent},
  ];

  String _aiRecommendations = "Audit goals to generate AI recommendations...";

  final TextEditingController _goalNameC = TextEditingController();
  final TextEditingController _goalTargetC = TextEditingController();

  final TextEditingController _budgetCNameC = TextEditingController();
  final TextEditingController _budgetLimitC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    try {
      final response = await http.get(Uri.parse('$baseUrl/money/financial-profile/${widget.userId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("income")) {
          setState(() {
            _monthlyIncome = data["income"] ?? 85000;
            _monthlyExpenses = data["expenses"] ?? 35000;
            _targetSavingsGoal = data["savings"] ?? 1000000;
            _profileGoals = List<String>.from(data["goals"] ?? []);

            // Dynamically recalculate Emergency Fund Target (6 months of fixed expenses)
            final efIndex = _savingsGoals.indexWhere((g) => g["name"].contains("Emergency"));
            if (efIndex != -1) {
              _savingsGoals[efIndex]["target"] = _monthlyExpenses * 6;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Load financials in Budget screen failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAiSavingsRecommendations() async {
    setState(() => _isLoading = true);
    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/money/advisor'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "question": "Provide 3 highly actionable, personalized AI savings recommendations based on my income of ₹$_monthlyIncome, monthly fixed expenses of ₹$_monthlyExpenses, and active savings goals.",
          "transactions": []
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiRecommendations = data["answer"] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Fetch recommendations failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addNewGoal() {
    final target = int.tryParse(_goalTargetC.text) ?? 0;
    if (_goalNameC.text.trim().isEmpty || target <= 0) return;
    setState(() {
      _savingsGoals.add({
        "name": _goalNameC.text.trim(),
        "target": target,
        "saved": 0,
        "color": Colors.blueAccent,
      });
      _goalNameC.clear();
      _goalTargetC.clear();
    });
    Navigator.pop(context);
  }

  void _addNewBudget() {
    final limit = int.tryParse(_budgetLimitC.text) ?? 0;
    if (_budgetCNameC.text.trim().isEmpty || limit <= 0) return;
    setState(() {
      _budgets.add({
        "category": _budgetCNameC.text.trim(),
        "limit": limit,
        "spent": 0,
        "color": Colors.cyanAccent,
      });
      _budgetCNameC.clear();
      _budgetLimitC.clear();
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Budget & Goal Planner", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileSummaryCard(),
              // 1. EMERGENCY FUND PLANNER
              _buildEmergencyFundCard(),
              const SizedBox(height: 20),

              // 2. SAVINGS GOALS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader("ACTIVE SAVINGS GOALS", Icons.track_changes),
                  TextButton.icon(
                    onPressed: _showAddGoalDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Add Goal"),
                  )
                ],
              ),
              const SizedBox(height: 10),
              ..._savingsGoals.map((goal) => _buildGoalProgressCard(goal)),
              const SizedBox(height: 20),

              // 3. CATEGORY BUDGET LIMITS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader("CATEGORY BUDGET LIMITS", Icons.pie_chart),
                  TextButton.icon(
                    onPressed: _showAddBudgetDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Add Budget"),
                  )
                ],
              ),
              const SizedBox(height: 10),
              ..._budgets.map((budget) => _buildBudgetProgressCard(budget)),
              const SizedBox(height: 20),

              // 4. AI RECOMMENDATIONS
              _buildAiRecommendationsCard(),
            ],
          ),
          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(color: Colors.greenAccent, backgroundColor: Colors.transparent),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.badge, color: Colors.blueAccent, size: 20),
              SizedBox(width: 8),
              Text("FINANCIAL GENOME SYNCED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Monthly Income", style: TextStyle(color: Colors.white38, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text("₹$_monthlyIncome", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Target Savings", style: TextStyle(color: Colors.white38, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text("₹$_targetSavingsGoal", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Genome Goals", style: TextStyle(color: Colors.white38, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text("${_profileGoals.length}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.greenAccent, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildEmergencyFundCard() {
    final ef = _savingsGoals.firstWhere((g) => g["name"].contains("Emergency"), orElse: () => _savingsGoals[0]);
    final progress = ef["target"] > 0 ? (ef["saved"] / ef["target"]).clamp(0.0, 1.0) : 0.0;
    
    // Calculate month coverage (saved / monthly expenses)
    double coverage = _monthlyExpenses > 0 ? ef["saved"] / _monthlyExpenses : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.shield, color: Colors.greenAccent, size: 20),
                  SizedBox(width: 8),
                  Text("EMERGENCY FUND PLANNER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${coverage.toStringAsFixed(1)} mo covered",
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, color: Colors.greenAccent, backgroundColor: Colors.white10, minHeight: 8),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Saved: ₹${ef["saved"]}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text("Target (6mo): ₹${ef["target"]}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "AI Calculation: Based on your monthly fixed expenses of ₹$_monthlyExpenses, a robust 6-month buffer requires ₹${_monthlyExpenses * 6}. You have saved ₹${ef["saved"]}.",
            style: const TextStyle(color: Colors.white38, fontSize: 10, height: 1.4, fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }

  Widget _buildGoalProgressCard(Map<String, dynamic> goal) {
    final double progress = goal["target"] > 0 ? (goal["saved"] / goal["target"]).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(goal["name"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text("$percent%", style: TextStyle(color: goal["color"], fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress, color: goal["color"], backgroundColor: Colors.white10, minHeight: 6),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Saved: ₹${goal["saved"]}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text("Target: ₹${goal["target"]}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBudgetProgressCard(Map<String, dynamic> budget) {
    final double progress = budget["limit"] > 0 ? budget["spent"] / budget["limit"] : 0.0;
    final isOver = progress > 1.0;
    final progressVal = progress.clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(budget["category"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(
                isOver ? "Limit Exceeded!" : "${(progress * 100).toInt()}% Used",
                style: TextStyle(color: isOver ? Colors.redAccent : budget["color"], fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progressVal, color: isOver ? Colors.redAccent : budget["color"], backgroundColor: Colors.white10, minHeight: 6),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Spent: ₹${budget["spent"]}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text("Limit: ₹${budget["limit"]}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAiRecommendationsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.tips_and_updates, color: Colors.greenAccent, size: 20),
                  SizedBox(width: 8),
                  Text("AI GOALS & SAVINGS RECOMMENDATIONS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.greenAccent, size: 20),
                onPressed: _fetchAiSavingsRecommendations,
              )
            ],
          ),
          const Divider(color: Colors.white10, height: 16),
          Text(
            _aiRecommendations,
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          )
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Create Savings Goal", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _goalNameC,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Goal Title (e.g. New Phone)", hintStyle: TextStyle(color: Colors.white24)),
            ),
            TextField(
              controller: _goalTargetC,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Target Amount (₹)", hintStyle: TextStyle(color: Colors.white24)),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: _addNewGoal, child: const Text("Create")),
        ],
      ),
    );
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Create Category Limit", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _budgetCNameC,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Category Name (e.g. Coffee)", hintStyle: TextStyle(color: Colors.white24)),
            ),
            TextField(
              controller: _budgetLimitC,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Monthly Limit (₹)", hintStyle: TextStyle(color: Colors.white24)),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: _addNewBudget, child: const Text("Create")),
        ],
      ),
    );
  }
}
