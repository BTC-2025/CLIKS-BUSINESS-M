import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_service.dart';

class LocationState {
  final UserLocation? location;
  final bool isLoading;
  final String? errorMessage;

  LocationState({
    this.location,
    this.isLoading = false,
    this.errorMessage,
  });

  LocationState copyWith({
    UserLocation? location,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationState(
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier()
      : super(LocationState(
          location: UserLocation(
            city: 'Tiruvallur',
            zip: '602001',
            streetAddress: 'Tiruvallur, Tamil Nadu',
            latitude: 13.1438,
            longitude: 79.9083,
          ),
        ));

  Future<void> detectGPSLocation() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final loc = await LocationService.determinePosition();
      state = state.copyWith(location: loc, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> searchAndSetLocation(String query) async {
    if (query.trim().isEmpty) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final loc = await LocationService.searchPosition(query);
      if (loc != null) {
        state = state.copyWith(location: loc, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Location not found.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to find location.',
      );
      return false;
    }
  }

  void setCustomLocation(UserLocation loc) {
    state = state.copyWith(location: loc, clearError: true);
  }
}

final locationStateProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});
