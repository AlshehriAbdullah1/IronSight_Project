import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  ImageHelper({
    ImagePicker? imagePicker,
    ImageCropper? imageCropper,
  })  : _ImagePicker = imagePicker ?? ImagePicker(),
        _ImageCropper = imageCropper ?? ImageCropper();

  final ImagePicker _ImagePicker;

  final ImageCropper _ImageCropper;

  Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 100,
  }) async {
    return await _ImagePicker.pickImage(
      source: source,
      imageQuality: imageQuality,
    );
  }

  Future<CroppedFile?> cropImage({
    required XFile file,
    CropStyle cropStyle = CropStyle.rectangle,
    CropAspectRatio aspectRatio = const CropAspectRatio(ratioX: 1, ratioY: 1),
  }) async {
    return await _ImageCropper.cropImage(
      cropStyle: cropStyle,
      sourcePath: file.path,
      aspectRatio: aspectRatio,
    );
  }
}
