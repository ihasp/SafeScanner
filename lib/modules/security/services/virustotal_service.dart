import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../constants/api_keys.dart';
import '../../../constants/app_constants.dart';
import '../models/analysis_model.dart';

class VirusTotalService {
  final http.Client _client;
  final String _apiKey;

  VirusTotalService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? ApiKeys.virusTotalApiKey;

  Future<String> scanUrl(String url) async {
    final uri = Uri.parse('${AppConstants.virustotalApiUrl}/urls');
    final response = await _client.post(
      uri,
      headers: {
        'accept': 'application/json',
        'content-type': 'application/x-www-form-urlencoded',
        'x-apikey': _apiKey,
      },
      body: {'url': url},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'VirusTotal scan failed with status ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>?;
    final analysisId = data?['id'] as String?;

    if (analysisId == null || analysisId.isEmpty) {
      throw Exception('VirusTotal did not return an analysis id.');
    }

    return analysisId;
  }

  Future<Analysis> getAnalysis(String analysisId) async {
    final uri = Uri.parse(
      '${AppConstants.virustotalApiUrl}/analyses/$analysisId',
    );
    final response = await _client.get(
      uri,
      headers: {'accept': 'application/json', 'x-apikey': _apiKey},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'VirusTotal analysis failed with status ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Analysis.fromJson(decoded);
  }
}
