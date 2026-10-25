import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingDone = 'cortex_onboarding_done';
const _kDefaultProjectId = 'cortex_default_project_id';
const _kAccentValue = 'cortex_accent_value';

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final onboardingDoneProvider = Provider<AsyncValue<bool>>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.whenData((p) => p.getBool(_kOnboardingDone) ?? false);
});

final defaultCaptureProjectIdProvider = Provider<AsyncValue<int?>>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.whenData((p) => p.getInt(_kDefaultProjectId));
});

final accentColorValueProvider = Provider<AsyncValue<int>>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.whenData((p) => p.getInt(_kAccentValue) ?? 0xFF22D3EE);
});

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  Future<void> setOnboardingDone(bool done) =>
      _prefs.setBool(_kOnboardingDone, done);

  Future<void> setDefaultProjectId(int? id) async {
    if (id == null) {
      await _prefs.remove(_kDefaultProjectId);
    } else {
      await _prefs.setInt(_kDefaultProjectId, id);
    }
  }

  Future<void> setAccentValue(int value) =>
      _prefs.setInt(_kAccentValue, value);
}

final settingsRepositoryProvider =
    Provider<AsyncValue<SettingsRepository>>((ref) {
  return ref.watch(sharedPrefsProvider).whenData(SettingsRepository.new);
});
