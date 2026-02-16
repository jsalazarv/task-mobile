import 'package:hometasks/core/config/env/env_config.dart';

class ProdEnv implements EnvConfig {
  @override
  Environment get environment => Environment.prod;

  @override
  String get appName => 'HomeTasks';

  @override
  String get apiBaseUrl => 'https://api.hometasks.com';

  @override
  bool get enableLogging => false;
}
