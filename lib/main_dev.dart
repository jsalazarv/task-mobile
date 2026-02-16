import 'package:flutter/material.dart';
import 'package:hometasks/core/config/env/dev_env.dart';
import 'package:hometasks/core/config/env/env_config.dart';
import 'package:hometasks/main.dart' as app;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  EnvConfig.initialize(DevEnv());
  
  app.main();
}
