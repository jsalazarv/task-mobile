import 'package:flutter/material.dart';
import 'package:hometasks/core/config/env/env_config.dart';
import 'package:hometasks/core/config/env/staging_env.dart';
import 'package:hometasks/main.dart' as app;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  EnvConfig.initialize(StagingEnv());
  
  await app.main();
}
