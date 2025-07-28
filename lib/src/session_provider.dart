

abstract class SessionProvider {
  Future<String?> getAccessToken();
  Future<String?> getVoipToken();
  Future<String?> getFcmToken();
}


//
// abstract class SessionProvider {
//   Future<String?> getAccessToken();
//   Future<String?> getVoipToken();
//   Future<String?> getFcmToken();
//
//   Future<bool> isLogged();
//   Future<String> getUserId();
//   Future<UserModel?> getUser();
//
//   Future<bool> isFirstRun();
//
//   Future<void> logout();
//
//   Future<String?> getBackNavigation();
//   Future<void> setBackNavigation(String backNavigation);
//   Future<void> removeBackNavigation();
//
//   Future<void> saveFcm(String fcm);
//   Future<void> saveVoipToken(String voipToken);
//   Future<void> saveFirstRun();
// }
