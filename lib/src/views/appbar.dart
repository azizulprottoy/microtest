import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_module/chat_module.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  ChatAppBar({super.key});

  final ChatController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF9B468A),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          if (controller.isCallPage.value) {
            return;
          }
          Get.back();
        },
      ),
      title: Row(
        children: [
          Obx(() {
            // final profilePic = controller.doctor.value.profilePic;

            return CircleAvatar(
              radius: 22.5,
              backgroundColor: Colors.white,
              // backgroundImage: profilePic != null && profilePic.isNotEmpty
              //     ? NetworkImage(profilePic)
              //     : const AssetImage('assets/images/doctor.png') as ImageProvider,
              backgroundImage: const AssetImage('assets/images/doctor.png') as ImageProvider,
            );
          }),

          const SizedBox(width: 8),
          SizedBox(
            width: Get.width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                      () => Text(
                    // controller.doctor.value.name ?? "Doctor",
              'doctor',
                    overflow: TextOverflow.ellipsis,
                    style: Get.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(() => Text(
                      _status(isOnline: controller.isDoctorOnline.value),
                      style: TextStyle(
                        color: Colors.white ,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )
                    )),
                    const SizedBox(width: 4),
                    Obx(() {
                      return _indicator();
                    }),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      centerTitle: false,
    );
  }

  String _status({required bool isOnline}) {
    return isOnline ? "Online" : "Offline";
  }

  Widget _indicator() {
    if (controller.isDoctorOnline.value) return _onlineIndicator();
    if (!controller.isDoctorOnline.value) return _offlineIndicator();
    return Container();
  }

  Widget _onlineIndicator() {
    return const Icon(
      Icons.circle_rounded,
      color: Colors.greenAccent,
      size: 10,
    );
  }

  Widget _offlineIndicator() {
    return const Icon(
      Icons.circle_rounded,
      color: Colors.white,
      size: 10,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
