abstract final class QrPayloadParser {
  static String sanitize(String rawPayload) {
    return rawPayload.trim();
  }

  static bool isValid(String? rawPayload) {
    if (rawPayload == null) return false;
    return rawPayload.trim().isNotEmpty;
  }
}
