import 'package:hometasks/core/config/env/env_config.dart';

class StagingEnv implements EnvConfig {
  @override
  Environment get environment => Environment.staging;

  @override
  String get appName => 'HomeTasks Staging';

  @override
  String get apiBaseUrl => 'https://staging-api.hometasks.com';

  @override
  bool get enableLogging => true;
}
