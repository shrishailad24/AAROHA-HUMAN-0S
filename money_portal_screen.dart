import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

// Import sub-screens
import 'budget_goal_screen.dart';
import 'decision_simulator_screen.dart';
import 'expense_tracker_screen.dart';
import 'advisor_twin_screen.dart';
import 'smart_shopping_screen.dart';
import 'scam_protection_screen.dart';

class MoneyPortalScreen extends StatefulWidget {
  final String userId;
  const MoneyPortalScreen({super.key, required this.userId});

  @override
  State<MoneyPortalScreen> createState() => _MoneyPortalScreenState();
}

class _MoneyPortalScreenState extends State<MoneyPortalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Financial Genome Profile controllers
  final _incomeC = TextEditingController(text: "85000");
  final _expenseC = TextEditingController(text: "35000");
  final _savingsC = TextEditingController(text: "25000");
  final _goalsC = TextEditingController(text: "Buy Laptop, Save 10 Lakhs");
  final _loansC = TextEditingController(text: "EMI: ₹15,000 Home Loan");
  
  // Financial Preferences
  String _riskAppetite = "Moderate";
  String _savingsFocus = "Long-term Wealth";
  
  bool _isLoading = false;

  // Transactions list
  final List<Map<String, dynamic>> _transactions = [
    {"desc": "Groceries", "amount": 2300, "category": "Food", "type": "Expense"},
    {"desc": "Rent", "amount": 15000, "category": "Rent", "type": "Expense"},
    {"desc": "Internet", "amount": 999, "category": "Bills", "type": "Expense"},
    {"desc": "Freelance work", "amount": 8000, "category": "Side Income", "type": "Income"},
  ];

  // Advisor Q&A states
  final _advisorQC = TextEditingController(text: "Can I afford a new ₹60,000 laptop?");
  String _advisorResponse = "Type a question and ask the AI advisor.";

  // Investment learning states
  String _riskAssessment = "Not Assessed Yet";
  List<dynamic> _investOptions = [];
  List<dynamic> _simulatedPortfolio = [];

  // Bill reminders lists
  final List<Map<String, dynamic>> _bills = [
    {"name": "Electricity Bill", "amount": 1800, "due": "In 3 Days", "paid": false},
    {"name": "App Subscription Renewal", "amount": 299, "due": "Tomorrow", "paid": false},
    {"name": "Home Rent", "amount": 15000, "due": "In 5 Days", "paid": true},
  ];

  // Subscription Optimizer states
  final List<Map<String, dynamic>> _subscriptions = [
    {"name": "Streaming Movie Plan", "cost": 499, "usage": "2 hours/month"},
    {"name": "Premium Music Sub", "cost": 99, "usage": "35 hours/month"},
    {"name": "Gym membership", "cost": 1500, "usage": "0 hours/month (No visits)"},
  ];
  Map<String, dynamic>? _subscriptionAuditResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadFinancialProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load Financial Profile
  Future<void> _loadFinancialProfile() async {
    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    try {
      final response = await http.get(Uri.parse('$baseUrl/money/financial-profile/${widget.userId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("income")) {
          setState(() {
            _incomeC.text = data["income"].toString();
            _expenseC.text = data["expenses"].toString();
            _savingsC.text = data["savings"].toString();
            _goalsC.text = (data["goals"] as List).join(", ");
            if (data.containsKey("loans")) {
              _loansC.text = (data["loans"] as List).join(", ");
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Load financials failed: $e");
    }
  }

  // Save Financial Profile
  Future<void> _saveFinancialProfile() async {
    setState(() => _isLoading = true);
    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    try {
      List<String> splitList(String text) => text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final response = await http.post(
        Uri.parse('$baseUrl/money/financial-profile'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "income": int.tryParse(_incomeC.text) ?? 0,
          "expenses": int.tryParse(_expenseC.text) ?? 0,
          "savings": int.tryParse(_savingsC.text) ?? 0,
          "goals": splitList(_goalsC.text),
          "loans": splitList(_loansC.text)
        }),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Financial Profile Saved!")));
        }
      }
    } catch (e) {
      debugPrint("Save financials failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // AI Advisor Call
  Future<void> _askAdvisor() async {
    if (_advisorQC.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/money/advisor'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "question": _advisorQC.text.trim(),
          "transactions": _transactions
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

  // Investment simulated mentor
  Future<void> _runInvestmentAdvisor() async {
    setState(() => _isLoading = true);
    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    try {
      final response = await http.get(Uri.parse('$baseUrl/money/invest-mentor/${widget.userId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _riskAssessment = data["risk_assessment"] ?? "";
          _investOptions = data["options"] ?? [];
          _simulatedPortfolio = data["simulated_portfolio"] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Investment mentor failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Run Subscription Audit
  Future<void> _runSubscriptionAudit() async {
    setState(() => _isLoading = true);
    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/money/subscription-optimizer'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "subscriptions": _subscriptions.map((s) => {
            "name": s["name"],
            "cost": s["cost"],
            "usage": s["usage"]
          }).toList(),
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          _subscriptionAuditResult = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Subscription optimizer failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addExpenseTransaction(String desc, int amt, String cat) {
    setState(() {
      _transactions.add({
        "desc": desc,
        "amount": amt,
        "category": cat,
        "type": "Expense",
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalExpense = _transactions.where((t) => t["type"] == "Expense").fold(0, (sum, item) => sum + (item["amount"] as int));
    int income = int.tryParse(_incomeC.text) ?? 85000;
    double savingsRate = income > 0 ? 1.0 - (totalExpense / income) : 0.0;
    int healthScore = (savingsRate * 100).toInt().clamp(0, 100);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Money Brain", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            Tab(icon: Icon(Icons.dashboard_customize), text: "Dashboard"),
            Tab(icon: Icon(Icons.account_balance_wallet), text: "Genome & Logs"),
            Tab(icon: Icon(Icons.notifications), text: "Bills & Subs"),
            Tab(icon: Icon(Icons.psychology), text: "Advisor & Learn"),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardHubTab(healthScore, totalExpense, savingsRate),
              _buildTrackerTab(),
              _buildBudgetBillsTab(),
              _buildAdvisorTab(),
            ],
          ),
          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                color: Colors.greenAccent,
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDashboardHubTab(int healthScore, int totalExpense, double savingsRate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Financial Health Gauges
          const Text("FINANCIAL HEALTH MONITOR", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF064E3B), Color(0xFF0F172A)]),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Financial Score", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("$healthScore / 100", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.savings, color: Colors.greenAccent, size: 16),
                        const SizedBox(width: 4),
                        Text("Rate: ${(savingsRate * 100).toInt()}%", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.outbox, color: Colors.redAccent, size: 16),
                        const SizedBox(width: 4),
                        Text("Spent: ₹$totalExpense", style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CustomPaint(
                    painter: _ScoreGaugePainter(healthScore.toDouble()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // AI Money Twin Suggestion Bubble
          const Text("AI MONEY TWIN ALERTS", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.warning, color: Colors.amberAccent, size: 20),
                    SizedBox(width: 8),
                    Text("AI Money Twin Coach", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "\"Shash, you've spent 85% of your food budget this week. Also, waiting two weeks on that laptop purchase could save you ₹8,000 on the festival sale!\"",
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 8 Quick Actions Grid (Command Center)
          const Text("MONEY BRAIN MODULES", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _buildGridCard(
                "Expense Tracker",
                "Log & analyze costs",
                Icons.account_balance_wallet,
                Colors.cyanAccent,
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => ExpenseTrackerScreen(userId: widget.userId))),
              ),
              _buildGridCard(
                "Budget & Goals",
                "Plan savings targets",
                Icons.track_changes,
                Colors.amberAccent,
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => BudgetGoalScreen(userId: widget.userId))),
              ),
              _buildGridCard(
                "Decision Simulator",
                "Try purchase impact",
                Icons.psychology,
                Colors.orangeAccent,
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => DecisionSimulatorScreen(userId: widget.userId))),
              ),
              _buildGridCard(
                "Smart Shopping",
                "Price drops & coupons",
                Icons.shopping_bag,
                Colors.tealAccent,
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => SmartShoppingScreen(userId: widget.userId))),
              ),
              _buildGridCard(
                "Scam & Fraud Shield",
                "Scanner & QR checks",
                Icons.security,
                Colors.redAccent,
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => ScamProtectionScreen(userId: widget.userId))),
              ),
              _buildGridCard(
                "AI Money Twin Chat",
                "Consult finance coach",
                Icons.forum,
                Colors.greenAccent,
                () => Navigator.push(context, MaterialPageRoute(builder: (c) => AdvisorTwinScreen(userId: widget.userId))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerTab() {
    final descC = TextEditingController();
    final amtC = TextEditingController();
    final catC = TextEditingController(text: "Food");

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile financials
          const Text("1. FINANCIAL GENOME PROFILE", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: _incomeC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Monthly Income")),
          TextField(controller: _expenseC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Monthly Fixed Expenses")),
          TextField(controller: _savingsC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Goal Savings Target")),
          TextField(controller: _goalsC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Savings Goals (comma separated)")),
          TextField(controller: _loansC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Active Loans / EMIs (comma separated)")),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            initialValue: _riskAppetite,
            dropdownColor: const Color(0xFF1E293B),
            decoration: const InputDecoration(labelText: "Investment Risk Profile"),
            items: ["Conservative", "Moderate", "Aggressive"]
                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white))))
                .toList(),
            onChanged: (v) => setState(() => _riskAppetite = v!),
          ),
          DropdownButtonFormField<String>(
            initialValue: _savingsFocus,
            dropdownColor: const Color(0xFF1E293B),
            decoration: const InputDecoration(labelText: "Financial Focus Preferences"),
            items: ["Emergency Cushion", "Long-term Wealth", "Retirement", "Debt Repayment"]
                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white))))
                .toList(),
            onChanged: (v) => setState(() => _savingsFocus = v!),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveFinancialProfile,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text("Commit Financial Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const Divider(height: 40, color: Colors.white10),

          // Log Transactions
          const Text("2. ADD QUICK TRANSACTION", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: descC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Description (e.g. Coffee)", labelStyle: TextStyle(color: Colors.white60))),
          TextField(controller: amtC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Amount (₹)", labelStyle: TextStyle(color: Colors.white60))),
          DropdownButtonFormField<String>(
            initialValue: catC.text,
            dropdownColor: const Color(0xFF1E293B),
            decoration: const InputDecoration(labelText: "Category", labelStyle: TextStyle(color: Colors.white60)),
            items: ["Food", "Rent", "Bills", "Entertainment", "Travel", "Miscellaneous"]
                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white))))
                .toList(),
            onChanged: (v) => catC.text = v!,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final amt = int.tryParse(amtC.text) ?? 0;
              if (descC.text.isNotEmpty && amt > 0) {
                _addExpenseTransaction(descC.text, amt, catC.text);
                descC.clear();
                amtC.clear();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quick transaction logged!")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Log Transaction", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 24),

          // Recent logs
          const Text("RECENT TRANSACTIONS", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._transactions.reversed.map((t) => Card(
            color: const Color(0xFF1E293B),
            child: ListTile(
              leading: Icon(t["type"] == "Income" ? Icons.add_circle : Icons.remove_circle, color: t["type"] == "Income" ? Colors.greenAccent : Colors.redAccent),
              title: Text(t["desc"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text("Category: ${t["category"]}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
              trailing: Text("₹${t["amount"]}", style: TextStyle(color: t["type"] == "Income" ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBudgetBillsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("MONTHLY BUDGET LIMITS", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Card(
          color: const Color(0xFF1E293B),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Food Budget Tracker", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const LinearProgressIndicator(value: 0.8, color: Colors.orange, backgroundColor: Colors.white12, minHeight: 8),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Spent: ₹4,000", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("Limit: ₹5,000", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text("BILL & EMI REMINDERS", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        ..._bills.map((bill) => Card(
          color: const Color(0xFF1E293B),
          child: CheckboxListTile(
            title: Text(bill["name"], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: bill["paid"] ? TextDecoration.lineThrough : null)),
            subtitle: Text("Amount: ₹${bill["amount"]} • Due: ${bill["due"]}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
            value: bill["paid"],
            activeColor: Colors.green,
            onChanged: (val) {
              setState(() {
                bill["paid"] = val!;
              });
            },
          ),
        )),
        const SizedBox(height: 24),

        // AI Subscription Optimizer Block
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("AI SUBSCRIPTION OPTIMIZER", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ElevatedButton.icon(
              onPressed: _runSubscriptionAudit,
              icon: const Icon(Icons.insights, size: 14),
              label: const Text("Audit Subscriptions", style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._subscriptions.map((sub) => Card(
          color: const Color(0xFF1E293B),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.credit_card, color: Colors.tealAccent),
            title: Text(sub["name"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text("Usage: ${sub["usage"]}", style: const TextStyle(color: Colors.white60, fontSize: 11)),
            trailing: Text("₹${sub["cost"]}/mo", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        )),
        if (_subscriptionAuditResult != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("AUDIT RECOMMENDATIONS", style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      "Est. Savings: ₹${_subscriptionAuditResult!["estimated_savings"]}",
                      style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 16),
                ...(_subscriptionAuditResult!["recommendations"] as List).map((rec) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "• ${rec["subscription"]}: ${rec["action"]} (${rec["reason"]})",
                    style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                  ),
                )),
                const SizedBox(height: 10),
                const Text("Optimizer Tips:", style: TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ...(_subscriptionAuditResult!["optimizer_tips"] as List).map((tip) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text("• $tip", style: const TextStyle(color: Colors.white60, fontSize: 11)),
                )),
              ],
            ),
          )
        ],
      ],
    );
  }

  Widget _buildAdvisorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Financial Advisor Q&A
          const Text("AI FINANCIAL ADVISOR", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _advisorQC,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Ask Financial Advisory details...",
              labelStyle: TextStyle(color: Colors.green),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _askAdvisor,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(_isLoading ? "Processing..." : "Query AI Advisor", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Advisor Response", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_advisorResponse, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const Divider(height: 40, color: Colors.white10),

          // Investment learning
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("INVESTMENT LEARNING & MOCK ALLOCATION", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              ElevatedButton(onPressed: _runInvestmentAdvisor, child: const Text("Run Mentor")),
            ],
          ),
          const SizedBox(height: 16),
          
          // Learning roadmap cards
          const Text("Beginner Learning Modules:", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildLearningCard("SIPs (Systematic Investment Plans)", "Invest fixed amount monthly in mutual funds to average cost and compound interest."),
          _buildLearningCard("Mutual Funds & ETFs", "Pooled investment vehicles tracking indices or baskets of assets. Low-cost diversification."),
          _buildLearningCard("Stocks & Equity", "Direct business ownership shares. Higher volatility, higher wealth growth potential."),
          const SizedBox(height: 16),

          if (_investOptions.isNotEmpty) ...[
            Text("Risk Level Profile: $_riskAssessment", style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._investOptions.map((opt) => Card(
              color: const Color(0xFF1E293B),
              child: ListTile(
                leading: const Icon(Icons.pie_chart, color: Colors.green),
                title: Text(opt["vehicle"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(opt["desc"], style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            )),
            if (_simulatedPortfolio.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text("AI Mock Simulated Portfolio Allocation", style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._simulatedPortfolio.map((item) => Card(
                color: const Color(0xFF1E293B),
                child: ListTile(
                  leading: const Icon(Icons.account_balance, color: Colors.greenAccent),
                  title: Text(item["asset"]?.toString() ?? item.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("Allocation: ${item["allocation"] ?? item["percentage"] ?? ""}%", style: const TextStyle(color: Colors.white70)),
                ),
              )),
            ],
          ]
        ],
      ),
    );
  }

  Widget _buildLearningCard(String title, String desc) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        iconColor: Colors.greenAccent,
        collapsedIconColor: Colors.white60,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
          )
        ],
      ),
    );
  }
}

// Custom Painter for Financial Health Score gauge
class _ScoreGaugePainter extends CustomPainter {
  final double score;
  _ScoreGaugePainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8;

    // Draw background track
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw active score arc
    final sweepAngle = (score / 100) * 2 * math.pi;
    final activePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );

    // Draw central text
    final textSpan = TextSpan(
      text: "${score.toInt()}",
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - (textPainter.width / 2), center.dy - (textPainter.height / 2)),
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreGaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
