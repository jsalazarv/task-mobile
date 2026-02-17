# Ejecutar HomeTasks en iPhone

## Problema identificado

La aplicación se cierra inmediatamente cuando se ejecuta en **modo Debug** porque requiere una conexión constante con el debugger. Si el cable USB se desconecta o hay problemas de red (mDNS), la app se cierra.

**Solución:** Ejecutar la app en **modo Release** que funciona de forma independiente.

## Método 1: Build & Install via Xcode (Recomendado)

### Prerrequisitos
- iPhone conectado por USB
- Modo desarrollador activado en el iPhone
- Perfil de desarrollador confiado en: `Configuración > General > VPN y administración de dispositivos`

### Pasos

```bash
# 1. Navegar al directorio del proyecto
cd /Users/jsalazarv/Code/Me/HomeTasks/hometasks

# 2. Construir en modo Release usando Xcode
cd ios
/usr/bin/arch -arm64e xcodebuild \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -destination 'id=00008130-0016390102F2001C' \
  -allowProvisioningUpdates \
  clean build

# 3. Instalar en el dispositivo
/usr/bin/arch -arm64e xcrun devicectl device install app \
  --device 00008130-0016390102F2001C \
  /Users/jsalazarv/Library/Developer/Xcode/DerivedData/Runner-fihhgualvbeewtdbwoyokrqvvsmd/Build/Products/Release-iphoneos/Runner.app
```

### Verificar ID del dispositivo
Si tu iPhone tiene un ID diferente:

```bash
flutter devices
```

Reemplaza `00008130-0016390102F2001C` con el ID de tu dispositivo.

## Método 2: Flutter Command (Alternativo)

```bash
# Asegúrate de que Flutter esté en el PATH
export PATH="$HOME/development/flutter/bin:$PATH"

# Build en modo Release
flutter build ios --release

# Nota: Este método requiere firma manual adicional
```

## Método 3: Xcode GUI (Más simple)

1. Abre Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. En Xcode:
   - Selecciona tu iPhone en el selector de dispositivos
   - Esquema: **Runner**
   - Build Configuration: **Release** (Edit Scheme > Run > Build Configuration)
   - Presiona ▶️ (Run)

## Configurar entornos

La app soporta 3 entornos:

### Development (por defecto)
```bash
# Usa lib/main.dart o lib/main_dev.dart
flutter build ios --release -t lib/main_dev.dart
```

### Staging
```bash
flutter build ios --release -t lib/main_staging.dart
```

### Production
```bash
flutter build ios --release -t lib/main_prod.dart
```

## Solución de problemas

### La app se cierra inmediatamente
- ✅ **Solución:** Usar modo **Release** en lugar de Debug
- El modo Debug requiere conexión constante al debugger

### Error: "Profile not trusted"
1. En iPhone: `Configuración > General > VPN y administración de dispositivos`
2. Toca en `Apple Development: jsalazarv8@gmail.com`
3. Toca **"Confiar"**

### Error: "Failed to install"
- Verifica que el iPhone esté conectado
- Verifica que Developer Mode esté activado
- Intenta desinstalar la app anterior primero

### Cable USB se desconecta
- Usa modo **Release** - no necesita cable después de la instalación
- Modo Debug requiere cable conectado todo el tiempo

## Notas importantes

1. **Modo Debug vs Release:**
   - **Debug:** Requiere cable USB + debugger activo. Se cierra si se desconecta.
   - **Release:** Funciona independientemente después de instalar.

2. **Firebase temporalmente deshabilitado:**
   - Firebase se agregará en Phase 12
   - Las dependencias están comentadas en `pubspec.yaml`

3. **Code Signing:**
   - Xcode maneja automáticamente la firma con `-allowProvisioningUpdates`
   - Team ID: `K8548MK8LZ`
   - Bundle ID: `com.hometasks.hometasks`

## Estado actual de la app

La app muestra:
- ✅ Ícono de confirmación (check verde)
- ✅ "¡Aplicación funcionando!"
- ✅ Entorno activo (DEV/STAGING/PROD)
- ✅ URL del API
- ✅ Servicios inicializados:
  - Dependency Injection (GetIt)
  - Local Storage (Hive)
  - Network Layer (Dio)

## Próximos pasos

- **PHASE 6:** Core Implementation - UI/UX (Routing, Theme, i18n, Widgets)
- **PHASE 7:** Feature Auth - Domain Layer
- **PHASE 8:** Feature Auth - Data Layer
- **PHASE 9:** Feature Auth - Presentation Layer
- **PHASE 10:** Integration and Testing
