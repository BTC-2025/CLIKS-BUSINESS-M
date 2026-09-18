import 'dart:io';

void main() {
  try {
    final src = File('assets/bit_tool_logo.png');
    final destWeb = File('web/user_logo.png');
    
    if (src.existsSync()) {
      // Copy to web folder for local development server
      destWeb.createSync(recursive: true);
      destWeb.writeAsBytesSync(src.readAsBytesSync());
      
      print('=====================================================');
      print(' SUCCESS: Logo copied from assets to:');
      print('  - ${destWeb.path}');
      print('=====================================================');
    } else {
      print('ERROR: assets/bit_tool_logo.png not found!');
    }
  } catch (e) {
    print('ERROR copying logo: $e');
  }
}
