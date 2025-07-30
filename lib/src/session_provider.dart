import '../chat_module.dart';

abstract class SessionProvider {
  Future<String?> getAccessToken();


  Future<String> getUserId();


  Future<ChatUser?> getCurrentUser();


}
abstract class BookingInfoProvider {
  Future<List<ChatSpecialty>> getSpecialties();
  Future<ChatDoctor?> getDoctorDetails(int doctorId);
}
