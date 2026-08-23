class Analysis {
  final String? error;
  final AnalysisData data;

  const Analysis({this.error, required this.data});

  factory Analysis.queued() {
    return const Analysis(
      data: AnalysisData(
        attributes: AnalysisAttributes(
          status: AnalysisStatus.queued,
          results: {},
        ),
      ),
    );
  }

  factory Analysis.failed({required String error}) {
    return Analysis(
      error: error,
      data: const AnalysisData(
        attributes: AnalysisAttributes(
          status: AnalysisStatus.failed,
          results: {},
        ),
      ),
    );
  }

  factory Analysis.whitelisted({
    String? url,
    String engineName = 'BadBlock Whitelist',
  }) {
    return Analysis(
      data: AnalysisData(
        attributes: AnalysisAttributes(
          status: AnalysisStatus.completed,
          results: {
            engineName: const EngineResult(
              category: 'harmless',
              result: 'clean',
            ),
          },
        ),
      ),
    );
  }

  factory Analysis.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as Map<String, dynamic>? ?? {};
    return Analysis(error: json['error'], data: AnalysisData.fromJson(rawData));
  }

  Map<String, dynamic> toJson() => {
    if (error != null) 'error': error,
    'data': data.toJson(),
  };
}

enum AnalysisStatus {
  queued,
  inProgress,
  completed,
  failed;

  static AnalysisStatus fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'completed' => AnalysisStatus.completed,
      'failed' => AnalysisStatus.failed,
      'in_progress' || 'in-progress' => AnalysisStatus.inProgress,
      _ => AnalysisStatus.queued,
    };
  }

  String get nameString => switch (this) {
    AnalysisStatus.queued => 'queued',
    AnalysisStatus.inProgress => 'in-progress',
    AnalysisStatus.completed => 'completed',
    AnalysisStatus.failed => 'failed',
  };
}

class EngineResult {
  final String? category;
  final String? result;

  const EngineResult({this.category, this.result});

  factory EngineResult.fromJson(Map<String, dynamic> json) {
    return EngineResult(category: json['category'], result: json['result']);
  }

  Map<String, dynamic> toJson() => {'category': category, 'result': result};
}

class AnalysisAttributes {
  final AnalysisStatus status;
  final Map<String, EngineResult> results;

  const AnalysisAttributes({required this.status, required this.results});

  factory AnalysisAttributes.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as Map<String, dynamic>? ?? {};
    final parsedResults = rawResults.map(
      (key, value) => MapEntry(
        key,
        value is Map<String, dynamic>
            ? EngineResult.fromJson(value)
            : const EngineResult(),
      ),
    );

    return AnalysisAttributes(
      status: AnalysisStatus.fromString(json['status']),
      results: parsedResults,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status.nameString,
    'results': results.map((key, value) => MapEntry(key, value.toJson())),
  };
}

class AnalysisData {
  final AnalysisAttributes attributes;

  const AnalysisData({required this.attributes});

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    final rawAttributes = json['attributes'] as Map<String, dynamic>? ?? {};
    return AnalysisData(attributes: AnalysisAttributes.fromJson(rawAttributes));
  }

  Map<String, dynamic> toJson() => {'attributes': attributes.toJson()};
}
