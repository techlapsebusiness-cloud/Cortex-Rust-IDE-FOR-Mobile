import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingDone = 'cortex_onboarding_done';
const _kDefaultTopicId = 'cortex_default_topic_id';
const _kAccentValue = 'cortex_accent_value';

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final onboardingDoneProvider = Provider<AsyncValue<bool>>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.whenData((p) => p.getBool(_kOnboardingDone) ?? false);
});

final defaultCaptureTopicIdProvider = Provider<AsyncValue<int?>>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.whenData((p) {
    final v = p.getInt(_kDefaultTopicId);
    return v;
  });
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

  Future<void> setDefaultTopicId(int? id) async {
    if (id == null) {
      await _prefs.remove(_kDefaultTopicId);
    } else {
      await _prefs.setInt(_kDefaultTopicId, id);
    }
  }

  Future<void> setAccentValue(int value) =>
      _prefs.setInt(_kAccentValue, value);
}

final settingsRepositoryProvider =
    Provider<AsyncValue<SettingsRepository>>((ref) {
  return ref.watch(sharedPrefsProvider).whenData(SettingsRepository.new);
});
