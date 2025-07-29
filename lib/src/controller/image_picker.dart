import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

showImagePickerDialog(Function(ImageSource) open) {
  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              open(ImageSource.gallery);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  Icon(Icons.browse_gallery_rounded, color: Color(0xFF9B468A)),
                  SizedBox(height: 4),
                  Text(
                    'Gallery',
                    style: TextStyle(color: Color(0xFF9B468A)),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              open(ImageSource.camera);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  Icon(Icons.camera_alt_rounded, color: Color(0xFF9B468A)),
                  SizedBox(height: 4),
                  Text(
                    'Camera',
                    style: TextStyle(color: Color(0xFF9B468A)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class ImagePickerWithDialog extends StatelessWidget {
  final Widget child;
  final Function(File) onUpload;

  const ImagePickerWithDialog({
    super.key,
    required this.child,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showImagePickerDialog(_open);
      },
      child: child,
    );
  }

  Future _open(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(
      source: source,
      maxWidth: 400,
    );

    if (img != null) {
      onUpload(File(img.path));
    }

    Get.back();
  }
}
