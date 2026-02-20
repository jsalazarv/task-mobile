# 📱 Tudus - Gestión de Tareas Gamificada

**Tudus** es una aplicación móvil multiplataforma de gestión de tareas diseñada para familias, grupos de trabajo y equipos colaborativos. Transforma la organización de tareas cotidianas en una experiencia gamificada mediante un sistema de puntos (XP), niveles, rachas y logros.

## 🚀 Características Destacadas

- 🏠 **Multi-grupo**: Gestiona múltiples grupos (familia, trabajo, amigos, escuela)
- ✅ **Tareas inteligentes**: Creación, asignación y organización con drag & drop
- 📅 **Vistas de calendario**: Día, semana y "Mi Día" personalizado
- 🎮 **Gamificación completa**: XP, niveles, rachas, podio semanal y logros
- 👥 **Perfiles personalizados**: Avatares, estadísticas y progreso individual
- 🎨 **Categorías personalizables**: Hasta 6 categorías con íconos y colores por grupo
- 🌓 **Temas**: Light, Dark o System
- 🌍 **Multi-idioma**: Español e Inglés

## 📖 Documentación Completa

Para información detallada sobre la app, arquitectura, características y guías técnicas, consulta:

**[📄 Documentación Completa](docs/APP_OVERVIEW.md)**

## 🛠️ Quick Start

### Requisitos
- Flutter SDK 3.7+
- Dart SDK 3.7+
- iOS 13+ / Android API 21+

### Instalación

```bash
# Clonar el repositorio
git clone <repo-url>
cd hometasks

# Instalar dependencias
flutter pub get

# Generar código (DI, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Ejecutar en desarrollo
flutter run --flavor dev -t lib/main_dev.dart
```

### Compilar para Producción

#### Android
```bash
flutter build apk --release --flavor prod -t lib/main_prod.dart
```

#### iOS
```bash
flutter build ipa --release --no-tree-shake-icons
```

> **Nota**: El flag `--no-tree-shake-icons` es necesario debido a iconos dinámicos.

## 🏗️ Arquitectura

La app sigue **Clean Architecture** con separación en 3 capas:

- **Presentation**: UI (Pages, Widgets) + State Management (BLoC/Cubit)
- **Domain**: Entities, Use Cases, Repository Interfaces
- **Data**: Models, DataSources, Repository Implementations

### Stack Tecnológico Principal

- **Framework**: Flutter + Dart 3.7+
- **State Management**: BLoC/Cubit + ValueNotifier
- **Navigation**: GoRouter
- **DI**: GetIt + Injectable
- **Persistence**: SharedPreferences + Hive
- **Networking**: Dio (preparado para backend futuro)

## 📂 Estructura del Proyecto

```
lib/
├── core/              # Código compartido
│   ├── config/        # Ambientes (dev/staging/prod)
│   ├── di/            # Inyección de dependencias
│   ├── models/        # Modelos compartidos
│   ├── services/      # Servicios singleton
│   └── theme/         # Tema de la app
├── features/          # Módulos por funcionalidad
│   ├── auth/          # Autenticación
│   ├── groups/        # Gestión de grupos
│   ├── home/          # Pantalla principal
│   ├── onboarding/    # Primer uso
│   └── settings/      # Configuración
└── l10n/              # Traducciones (ES/EN)
```

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Análisis de código
flutter analyze
```

## 🌍 Internacionalización

La app soporta múltiples idiomas mediante ARB files:
- Español (es)
- Inglés (en)

## 📝 Licencia

Proyecto privado - Todos los derechos reservados

---

**Versión**: 1.0.0 (Build 1)  
**Plataformas**: iOS 13+ | Android API 21+
