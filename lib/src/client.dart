import 'dart:math';
import 'package:http/http.dart' as http;

/// Relay42 Tracking API client (no authentication required).
///
/// Supports:
///  • Engagements  (e=true, et=... , cup=key:value)
///  • Facts        (f=true, ft=... , fttl=..., cup=...)
///  • Mappings     (syncResponse with ca_* params)
///
/// Relay42 tracking API is SAFE for client-side usage.
class Relay42TrackingClient {
  /// Hostname for the tracking API.
  /// Defaults to 't.svtrd.com'.
  final String host;

  /// Your Relay42 site ID (e.g. "1232").
  final String siteId;

  /// HTTP client (can be replaced for testing).
  final http.Client _client;

  Relay42TrackingClient({
    required this.siteId,
    this.host = 't.svtrd.com',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Generates a cachebuster value if none provided.
  String _generateCachebuster() {
    final random = Random();
    return (random.nextInt(1 << 31) + DateTime.now().millisecondsSinceEpoch)
        .toString();
  }

  /// Converts base params + cups into a single encoded query string.
  String _buildQueryString(Map<String, String> params, List<String> cups) {
    final parts = <String>[];

    // Encode base params
    params.forEach((key, value) {
      final encodedKey = Uri.encodeQueryComponent(key);
      final encodedValue = Uri.encodeQueryComponent(value);
      parts.add('$encodedKey=$encodedValue');
    });

    // Encode each CUP parameter separately
    for (final cup in cups) {
      final encodedValue = Uri.encodeQueryComponent(cup);
      parts.add('cup=$encodedValue');
    }

    return parts.join('&');
  }

  /// Sends an Engagement event.
  ///
  /// Example:
  /// https://t.svtrd.com/t-1232?i=UUID&e=true&et=ProductView&cup=productId%3A1630&cb=...
  Future<http.Response> trackEngagement({
    required String uuid,
    required String engagementType,
    Map<String, String> properties = const {},
    String? cachebuster,
  }) async {
    final path = 't-$siteId';

    final params = {
      'i': uuid,
      'e': 'true',
      'et': engagementType,
      'cb': cachebuster ?? _generateCachebuster(),
    };

    final cups =
        properties.entries.map((e) => '${e.key}:${e.value}').toList();

    final query = _buildQueryString(params, cups);
    final url = 'https://$host/$path?$query';

    return _client.get(Uri.parse(url));
  }

  /// Sends a Fact event.
  ///
  /// Example:
  /// https://t.svtrd.com/t-1232?i=UUID&f=true&ft=LastProduct&fttl=1000&cup=LastProduct%3A1630&cb=...
  Future<http.Response> trackFact({
    required String uuid,
    required String factName,
    required int ttlSecs,
    Map<String, String> properties = const {},
    String? cachebuster,
  }) async {
    final path = 't-$siteId';

    final params = {
      'i': uuid,
      'f': 'true',
      'ft': factName,
      'fttl': ttlSecs.toString(),
      'cb': cachebuster ?? _generateCachebuster(),
    };

    final cups =
        properties.entries.map((e) => '${e.key}:${e.value}').toList();

    final query = _buildQueryString(params, cups);
    final url = 'https://$host/$path?$query';

    return _client.get(Uri.parse(url));
  }

  /// Sends a Mapping request.
  ///
  /// Example:
  /// https://t.svtrd.com/syncResponse
  ///   ?ca_site=1232
  ///   &ca_partner=2001
  ///   &ca_cookie=UUID
  ///   &ca_read=pid
  ///   &pid=123456789
  ///   &ca_merge=1
  ///   &cb=...
  Future<http.Response> sendMapping({
    required String uuid,
    required String partnerType,
    required String externalId,
    bool merge = true,
    String? cachebuster,
  }) async {
    const path = 'syncResponse';

    final params = {
      'ca_site': siteId,
      'ca_partner': partnerType,
      'ca_cookie': uuid,
      'ca_read': 'pid',
      'pid': externalId,
      'ca_merge': merge ? '1' : '0',
      'cb': cachebuster ?? _generateCachebuster(),
    };

    final query = _buildQueryString(params, const []);
    final url = 'https://$host/$path?$query';

    return _client.get(Uri.parse(url));
  }

  /// Close the HTTP client.
  void close() => _client.close();
}