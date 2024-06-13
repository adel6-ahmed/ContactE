import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<String>> getSuggestedFriends(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/suggest_friends'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      List<dynamic> friends = jsonDecode(response.body);
      return friends.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }
}
