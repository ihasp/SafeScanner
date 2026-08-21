import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../modules/security/models/Analysis.dart';

abstract final class AnalysisStatusResolver {
  static FormattedEngineResult formatEngineResult(
    String key,
    String? rawResult,
  ) {
    return switch (rawResult?.toLowerCase()) {
      'malicious' || 'malware' => FormattedEngineResult(
        key: key,
        text: 'Malicious',
        color: AppColors.malicious,
        priority: 1,
      ),
      'phishing' => FormattedEngineResult(
        key: key,
        text: 'Phishing',
        color: AppColors.phishing,
        priority: 2,
      ),
      'suspicious' => FormattedEngineResult(
        key: key,
        text: 'Suspicious',
        color: AppColors.suspicious,
        priority: 3,
      ),
      'clean' || 'harmless' => FormattedEngineResult(
        key: key,
        text: 'Safe',
        color: AppColors.safe,
        priority: 4,
      ),
      'unrated' ||
      'undetected' ||
      'timeout' ||
      'confirmed-timeout' ||
      'failure' ||
      'type-unsupported' ||
      null => FormattedEngineResult(
        key: key,
        text: '',
        color: Colors.transparent,
        priority: 5,
      ),
      _ => FormattedEngineResult(
        key: key,
        text: rawResult ?? '',
        color: Colors.black,
        priority: 6,
      ),
    };
  }

  static ResolvedAnalysisStatus resolve(Analysis analysis) {
    final rawResults = analysis.data.attributes.results;
    final formattedList = <FormattedEngineResult>[];

    rawResults.forEach((key, value) {
      final formatted = formatEngineResult(
        key,
        value.category != null && value.category!.isNotEmpty
            ? value.category
            : value.result,
      );
      if (formatted.text.isNotEmpty) {
        formattedList.add(formatted);
      }
    });

    formattedList.sort((a, b) => a.priority.compareTo(b.priority));

    final maliciousCount = formattedList
        .where((r) => r.text == 'Malicious')
        .length;
    final phishingCount = formattedList
        .where((r) => r.text == 'Phishing')
        .length;
    final suspiciousCount = formattedList
        .where((r) => r.text == 'Suspicious')
        .length;
    final safeCount = formattedList.where((r) => r.text == 'Safe').length;
    final totalCount = formattedList.length;

    final isCompleted =
        analysis.data.attributes.status == AnalysisStatus.completed;
    final hasDangerous =
        maliciousCount > 0 || phishingCount > 0 || suspiciousCount > 0;
    final riskCount = maliciousCount + phishingCount + suspiciousCount;
    final isSafe = isCompleted && !hasDangerous;

    return ResolvedAnalysisStatus(
      sortedResults: formattedList,
      resultCounts: ResultCounts(
        malicious: maliciousCount,
        phishing: phishingCount,
        suspicious: suspiciousCount,
        safe: safeCount,
        total: totalCount,
      ),
      riskCount: riskCount,
      hasDangerousResults: hasDangerous,
      isSafe: isSafe,
      status: analysis.data.attributes.status,
    );
  }
}

class FormattedEngineResult {
  final String key;
  final String text;
  final Color color;
  final int priority;

  const FormattedEngineResult({
    required this.key,
    required this.text,
    required this.color,
    required this.priority,
  });
}

class ResultCounts {
  final int malicious;
  final int phishing;
  final int suspicious;
  final int safe;
  final int total;

  const ResultCounts({
    required this.malicious,
    required this.phishing,
    required this.suspicious,
    required this.safe,
    required this.total,
  });
}

class ResolvedAnalysisStatus {
  final List<FormattedEngineResult> sortedResults;
  final ResultCounts resultCounts;
  final int riskCount;
  final bool hasDangerousResults;
  final bool isSafe;
  final AnalysisStatus status;

  const ResolvedAnalysisStatus({
    required this.sortedResults,
    required this.resultCounts,
    required this.riskCount,
    required this.hasDangerousResults,
    required this.isSafe,
    required this.status,
  });
}
