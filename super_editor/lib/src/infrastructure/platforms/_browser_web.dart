import 'dart:js_interop';

/// Returns `true` if the current browser is Safari.
bool get isSafariBrowser {
  final ua = _navigatorUserAgent.toLowerCase();
  return ua.contains('safari') && !ua.contains('chrome');
}

@JS('navigator.userAgent')
external String get _navigatorUserAgent;

