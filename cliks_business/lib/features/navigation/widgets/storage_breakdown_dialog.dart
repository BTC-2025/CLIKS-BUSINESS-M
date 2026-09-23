import 'package:flutter/material.dart';
import '../pages/macos_storage_page.dart';

class MacOsStorageBreakdownDialog extends StatelessWidget {
  const MacOsStorageBreakdownDialog({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MacOsStoragePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MacOsStoragePage();
  }
}
