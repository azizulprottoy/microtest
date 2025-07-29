class ChatArgs {
  int? doctorId;
  int? patientId;
  int? appointmentId;
  bool? isCallPage;
  String? chatId;
  String? roomId;

  ChatArgs({
    this.doctorId,
    this.patientId,
    this.appointmentId,
    this.isCallPage = false,
    this.chatId,
    this.roomId,
  });
}