# Configuración de Environments (Flavors)

El proyecto HomeTasks está configurado con tres ambientes diferentes:

## 🌍 Ambientes Disponibles

### 1. Development (Dev)
- **App Name:** HomeTasks Dev
- **API Base URL:** https://dev-api.hometasks.com
- **Logging:** Enabled
- **Bundle ID (iOS):** com.hometasks.hometasks.dev

### 2. Staging
- **App Name:** HomeTasks Staging
- **API Base URL:** https://staging-api.hometasks.com
- **Logging:** Enabled
- **Bundle ID (iOS):** com.hometasks.hometasks.staging

### 3. Production (Prod)
- **App Name:** HomeTasks
- **API Base URL:** https://api.hometasks.com
- **Logging:** Disabled
- **Bundle ID (iOS):** com.hometasks.hometasks

## 🚀 Cómo Ejecutar con Diferentes Ambientes

### iOS / macOS

#### Development
```bash
flutter run -t lib/main_dev.dart
```

#### Staging
```bash
flutter run -t lib/main_staging.dart
```

#### Production
```bash
flutter run -t lib/main_prod.dart
```

### Ejecutar por Defecto (Dev)
```bash
flutter run
# o simplemente
flutter run -t lib/main.dart
```

## 🏗️ Cómo Hacer Build

### iOS

#### Development
```bash
flutter build ios -t lib/main_dev.dart --flavor dev
```

#### Staging
```bash
flutter build ios -t lib/main_staging.dart --flavor staging
```

#### Production
```bash
flutter build ios -t lib/main_prod.dart --flavor prod
```

### macOS

```bash
flutter build macos -t lib/main_dev.dart
flutter build macos -t lib/main_staging.dart
flutter build macos -t lib/main_prod.dart
```

## 📱 Configuración por Plataforma

### iOS

Los flavors de iOS están configurados en Xcode con schemes diferentes:

1. Abrir `ios/Runner.xcworkspace` en Xcode
2. En la barra superior, seleccionar el scheme deseado:
   - Runner (Dev)
   - Runner Staging
   - Runner Prod

### Android (Cuando se agregue)

Los flavors de Android se configurarán en `android/app/build.gradle`:

```gradle
flavorDimensions "environment"
productFlavors {
    dev {
        dimension "environment"
        applicationIdSuffix ".dev"
        versionNameSuffix "-dev"
    }
    staging {
        dimension "environment"
        applicationIdSuffix ".staging"
        versionNameSuffix "-staging"
    }
    prod {
        dimension "environment"
    }
}
```

## 🔧 Configuración de Variables

Las configuraciones de ambiente están en:
- `lib/core/config/env/env_config.dart` (Clase abstracta)
- `lib/core/config/env/dev_env.dart`
- `lib/core/config/env/staging_env.dart`
- `lib/core/config/env/prod_env.dart`

### Cómo Agregar Nuevas Variables

1. Agregar el getter en `EnvConfig`:
```dart
abstract class EnvConfig {
  String get nuevoValor;
  // ...
}
```

2. Implementar en cada ambiente:
```dart
// dev_env.dart
@override
String get nuevoValor => 'valor_dev';

// staging_env.dart
@override
String get nuevoValor => 'valor_staging';

// prod_env.dart
@override
String get nuevoValor => 'valor_prod';
```

3. Usar en la app:
```dart
final config = EnvConfig.instance;
print(config.nuevoValor);
```

## 🧪 Testing con Diferentes Ambientes

Para tests, puedes inicializar el ambiente deseado:

```dart
void main() {
  setUp(() {
    EnvConfig.initialize(DevEnv());
  });
  
  test('should use dev environment', () {
    expect(EnvConfig.instance.environment, Environment.dev);
  });
}
```

## 📝 Notas Importantes

1. **Por Defecto:** Si no se especifica ningún ambiente, se usa `dev`
2. **Variables Sensibles:** No commitear valores reales de producción (API keys, secrets)
3. **Firebase:** Cada ambiente debe tener su propia configuración de Firebase
4. **Bundle IDs:** Cada ambiente tiene su propio bundle ID para poder instalar múltiples versiones en el mismo dispositivo

## 🔐 Best Practices

1. ✅ Nunca usar valores de producción en dev/staging
2. ✅ Mantener logging habilitado solo en dev/staging
3. ✅ Usar certificados diferentes para cada ambiente
4. ✅ Configurar Firebase projects separados
5. ✅ Nunca commitear secrets reales en el repositorio
6. ✅ Usar variables de entorno para CI/CD

## 🎯 VS Code Launch Configuration

Puedes agregar esto en `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Dev",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart"
    },
    {
      "name": "Staging",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_staging.dart"
    },
    {
      "name": "Prod",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart"
    }
  ]
}
```

Esto te permitirá seleccionar el ambiente desde el dropdown de VS Code.
