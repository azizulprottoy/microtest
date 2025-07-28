// chat_module/lib/src/session.dart
import 'session_provider.dart';

class Session {
  static SessionProvider? _provider;

  static void inject(SessionProvider provider) {
    _provider = provider;
  }

  static SessionProvider get provider {
    if (_provider == null) {
      throw Exception("SessionProvider not injected!");
    }
    return _provider!;
  }
}
