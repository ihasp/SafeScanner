class AiSecurityExplanation {
  final String headline;
  final String summary;
  final AiRiskLevel riskLevel;
  final List<String> keyFindings;
  final String recommendedAction;
  final DateTime generatedAt;

  const AiSecurityExplanation({
    required this.headline,
    required this.summary,
    required this.riskLevel,
    required this.keyFindings,
    required this.recommendedAction,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
    'headline': headline,
    'summary': summary,
    'riskLevel': riskLevel.nameString,
    'keyFindings': keyFindings,
    'recommendedAction': recommendedAction,
    'generatedAt': generatedAt.toIso8601String(),
  };

  factory AiSecurityExplanation.fromJson(Map<String, dynamic> json) {
    final rawFindings = json['keyFindings'] as List<Object?>? ?? [];
    return AiSecurityExplanation(
      headline: json['headline'] as String? ?? 'Security Analysis',
      summary: json['summary'] as String? ?? '',
      riskLevel: AiRiskLevel.fromString(json['riskLevel'] as String?),
      keyFindings: rawFindings
          .map((e) => e?.toString())
          .whereType<String>()
          .toList(),
      recommendedAction: json['recommendedAction'] as String? ?? '',
      generatedAt:
          DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  AiSecurityExplanation copyWith({
    String? headline,
    String? summary,
    AiRiskLevel? riskLevel,
    List<String>? keyFindings,
    String? recommendedAction,
    DateTime? generatedAt,
  }) {
    return AiSecurityExplanation(
      headline: headline ?? this.headline,
      summary: summary ?? this.summary,
      riskLevel: riskLevel ?? this.riskLevel,
      keyFindings: keyFindings ?? this.keyFindings,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}

enum AiRiskLevel {
  safe,
  warning,
  malicious,
  unverified;

  static AiRiskLevel fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'safe' || 'clean' || 'low' => AiRiskLevel.safe,
      'warning' || 'suspicious' || 'medium' => AiRiskLevel.warning,
      'malicious' ||
      'dangerous' ||
      'critical' ||
      'high' => AiRiskLevel.malicious,
      _ => AiRiskLevel.unverified,
    };
  }

  String get nameString => switch (this) {
    AiRiskLevel.safe => 'safe',
    AiRiskLevel.warning => 'warning',
    AiRiskLevel.malicious => 'malicious',
    AiRiskLevel.unverified => 'unverified',
  };
}
