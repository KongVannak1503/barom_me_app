import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/api_constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiConstants.setFlavor(ApiFlavor.stage);
  runApp(const ProviderScope(child: BaromMeApp()));
}
