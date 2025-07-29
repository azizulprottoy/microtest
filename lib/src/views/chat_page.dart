import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:chat_module/chat_module.dart';

class ChatPage extends StatelessWidget {
  final ChatController controller = Get.find();
  final ChatArgs chatArgs;

  ChatPage(this.chatArgs, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF6F9),
      appBar: ChatAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages = controller.messages;

              return ListView.builder(
                controller: controller.scrollController,

                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isSelf = msg.senderType == 'patient';
                  final isImage = msg.type == 'image' &&
                      (msg.mimeType?.startsWith('image/') ?? false);
                  final messageWidget = _buildMessage(context, msg);

                  final showDateHeader = _shouldShowDateHeader(messages, index);
                  final dateWidget = showDateHeader && msg.createdAt != null
                      ? _buildDateHeader(msg.createdAt!)
                      : null;

                  final messageBubble = Align(
                    alignment:
                        isSelf ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.85),
                      child: isImage
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 6),
                              child: messageWidget,
                            )
                          : Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelf? Color(0xFF9B468A) : Colors.white,
                                borderRadius: isSelf
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(0),
                                      )
                                    : const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(12),
                                      ),
                              ),
                              child: messageWidget,
                            ),
                    ),
                  );

                  if (showDateHeader && dateWidget != null) {
                    return Column(
                      children: [
                        dateWidget,
                        messageBubble,
                      ],
                    );
                  } else {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          messageBubble,
                          Obx(() {
                            if (!controller.isDoctorTyping.value) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: SizedBox(
                                    height: 20,
                                    width: 50,
                                    child: DefaultTextStyle(
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      child: AnimatedTextKit(
                                        repeatForever: true,
                                        pause: const Duration(milliseconds: 200),
                                        isRepeatingAnimation: true,
                                        animatedTexts: [
                                          TyperAnimatedText('Typing...', speed: const Duration(milliseconds: 100)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    } else {
                      return messageBubble;
                    }

                  }
                },
              );
            }),
          ),
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, Message msg) {
    final isSelf = msg.senderType == 'patient';

    if (msg.type == 'text') {
      return Text(
        msg.text ?? '',
        textAlign: isSelf ? TextAlign.end : TextAlign.start,
        style: TextStyle(fontSize: 16,
            color:  isSelf? Colors.white : Colors.black,),
      );
    }

    if (msg.type == 'file' || msg.type == 'image') {
      final mime = msg.mimeType ?? '';

      if (mime.startsWith('image/')) {
        return GestureDetector(
          onTap: () => controller.handleMessageTap(context, msg),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              msg.uri ?? '',
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                color: Color(0xFF9B468A),
                size: 48,
              ),
            ),
          ),
        );
      }

      if (mime.startsWith('video/')) {
        return GestureDetector(
          onTap: () => controller.handleMessageTap(context, msg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Icon(Icons.videocam, color:  isSelf? Colors.white : Color(0xFF9B468A),),
              SizedBox(width:8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.name ?? 'Video',
                      style: TextStyle(color:  isSelf? Colors.white : Colors.black,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${(msg.size ?? 0) ~/ 1024} KB',
                      style:  TextStyle(color:  isSelf? Colors.white : Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return GestureDetector(
        onTap: () => controller.handleMessageTap(context, msg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Icon(Icons.insert_drive_file, color:  isSelf? Colors.white : Color(0xFF9B468A),),
            SizedBox(width:8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.name ?? 'File',
                    style:  TextStyle(color:  isSelf? Colors.white : Colors.black,),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${(msg.size ?? 0) ~/ 1024} KB',
                    style: TextStyle(color:  isSelf? Colors.white : Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const Text("Unsupported message type");
  }

  Widget _buildInputBar(BuildContext context) {
    final TextEditingController inputController = TextEditingController();

    return SafeArea(
      bottom: false,

      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 4,top: 4,right: 4,bottom: 20),
        child: Row(
          children: [
            IconButton(
              icon: SvgPicture.asset(
'assets/attach.svg',
                color: Color(0xFF9B468A),
                width: 24,
                height: 24,
              ),
              onPressed: controller.handleFileSelection,
            ),
            IconButton(
              icon:  Icon(Icons.image, color: Color(0xFF9B468A)),
              onPressed: controller.handleImageSelection,
            ),
            Expanded(
              child: TextField(
                controller: inputController,
                onChanged: controller.handleTyping,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            IconButton(
                icon: SvgPicture.asset(
                  'assets/send.svg',
                  color: Color(0xFF9B468A),
                  width: 24,
                  height: 24,
                ),
                onPressed: () {
                  final text = inputController.text.trim();
                  if (text.isNotEmpty) {
                    controller.handleSendPressed(text);
                    controller.stopTyping();
                    inputController.clear();
                  }
                }),
          ],
        ),
      ),
    );
  }
}

bool _shouldShowDateHeader(List<Message> messages, int index) {
  if (index == messages.length - 1) return true;

  final current = messages[index].createdAt;
  final next = messages[index + 1].createdAt;

  if (current == null || next == null) return false;

  return !_isSameDay(current, next);
}

bool _isSameDay(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

Widget _buildDateHeader(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final messageDate = DateTime(date.year, date.month, date.day);

  String label;
  if (messageDate == today) {
    label = 'Today';
  } else if (messageDate == yesterday) {
    label = 'Yesterday';
  } else {
    label = '${date.day}/${date.month}/${date.year}';
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          color: Color(0xFF9B468A).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ),
    ),
  );
}
