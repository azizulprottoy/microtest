import 'package:get/get.dart';

import '../chat_module.dart';



class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}