import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../constants/api_keys.dart';
import '../../../constants/app_constants.dart';
import '../models/analysis_model.dart';

sealed class VirusTotalException implements Exception {
  final String message;
  final int? statusCode;

  const VirusTotalException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class VirusTotalAuthException extends VirusTotalException {
  const VirusTotalAuthException([
    String message = 'Invalid or missing VirusTotal API key.',
  ]) : super(message, 401);
}

class VirusTotalRateLimitException extends VirusTotalException {
  const VirusTotalRateLimitException([
    String message =
        'VirusTotal rate limit exceeded. Please try again in a moment.',
  ]) : super(message, 429);
}

class VirusTotalNotFoundException extends VirusTotalException {
  const VirusTotalNotFoundException([
    String message = 'Analysis report not found on VirusTotal.',
  ]) : super(message, 404);
}

class VirusTotalBadRequestException extends VirusTotalException {
  const VirusTotalBadRequestException([
    String message = 'Invalid URL format submitted to VirusTotal.',
  ]) : super(message, 400);
}

class VirusTotalForbiddenException extends VirusTotalException {
  const VirusTotalForbiddenException([
    String message = 'Access to VirusTotal API was forbidden.',
  ]) : super(message, 403);
}

class VirusTotalServerException extends VirusTotalException {
  const VirusTotalServerException([
    String message = 'VirusTotal service is temporarily unavailable.',
  ]) : super(message, 500);
}

class VirusTotalGenericException extends VirusTotalException {
  const VirusTotalGenericException(super.message, [super.statusCode]);
}

class VirusTotalService {
  final http.Client _client;
  final String _apiKey;

  VirusTotalService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? ApiKeys.virusTotalApiKey;

  void _handleStatusCode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    switch (response.statusCode) {
      case 400:
        throw const VirusTotalBadRequestException();
      case 401:
        throw const VirusTotalAuthException();
      case 403:
        throw const VirusTotalForbiddenException();
      case 404:
        throw const VirusTotalNotFoundException();
      case 429:
        throw const VirusTotalRateLimitException();
      case 500 || 502 || 503 || 504:
        throw const VirusTotalServerException();
      default:
        throw VirusTotalGenericException(
          'VirusTotal request failed with status ${response.statusCode}',
          response.statusCode,
        );
    }
  }

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

    _handleStatusCode(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>?;
    final analysisId = data?['id'] as String?;

    if (analysisId == null || analysisId.isEmpty) {
      throw const VirusTotalGenericException(
        'VirusTotal did not return an analysis id.',
      );
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

    _handleStatusCode(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Analysis.fromJson(decoded);
  }

  void close() {
    _client.close();
  }
}

