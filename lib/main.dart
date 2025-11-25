import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'domain/services/audio_service.dart';
import 'presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await initializeNotifications();

  // Initialize audio service (for timer completion sounds)
  await AudioService().initialize();

  runApp(
    const ProviderScope(
      child: AtomizeApp(),
    ),
  );
}
