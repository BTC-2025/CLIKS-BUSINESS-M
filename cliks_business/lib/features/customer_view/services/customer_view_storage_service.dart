import 'dart:convert';
import 'dart:io';
import '../models/customer_view_settings_model.dart';

class CustomerViewStorageService {
  static final CustomerViewStorageService _instance =
      CustomerViewStorageService._internal();
  factory CustomerViewStorageService() => _instance;
  CustomerViewStorageService._internal();

  File? _getStorageFile() {
    try {
      final home = Platform.environment['HOME'] ?? '';
      if (home.isNotEmpty) {
        final dir = Directory('$home/Library/Application Support/CliksBusiness');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        return File('${dir.path}/customer_view_config.json');
      }
    } catch (_) {
      // Fallback to temp
    }
    try {
      return File('${Directory.systemTemp.path}/cliks_customer_view_config.json');
    } catch (_) {
      return null;
    }
  }

  Future<void> saveConfiguration({
    required CustomerViewSettings settings,
    required Map<String, String> customImages, // productId -> filePath
    required List<String> hiddenProductIds,
    required List<String> featuredProductIds,
  }) async {
    try {
      final file = _getStorageFile();
      if (file == null) return;

      final data = {
        'settings': settings.toJson(),
        'customImages': customImages,
        'hiddenProductIds': hiddenProductIds,
        'featuredProductIds': featuredProductIds,
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      // Ignore or log error
    }
  }

  Future<Map<String, dynamic>?> loadConfiguration() async {
    try {
      final file = _getStorageFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        }
      }
    } catch (_) {
      // Ignore error and fall back to default
    }
    return null;
  }
}
