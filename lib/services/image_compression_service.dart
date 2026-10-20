import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageCompressionService {
  static const int maxDimension = 1600;
  static const int jpegQuality = 80;

  /// Redimensiona a imagem para no máximo 1600px mantendo o aspect ratio
  /// e comprime em formato JPEG com qualidade 80.
  static Future<File> compressImage(File sourceFile) async {
    final Uint8List bytes = await sourceFile.readAsBytes();
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return sourceFile;
    }

    img.Image resized = decoded;
    if (decoded.width > maxDimension || decoded.height > maxDimension) {
      if (decoded.width >= decoded.height) {
        resized = img.copyResize(decoded, width: maxDimension);
      } else {
        resized = img.copyResize(decoded, height: maxDimension);
      }
    }

    final List<int> compressedBytes = img.encodeJpg(resized, quality: jpegQuality);

    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath =
        '${tempDir.path}/nf_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File compressedFile = File(tempPath);
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
  }
}
