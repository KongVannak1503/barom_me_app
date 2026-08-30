import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/translation_repository.dart';
import 'locale_provider.dart';

/// Holds the current locale's dynamic keyword map ({ key: value }).
/// Loads instantly from the local cache, then refreshes from the backend.
final translationsProvider = AsyncNotifierProvider<TranslationsNotifier, Map<String, String>>(
  TranslationsNotifier.new,
);

class TranslationsNotifier extends AsyncNotifier<Map<String, String>> {
  late final TranslationRepository _repo;

  @override
  Future<Map<String, String>> build() async {
    // Rebuild whenever the active locale changes.
    final locale = ref.watch(localeProvider).languageCode;
    _repo = TranslationRepository();

    final cached = await _repo.cached(locale);
    // Kick off a background refresh; UI already shows cached values.
    unawaited(_refresh(locale));
    return cached;
  }

  Future<void> refresh() async {
    final locale = ref.read(localeProvider).languageCode;
    final fresh = await _repo.fetch(locale);
    state = AsyncData(fresh);
  }

  Future<void> _refresh(String locale) async {
    await refresh();
  }
}

/// Convenience helper for callers that explicitly manage loading.
Future<void> refreshTranslations(WidgetRef ref) async {
  await ref.read(translationsProvider.notifier).refresh();
}