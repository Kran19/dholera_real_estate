import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// Cross-Platform Picked Image Model (Web + Mobile compatible)
/// DHOLERA REAL ESTATE
class AppPickedImage {
  final XFile xfile;
  final Uint8List bytes;
  final String name;

  AppPickedImage({
    required this.xfile,
    required this.bytes,
    required this.name,
  });
}
