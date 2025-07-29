import '../chat_module.dart';

abstract class SessionProvider {
  Future<String?> getAccessToken();
  Future<String?> getVoipToken();
  Future<String?> getFcmToken();

  Future<bool> isLogged();
  Future<String> getUserId();


  Future<ChatUser?> getCurrentUser();

  Future<bool> isFirstRun();

  Future<void> logout();

  Future<String?> getBackNavigation();
  Future<void> setBackNavigation(String backNavigation);
  Future<void> removeBackNavigation();

  Future<void> saveFcm(String fcm);
  Future<void> saveVoipToken(String voipToken);
  Future<void> saveFirstRun();
}
