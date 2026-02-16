enum Environment {
  dev,
  staging,
  prod,
}

abstract class EnvConfig {
  Environment get environment;
  String get appName;
  String get apiBaseUrl;
  bool get enableLogging;
  
  static EnvConfig? _instance;
  
  static EnvConfig get instance {
    if (_instance == null) {
      throw Exception(
        'EnvConfig not initialized. Call EnvConfig.initialize() first',
      );
    }
    return _instance!;
  }
  
  static void initialize(EnvConfig config) {
    _instance = config;
  }
}
