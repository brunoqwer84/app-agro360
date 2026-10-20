import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:agro360/services/image_compression_service.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  test('Deve comprimir imagem mantendo proporção e limite de 1600px', () async {
    // Cria imagem de teste com 2000 x 1000 pixels (aspect ratio 2:1)
    final original = img.Image(width: 2000, height: 1000);
    img.fill(original, color: img.ColorRgb8(30, 110, 60));
    final pngBytes = img.encodePng(original);

    final tempFile = File('${Directory.systemTemp.path}/test_source_2000x1000.png');
    await tempFile.writeAsBytes(pngBytes);

    final compressedFile = await ImageCompressionService.compressImage(tempFile);

    expect(compressedFile.existsSync(), true);
    final compressedBytes = await compressedFile.readAsBytes();
    expect(compressedBytes, isNotEmpty);

    final decoded = img.decodeImage(compressedBytes);
    expect(decoded, isNotNull);
    // Deve limitar o lado maior a 1600 mantendo a proporção 2:1
    expect(decoded!.width, 1600);
    expect(decoded.height, 800);

    // Limpeza
    if (tempFile.existsSync()) tempFile.deleteSync();
    if (compressedFile.existsSync()) compressedFile.deleteSync();
  });

  test('Deve manter dimensão original se a imagem for menor que 1600px', () async {
    // Imagem 800 x 600
    final original = img.Image(width: 800, height: 600);
    img.fill(original, color: img.ColorRgb8(100, 100, 100));
    final pngBytes = img.encodePng(original);

    final tempFile = File('${Directory.systemTemp.path}/test_source_800x600.png');
    await tempFile.writeAsBytes(pngBytes);

    final compressedFile = await ImageCompressionService.compressImage(tempFile);
    final decoded = img.decodeImage(await compressedFile.readAsBytes());

    expect(decoded, isNotNull);
    expect(decoded!.width, 800);
    expect(decoded.height, 600);

    // Limpeza
    if (tempFile.existsSync()) tempFile.deleteSync();
    if (compressedFile.existsSync()) compressedFile.deleteSync();
  });
}
