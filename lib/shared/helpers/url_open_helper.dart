import 'package:url_launcher/url_launcher_string.dart';

abstract final class UrlOpenHelper {
  static String formatUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return trimmed;

    final lower = trimmed.toLowerCase();
    if (!lower.startsWith('http://') &&
        !lower.startsWith('https://') &&
        !lower.startsWith('ftp://')) {
      return 'https://$trimmed';
    }
    return trimmed;
  }

  static Future<bool> openUrl(String rawUrl) async {
    final formatted = formatUrl(rawUrl);
    if (formatted.isEmpty) return false;

    try {
      final launched = await launchUrlString(
        formatted,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        return await launchUrlString(
          formatted,
          mode: LaunchMode.platformDefault,
        );
      }
      return true;
    } catch (_) {
      try {
        return await launchUrlString(
          formatted,
          mode: LaunchMode.inAppBrowserView,
        );
      } catch (_) {
        return false;
      }
    }
  }
}
