import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../shared/constants/api_keys.dart';
import '../../security/logic/analysis_status_resolver.dart';
import '../../security/logic/decision_maker.dart';
import '../../security/models/analysis.dart';
import '../../security/models/crypto_decision.dart';
import '../../security/models/crypto_wallet_scan.dart';
import '../models/ai_security_explanation.dart';

class GeminiAiService {
  final String _defaultApiKey;

  const GeminiAiService({String? apiKey})
    : _defaultApiKey = apiKey ?? ApiKeys.geminiApiKey;

  String _resolveApiKey(String? customApiKey) {
    if (customApiKey != null && customApiKey.trim().isNotEmpty) {
      return customApiKey.trim();
    }
    return _defaultApiKey.trim();
  }

  static String _normalizeModel(String model) {
    return model.trim().replaceFirst(RegExp(r'^models/'), '');
  }

  static String _resolveLanguageName(String code) {
    return switch (code.toLowerCase().trim()) {
      'pl' => 'Polish (Polski)',
      'de' => 'German (Deutsch)',
      'es' => 'Spanish (Español)',
      'fr' => 'French (Français)',
      'it' => 'Italian (Italiano)',
      'pt' => 'Portuguese (Português)',
      _ => 'English',
    };
  }

  GenerativeModel _createModel(String apiKey, String modelName) {
    return GenerativeModel(
      model: _normalizeModel(modelName),
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.2,
      ),
      systemInstruction: Content.system(
        'You are an expert cybersecurity advisor in a mobile QR and Crypto Scanner app. '
        'Your goal is to provide concise, non-technical, high-signal security explanations '
        'to everyday users who just scanned a QR code, link, or crypto address.\n'
        'When the scanner flags an item as not safe, malicious, phishing, or unverified, '
        'prioritize explaining the exact risk, why it was flagged, and actionable steps to protect assets or private data.\n'
        'Respond ONLY with valid JSON matching this exact structure:\n'
        '{\n'
        '  "headline": "Short punchy verdict (e.g. Malicious Wallet Drainer Flagged)",\n'
        '  "summary": "2-3 sentences explaining in simple words what this is, why it is safe/dangerous, and what will happen if interacted with.",\n'
        '  "riskLevel": "safe" | "warning" | "malicious" | "unverified",\n'
        '  "keyFindings": ["Point 1", "Point 2"],\n'
        '  "recommendedAction": "Single clear actionable sentence for the user."\n'
        '}\n'
        'CRITICAL: Always write the entire JSON response values in the exact language requested in the prompt.',
      ),
    );
  }

  Future<AiSecurityExplanation> explainUrlScan({
    required String url,
    required Analysis analysis,
    required String languageCode,
    String? customApiKey,
  }) async {
    final apiKey = _resolveApiKey(customApiKey);
    if (apiKey.isEmpty) {
      throw const GeminiMissingApiKeyException();
    }

    final resolved = AnalysisStatusResolver.resolve(analysis);
    final maliciousEngines = resolved.sortedResults
        .where((r) => r.priority <= 3)
        .map((r) => '${r.key}: ${r.text}')
        .take(10)
        .toList();

    final isNotSafe = resolved.verdict != AnalysisVerdict.safe;
    final langName = _resolveLanguageName(languageCode);

    final promptData = {
      'targetType': 'url',
      'url': url,
      'verdict': resolved.verdict.name,
      'isFlaggedUnsafe': isNotSafe,
      'targetLanguage': langName,
      'targetLanguageCode': languageCode,
      'stats': {
        'totalEnginesChecked': resolved.resultCounts.total,
        'maliciousCount': resolved.resultCounts.malicious,
        'phishingCount': resolved.resultCounts.phishing,
        'suspiciousCount': resolved.resultCounts.suspicious,
        'safeCount': resolved.resultCounts.safe,
      },
      'flaggedEngines': maliciousEngines,
      if (isNotSafe)
        'scannerThreatAlert': {
          'status': resolved.verdict.name,
          'threatDescription': resolved.verdict == AnalysisVerdict.malicious
              ? 'Automated security scan flagged this URL as MALICIOUS/PHISHING. Instruct the user not to open or enter passwords.'
              : 'Automated security scan found suspicious flags for this URL. Advise extreme caution.',
        },
    };

    final prompt =
        'Analyze this scanned URL scan result and explain it to the user.\n'
        'CRITICAL INSTRUCTION: You MUST write the entire JSON response (headline, summary, keyFindings, recommendedAction) in $langName language.\n'
        'Scan data:\n${jsonEncode(promptData)}';

    return _generateExplanation(apiKey, prompt);
  }

  Future<AiSecurityExplanation> explainCryptoScan({
    required CryptoWalletScan scan,
    required String languageCode,
    String? customApiKey,
  }) async {
    final apiKey = _resolveApiKey(customApiKey);
    if (apiKey.isEmpty) {
      throw const GeminiMissingApiKeyException();
    }

    final decision = DecisionMaker.decide(scan);
    final isNotSafe = decision.safetyLevel != CryptoSafetyLevel.safe;
    final langName = _resolveLanguageName(languageCode);

    final assetsSummary = scan.assets
        .take(10)
        .map((a) => '${a.metadata?.name ?? a.symbol ?? a.type}: ${a.balance}')
        .toList();

    final promptData = {
      'targetType': 'crypto_wallet',
      'address': scan.wallet.address,
      'network': scan.wallet.label,
      'chain': scan.wallet.chain.value,
      'nativeBalance': scan.nativeBalance?.balance ?? '0',
      'assetsCount': scan.assets.length,
      'assetsPreview': assetsSummary,
      'scannerSafetyVerdict': decision.safetyLevel.name,
      'isFlaggedUnsafe': isNotSafe,
      'threatReasons': decision.reasons,
      'threatSignals': decision.signals ?? [],
      if (scan.safety.description != null)
        'threatDescription': scan.safety.description,
      if (scan.safety.source != null) 'threatSource': scan.safety.source,
      if (isNotSafe)
        'scannerThreatAlert': {
          'threatLevel': decision.safetyLevel.name,
          'instruction': decision.safetyLevel == CryptoSafetyLevel.malicious
              ? 'CRITICAL ALERT: The security scanner identified this address as MALICIOUS (e.g. scam, drainer, or blacklist). Emphasize that transferring crypto or signing transactions will lead to permanent fund loss.'
              : 'CAUTION: The security scanner identified this address as UNVERIFIED with no trusted security verification. Remind the user to double check before sending funds.',
        },
      'targetLanguage': langName,
      'targetLanguageCode': languageCode,
    };

    final prompt =
        'Analyze this scanned cryptocurrency wallet address and explain it to the user.\n'
        'CRITICAL INSTRUCTION: You MUST write the entire JSON response (headline, summary, keyFindings, recommendedAction) in $langName language.\n'
        'Scan data:\n${jsonEncode(promptData)}';

    return _generateExplanation(apiKey, prompt);
  }

  Future<AiSecurityExplanation> _generateExplanation(
    String apiKey,
    String prompt,
  ) async {
    const candidateModels = [
      'gemini-3.6-flash',
      'gemini-3.7-flash',
      'gemini-3.5-flash-lite',
      'gemini-2.5-flash',
      'gemini-1.5-flash',
    ];

    Object? lastError;
    StackTrace? lastStackTrace;

    for (final candidate in candidateModels) {
      try {
        final model = _createModel(apiKey, candidate);
        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text;

        if (text == null || text.trim().isEmpty) {
          throw const GeminiEmptyResponseException();
        }

        final Object? decoded = jsonDecode(text.trim());
        if (decoded is! Map<String, dynamic>) {
          throw const GeminiInvalidJsonException();
        }

        return AiSecurityExplanation.fromJson(decoded);
      } on GeminiException {
        rethrow;
      } catch (e, st) {
        lastError = e;
        lastStackTrace = st;
        final errorStr = e.toString().toLowerCase();

        // If the model is not found/deprecated, try next model candidate
        if (errorStr.contains('not found') ||
            errorStr.contains('not supported') ||
            errorStr.contains('is no longer available') ||
            errorStr.contains('404')) {
          continue;
        }

        if (errorStr.contains('api_key_invalid') ||
            errorStr.contains('invalid api key') ||
            errorStr.contains('api key not found') ||
            errorStr.contains('403') ||
            errorStr.contains('unauthenticated')) {
          Error.throwWithStackTrace(const GeminiInvalidApiKeyException(), st);
        }
        if (errorStr.contains('429') ||
            errorStr.contains('resource_exhausted') ||
            errorStr.contains('quota')) {
          Error.throwWithStackTrace(const GeminiRateLimitException(), st);
        }

        Error.throwWithStackTrace(
          GeminiGenericException('Gemini analysis failed: $e'),
          st,
        );
      }
    }

    if (lastError != null && lastStackTrace != null) {
      Error.throwWithStackTrace(
        GeminiGenericException('Gemini analysis failed: $lastError'),
        lastStackTrace,
      );
    }

    throw const GeminiGenericException('Gemini analysis failed.');
  }
}

sealed class GeminiException implements Exception {
  final String message;
  const GeminiException(this.message);

  @override
  String toString() => message;
}

class GeminiMissingApiKeyException extends GeminiException {
  const GeminiMissingApiKeyException([
    super.message =
        'Gemini API key is not configured. Please supply GEMINI_API_KEY.',
  ]);
}

class GeminiInvalidApiKeyException extends GeminiException {
  const GeminiInvalidApiKeyException([
    super.message = 'The provided Gemini API key is invalid or unauthorized.',
  ]);
}

class GeminiRateLimitException extends GeminiException {
  const GeminiRateLimitException([
    super.message =
        'Gemini request limit reached. Please wait a moment and try again.',
  ]);
}

class GeminiEmptyResponseException extends GeminiException {
  const GeminiEmptyResponseException([
    super.message = 'Gemini returned an empty response.',
  ]);
}

class GeminiInvalidJsonException extends GeminiException {
  const GeminiInvalidJsonException([
    super.message = 'Failed to parse Gemini response format.',
  ]);
}

class GeminiGenericException extends GeminiException {
  const GeminiGenericException(super.message);
}
