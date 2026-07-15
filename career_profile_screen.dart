import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class CareerProfileScreen extends StatefulWidget {
  final String userId; 
  
  const CareerProfileScreen({super.key, required this.userId});

  @override
  State<CareerProfileScreen> createState() => _CareerProfileScreenState();
}

class _CareerProfileScreenState extends State<CareerProfileScreen> {
  final _educationController = TextEditingController();
  final _skillsController = TextEditingController();
  final _projectsController = TextEditingController();
  final _goalsController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    setState(() { _isLoading = true; });

    String baseUrl = kIsWeb ? 'http://localhost:8002' : 'http://10.0.2.2:8002';
    
    List<String> splitText(String text) {
      return text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    final profileData = {
      "user_id": widget.userId,
      "education": splitText(_educationController.text),
      "skills": splitText(_skillsController.text),
      "certifications": [], 
      "projects": splitText(_projectsController.text),
      "career_goals": splitText(_goalsController.text),
      "work_experience": [] 
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-profile'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Saved to AI Twin!'), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception('Server rejected the profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Career Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Define Your AI Career Twin", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            const Text(
              "This data acts as the memory for your AI advisor.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            _buildTextField("Education (e.g., B.Tech AI & DS)", _educationController),
            _buildTextField("Skills (Separate with commas)", _skillsController),
            _buildTextField("Projects (Separate with commas)", _projectsController),
            _buildTextField("Career Goals (e.g., AI Engineer)", _goalsController),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Save Profile to Memory', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}