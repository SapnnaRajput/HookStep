import 'dart:developer';
import 'package:dancebuddy/utils/app_const.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/string_const.dart';

class GetAPIDataRepository {
  static Future<void> fetchApiKey() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/token/getToken'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        StringConst.apiKey = data['token'];
        log("apiKey ======>>>>. ${StringConst.apiKey}");
      } else {
        log('Failed to fetch apiKey. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching apiKey: $e');
    }
  }
}