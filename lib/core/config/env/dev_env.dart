import 'package:hometasks/core/config/env/env_config.dart';

class DevEnv implements EnvConfig {
  @override
  Environment get environment => Environment.dev;

  @override
  String get appName => 'HomeTasks Dev';

  @override
  String get apiBaseUrl => 'https://dev-api.hometasks.com';

  @override
  bool get enableLogging => true;
}
