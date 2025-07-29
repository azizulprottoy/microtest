import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:shukhee_flutter_app/features/lab/utils/snack_message.dart';
import 'package:url_launcher/url_launcher.dart';

import '../arguments/file_view_argument.dart';

class FileViewController extends GetxController {

  Rx<FileViewArgument> argument = FileViewArgument().obs;

  RxBool fileDownloading = false.obs;

  @override
  void onReady() {
    super.onReady();
    if (Get.arguments != null) {
      argument.value = Get.arguments;
      log('${argument.value.fileType} : ------  ${argument.value.fileUrl}');
    }
  }

  void downloadFile() async {

    if (argument.value.fileUrl != null) {

      fileDownloading.value = true;

      final url = argument.value.fileUrl!;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();

      File file = File("${dir.path}/$filename");
      await file.writeAsBytes(bytes, flush: true);

      fileDownloading.value = false;

      // SnackMessage.showSuccess(title: "File Saved!", message: "Find it in: ${file.path}");
    }
  }

  void openInBrowser() async {
    if (argument.value.fileUrl != null) {
      final url = Uri.parse(argument.value.fileUrl ?? '');
      launchUrl(
          url,
          mode: LaunchMode.externalApplication
      );
    }
  }
}