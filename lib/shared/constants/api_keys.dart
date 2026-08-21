abstract final class ApiKeys {
  static const String virusTotalApiKey = String.fromEnvironment(
    'VIRUSTOTAL_API_KEY',
  );

  static const String tatumApiKey = String.fromEnvironment('TATUM_API_KEY');
}
