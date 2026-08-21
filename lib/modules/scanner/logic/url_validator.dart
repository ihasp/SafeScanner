abstract final class UrlValidator {
  static final RegExp _domainRegex = RegExp(
    r'^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(?::\d+)?(?:/.*)?$',
  );

  static bool isLikelyUrl(String payload) {
    final sanitized = payload.trim();
    if (sanitized.isEmpty) return false;

    final uri = Uri.tryParse(sanitized);
    if (uri == null) return false;

    if (uri.hasScheme &&
        (uri.scheme == 'http' ||
            uri.scheme == 'https' ||
            uri.scheme == 'ftp') &&
        uri.host.isNotEmpty) {
      return true;
    }

    if (!sanitized.contains('@') &&
        !sanitized.contains(' ') &&
        !sanitized.contains('\n') &&
        !sanitized.startsWith('WIFI:') &&
        !sanitized.startsWith('BEGIN:VCARD') &&
        _domainRegex.hasMatch(sanitized)) {
      return true;
    }

    return false;
  }
}
