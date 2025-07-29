import 'package:chat_module/chat_module.dart';

import '../domain/typedef.dart';
abstract class ChatRepository {
   ResultFuture<List<Conversation>> getConversations();

  ResultFuture<ChatHistory> getAll(ChatArgs args, {required int page, required int limit});
  ResultFuture<void> markMessagesAsSeen(String roomId);
  ResultFuture<FileUploaded> upload(FileUploadDto data);
}
