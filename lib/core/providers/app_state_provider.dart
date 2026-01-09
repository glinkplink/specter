import 'package:flutter_riverpod/flutter_riverpod.dart';

// App state model
class AppState {
  final bool isScanning;

  AppState({
    this.isScanning = false,
  });

  AppState copyWith({
    bool? isScanning,
  }) {
    return AppState(
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

// State notifier for app state
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState());

  void toggleScanning() {
    state = state.copyWith(isScanning: !state.isScanning);
  }

  void setScanning(bool value) {
    state = state.copyWith(isScanning: value);
  }
}

// Provider for app state
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);
