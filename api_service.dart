import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator. 
  // If using a physical device, use your local IP (e.g., 192.168.1.XX)
  final String baseUrl = 'http://10.0.2.2:8002'; 

  Future<String> analyzeScenario(String userId, int salary, String skills, bool isRemote) async {
    final url = Uri.parse('$baseUrl/analyze-scenario');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId,
          "salary": salary,
          "skills": skills,
          "is_remote": isRemote
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['decision']; // Returns the AI's analysis
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Connection Error: $e';
    }
  }
}