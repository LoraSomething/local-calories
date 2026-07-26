import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';


class ImagePickerService {

  final ImagePicker _picker = ImagePicker();

  Future<File?> pickAndCropImage(BuildContext context) async {
    // Step 1: Prompt user for image source
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    // If the user dismissed the bottom sheet, stop execution
    if (source == null) return null;

    // Step 2: Pick the image from the selected source
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxHeight: 1000,
      maxWidth: 1000,
      imageQuality: 80,
    );
    if (pickedFile == null) return null; // User canceled picking

    // Step 3: Open the cropping interface
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop the label',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPresetCustom(),
          lockAspectRatio: false,
          showCropGrid: true,             // Ensures lines show up
          cropGridRowCount: 8,
          aspectRatioPresets: <CropAspectRatioPresetData>[
            CropAspectRatioPresetCustom()
          ],
        ),
      ],
    );

    if (croppedFile == null) return null; // User canceled cropping

    // Step 4: Convert CroppedFile to a standard File object and return it
    return File(croppedFile.path);
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 4);

  @override
  String get name => '2x4';
}