/// Notification payloads may open only one public job detail route.
String? jobRouteFromPayload(String? payload) {
  if (payload == null) return null;
  final uri = Uri.tryParse(payload);
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      uri.hasQuery ||
      uri.hasFragment) {
    return null;
  }
  final parts = uri.pathSegments;
  if (parts.length != 2 ||
      parts.first != 'jobs' ||
      !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(parts.last)) {
    return null;
  }
  return '/jobs/${parts.last}';
}
