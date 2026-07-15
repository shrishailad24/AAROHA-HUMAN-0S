import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ResumeBuilderScreen extends StatefulWidget {
  final String userId;
  const ResumeBuilderScreen({super.key, required this.userId});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final TextEditingController _jdController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _versionNameController = TextEditingController();

  bool _isAnalyzing = false;
  bool _isGeneratingLetter = false;

  int? _atsScore;
  List<dynamic> _missingKeywords = [];
  List<dynamic> _improvements = [];
  String _generatedCoverLetter = "";
  Map<String, dynamic> _savedVersions = {};

  @override
  void initState() {
    super.initState();
    _loadResumeVersions();
  }

  Future<void> _loadResumeVersions() async {
    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    try {
      final response = await http.get(Uri.parse('$baseUrl/list-resume-versions/${widget.userId}'));
      if (response.statusCode == 200) {
        setState(() {
          _savedVersions = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error loading versions: $e");
    }
  }

  Future<void> _runATSCheck() async {
    if (_jdController.text.trim().isEmpty) return;
    setState(() { _isAnalyzing = true; });

    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-ats'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "job_description": _jdController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _atsScore = data['ats_score'];
          _missingKeywords = data['missing_keywords'] ?? [];
          _improvements = data['improvements'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("ATS check failed: $e");
    } finally {
      setState(() { _isAnalyzing = false; });
    }
  }

  Future<void> _createCoverLetter() async {
    if (_jdController.text.trim().isEmpty || _companyController.text.isEmpty || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Company, Title, and Job Description first!')),
      );
      return;
    }
    setState(() { _isGeneratingLetter = true; });

    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-cover-letter'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "company_name": _companyController.text.trim(),
          "job_title": _titleController.text.trim(),
          "job_description": _jdController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _generatedCoverLetter = jsonDecode(response.body)['cover_letter'] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Cover Letter optimization failed: $e");
    } finally {
      setState(() { _isGeneratingLetter = false; });
    }
  }

  Future<void> _saveVariant(String name) async {
    if (name.trim().isEmpty) return;
    final String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save-resume-version'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "version_name": name.trim(),
          "resume_data": {
            "target_role": _titleController.text,
            "target_company": _companyController.text,
            "associated_score": _atsScore ?? 0,
            "optimized_on": DateTime.now().toIso8601String()
          }
        }),
      );

      if (response.statusCode == 200) {
        _versionNameController.clear();
        _loadResumeVersions();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Failed saving custom profile matrix: $e");
    }
  }

  void _showSaveVariantDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Variant Configuration'),
        content: TextField(
          controller: _versionNameController,
          decoration: const InputDecoration(
            hintText: 'e.g., Senior Dev - Google Variant',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => _saveVariant(_versionNameController.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('Commit Version'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Resume & Application Suite'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Input Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              key: const ValueKey('input_card'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎯 Job Context Engine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _companyController,
                          decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Job Title', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _jdController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Paste Target Job Description Here',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isAnalyzing ? null : _runATSCheck,
                          icon: const Icon(Icons.analytics),
                          label: Text(_isAnalyzing ? 'Scanning...' : 'Analyze ATS Score'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isGeneratingLetter ? null : _createCoverLetter,
                          icon: const Icon(Icons.auto_awesome),
                          label: Text(_isGeneratingLetter ? 'Writing...' : 'Draft Cover Letter'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ATS Scoring & Improvements View
          if (_atsScore != null) ...[
            Card(
              color: const Color(0xFF0F172A), // Tailwind Slate 900 Fixed Hex
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('ATS Alignment Optimization Metric', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('$_atsScore%', style: TextStyle(color: _atsScore! >= 75 ? Colors.greenAccent : Colors.amberAccent, fontSize: 44, fontWeight: FontWeight.w900)), // Fixed weight to w900
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: _atsScore! / 100, color: _atsScore! >= 75 ? Colors.greenAccent : Colors.amberAccent, backgroundColor: Colors.white24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_missingKeywords.isNotEmpty) ...[
              const Text('⚠️ Crucial Missing Keywords', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: _missingKeywords.map((tag) => Chip(label: Text(tag.toString()), backgroundColor: Colors.red.shade50)).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (_improvements.isNotEmpty) ...[
              const Text('💡 Resume Enhancements Required', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 6),
              ..._improvements.map((tip) => ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: Colors.indigo),
                    title: Text(tip.toString(), style: const TextStyle(fontSize: 13)),
                  )),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _showSaveVariantDialog,
                icon: const Icon(Icons.bookmark_added),
                label: const Text('Save This Variant Base'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              ),
              const SizedBox(height: 20),
            ],
          ],

          // Dynamic Cover Letter Workspace Area
          if (_generatedCoverLetter.isNotEmpty) ...[
            const Text('📄 Generated Custom Cover Letter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_generatedCoverLetter, style: const TextStyle(fontFamily: 'Courier', fontSize: 13, height: 1.4)),
                    const Divider(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _generatedCoverLetter));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to Clipboard!')));
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Output Text'),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Historical Role Revisions View Catalog
          if (_savedVersions.isNotEmpty) ...[
            const Text('📂 Tailored Role Variants Vault', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._savedVersions.entries.map((item) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.history_edu, color: Colors.indigo),
                    title: Text(item.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Target: ${item.value['target_role']} @ ${item.value['target_company']}\nScore: ${item.value['associated_score']}%"),
                    isThreeLine: true,
                  ),
                )),
          ],
        ],
      ),
    );
  }
}