import 'dart:io';
import 'package:flutter/material.dart';

class ImageDisplayWidget extends StatelessWidget {
  final File? imageFile;
  final double size;

  const ImageDisplayWidget({
    super.key,
    required this.imageFile,
    this.size = 250,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: const Center(
          child: Text(
            'No image has been selected',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        imageFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}