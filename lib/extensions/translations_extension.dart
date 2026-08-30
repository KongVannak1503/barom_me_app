import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/translations_provider.dart';

/// Resolves a string as: dynamic DB value (if present) → [fallback] → key.
///
/// Screens keep their bundled `AppLocalizations` value as the fallback, so any
/// key without a backend override simply renders the bundled text.
///
/// NOTE: the app root watches [translationsProvider], so the whole tree
/// rebuilds when the dynamic map changes — this read stays reactive via that.
extension TranslationsX on BuildContext {
  String tr(String key, [String? fallback]) {
    final container = ProviderScope.containerOf(this, listen: false);
    final map = container.read(translationsProvider).valueOrNull ??
        const <String, String>{};
    return map[key] ?? fallback ?? key;
  }
}