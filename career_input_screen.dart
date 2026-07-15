import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'vault_viewer_screen.dart';

class CareerInputScreen extends StatefulWidget {
  const CareerInputScreen({super.key});

  @override
  State<CareerInputScreen> createState() => _CareerInputScreenState();
}

class _CareerInputScreenState extends State<CareerInputScreen> {
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  bool _isRemote = true;
  bool _isLoading = false;

  final String _baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';

  Future<void> _analyzeCareerProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze-scenario'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": "test_user",
          "salary": int.tryParse(_salaryController.text) ?? 0,
          "skills": _skillsController.text,
          "is_remote": _isRemote,
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _showResultDialog(data['decision']);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadFile() async {
    setState(() => _isLoading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true,
      );
      if (result == null || result.files.single.bytes == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload-doc'));
      request.files.add(http.MultipartFile.fromBytes('file', result.files.single.bytes!, filename: result.files.single.name));
      var response = await request.send();
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File Uploaded!")));
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResultDialog(String decision) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("AI Analysis Result"),
        content: Text(decision),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Career Brain")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _skillsController, decoration: const InputDecoration(labelText: "Skills")),
            TextField(controller: _salaryController, decoration: const InputDecoration(labelText: "Salary")),
            SwitchListTile(title: const Text("Remote?"), value: _isRemote, onChanged: (val) => setState(() => _isRemote = val)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _isLoading ? null : _pickAndUploadFile, child: const Text("Upload Resume")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _isLoading ? null : _analyzeCareerProfile, child: const Text("Analyze Scenario")),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VaultViewerScreen())), child: const Text("View Vault")),
          ],
        ),
      ),
    );
  }
}