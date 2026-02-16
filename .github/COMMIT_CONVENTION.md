# Conventional Commits

Este proyecto sigue la especificación de [Conventional Commits](https://www.conventionalcommits.org/).

## Formato

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

## Types

- **feat**: Nueva funcionalidad
- **fix**: Corrección de bugs
- **docs**: Solo cambios en documentación
- **style**: Cambios que no afectan el significado del código (espacios, formato, etc.)
- **refactor**: Refactorización de código (ni fix ni feat)
- **test**: Agregar tests faltantes o corregir tests existentes
- **chore**: Cambios en el proceso de build o herramientas auxiliares
- **perf**: Mejoras de performance
- **ci**: Cambios en configuración de CI/CD
- **build**: Cambios que afectan el sistema de build o dependencias externas

## Scope (Opcional)

El scope proporciona contexto adicional:

- **config**: Configuración (environments, etc.)
- **auth**: Feature de autenticación
- **core**: Core layer
- **network**: Networking layer
- **storage**: Storage layer
- **ui**: Componentes de UI
- **deps**: Dependencias

## Ejemplos

### Feature
```
feat(auth): add login functionality

Implements user login with email and password.
Includes form validation and error handling.
```

### Bug Fix
```
fix(network): handle network timeout correctly

Previously, network timeouts would crash the app.
Now they are caught and displayed as user-friendly errors.
```

### Build
```
build: add freezed for code generation

Adds freezed and json_serializable for immutable data classes
and JSON serialization.
```

### Refactor
```
refactor(auth): extract validation logic to separate class

Moved email and password validation from UI to
EmailValidator and PasswordValidator classes.
```

### Documentation
```
docs: update README with installation instructions

Added step-by-step Flutter installation guide
for macOS, Linux, and Windows.
```

### Breaking Changes

Para cambios que rompen la compatibilidad, agregar `BREAKING CHANGE:` en el footer o `!` después del type/scope:

```
feat(api)!: change authentication endpoint

BREAKING CHANGE: The /auth/login endpoint now requires
a different payload structure. Update all API calls accordingly.
```

## Reglas

1. ✅ El type es **obligatorio**
2. ✅ El scope es **opcional** pero recomendado
3. ✅ La description debe estar en **minúsculas**
4. ✅ La description **NO debe** terminar en punto
5. ✅ Usar **modo imperativo** ("add" no "added" o "adds")
6. ✅ El body es **opcional** para explicar el "qué" y "por qué" (no el "cómo")
7. ✅ Breaking changes deben ser indicados claramente

## Beneficios

- 📝 Historial de commits claro y consistente
- 🤖 Generación automática de CHANGELOG
- 📦 Versionado semántico automático
- 🔍 Fácil navegación en el historial
- 👥 Mejor comunicación en el equipo

## Herramientas Recomendadas

### Commitizen
Para commits interactivos:
```bash
npm install -g commitizen cz-conventional-changelog
git cz
```

### Commitlint
Para validar mensajes de commit:
```bash
npm install -g @commitlint/cli @commitlint/config-conventional
```

### Husky
Para pre-commit hooks:
```bash
npx husky install
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit $1'
```

## Referencias

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Angular Commit Guidelines](https://github.com/angular/angular/blob/master/CONTRIBUTING.md#commit)
