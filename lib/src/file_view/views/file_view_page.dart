import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../app_enums.dart';
import '../controllers/file_view_controller.dart';

class FileViewPage extends StatelessWidget {
  FileViewPage({super.key});

  final FileViewController controller = Get.put(FileViewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        actions: [
          Obx(() => controller.fileDownloading.value ? Image.asset(
   'assets/loader.gif'   ,
      height: 30,
      width: 30,
    )
              : Container()),
          IconButton(
            onPressed: controller.downloadFile,
            icon: const Icon(Icons.save_outlined),
          ),
          IconButton(
            onPressed: controller.openInBrowser,
            icon: const Icon(Icons.open_in_browser),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Obx(() => controller.argument.value.fileType == AppFileType.pdf ? _pdf(
      controller.argument.value.fileUrl
    ) : controller.argument.value.fileType == AppFileType.image ? _image(
      controller.argument.value.fileUrl
    ) : Center(
      child: Text(
        'Unsupported File Format',
        style: Get.textTheme.labelLarge?.copyWith(
          color: Colors.grey
        ),
      ),
    ));
  }

  Widget _pdf(String? url) {
    return SfPdfViewer.network(
      controller.argument.value.fileUrl ?? '',
    );
  }

  Widget _image(String? url) {
    return PhotoView(
      imageProvider: NetworkImage(
          url ?? ''
      ),
      minScale: PhotoViewComputedScale.contained * 1,
      maxScale: PhotoViewComputedScale.covered * 3,
    );
  }
}
