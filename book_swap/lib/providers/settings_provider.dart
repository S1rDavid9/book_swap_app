import 'package:flutter_riverpod/flutter_riverpod.dart';

// Settings State Class
class SettingsState {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool swapNotifications;

  SettingsState({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.swapNotifications = true,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? swapNotifications,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      swapNotifications: swapNotifications ?? this.swapNotifications,
    );
  }
}

// Settings State Notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  void toggleEmailNotifications(bool value) {
    state = state.copyWith(emailNotifications: value);
  }

  void toggleSwapNotifications(bool value) {
    state = state.copyWith(swapNotifications: value);
  }

  void resetSettings() {
    state = SettingsState();
  }
}

// Settings Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});