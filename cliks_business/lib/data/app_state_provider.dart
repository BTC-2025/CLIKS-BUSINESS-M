import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppUiState {
  final bool isDarkMode;
  final String activeFolder;

  const AppUiState({
    this.isDarkMode = false,
    this.activeFolder = 'Inbox',
  });

  AppUiState copyWith({
    bool? isDarkMode,
    String? activeFolder,
  }) {
    return AppUiState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      activeFolder: activeFolder ?? this.activeFolder,
    );
  }
}

class AppUiNotifier extends StateNotifier<AppUiState> {
  AppUiNotifier() : super(const AppUiState());

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void selectFolder(String folder) {
    state = state.copyWith(activeFolder: folder);
  }

  void loadUserSettings(String email) {
    // Synchronize user settings if needed
  }
}

final appUiProvider = StateNotifierProvider<AppUiNotifier, AppUiState>((ref) {
  return AppUiNotifier();
});
