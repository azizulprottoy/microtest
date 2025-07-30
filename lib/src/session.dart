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

class  BookingInfo{
  static BookingInfoProvider? _provider;

  static void inject(BookingInfoProvider provider) {
    _provider = provider;
  }

  static BookingInfoProvider get provider {
    if (_provider == null) {
      throw Exception("SessionProvider not injected!");
    }
    return _provider!;
  }
}