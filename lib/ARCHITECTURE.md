# Arquitectura del Proyecto HomeTasks

## 📐 Clean Architecture + BLoC

Este proyecto sigue los principios de **Clean Architecture** con **BLoC** para gestión de estado.

## 🗂️ Estructura de Carpetas

```
lib/
├── core/                          # Código compartido entre features
│   ├── config/                    # Configuraciones globales
│   │   ├── env/                   # Variables de entorno (dev/staging/prod)
│   │   ├── routes/                # Configuración de navegación (GoRouter)
│   │   └── theme/                 # Temas (light/dark) Material 3
│   ├── constants/                 # Constantes globales (API URLs, etc.)
│   ├── di/                        # Dependency Injection (GetIt + Injectable)
│   ├── error/                     # Manejo centralizado de errores
│   │   ├── exceptions.dart        # Excepciones de data layer
│   │   └── failures.dart          # Failures de domain layer
│   ├── network/                   # Cliente HTTP (Dio) con interceptors
│   ├── storage/                   # Storage local (Hive + SharedPreferences)
│   ├── utils/                     # Utilidades y helpers
│   │   ├── extensions/            # Extension methods
│   │   ├── validators/            # Validadores de formularios
│   │   └── helpers/               # Helper functions
│   └── widgets/                   # Widgets reutilizables globales
│
├── features/                      # Features/Módulos de la aplicación
│   └── auth/                      # Ejemplo: Módulo de Autenticación
│       ├── data/                  # Data Layer
│       │   ├── datasources/       # Fuentes de datos (Remote API + Local Cache)
│       │   ├── models/            # Modelos de datos (JSON serialization)
│       │   └── repositories/      # Implementación de repositorios
│       ├── domain/                # Domain Layer (Lógica de negocio)
│       │   ├── entities/          # Entidades de dominio (objetos puros)
│       │   ├── repositories/      # Contratos de repositorios (interfaces)
│       │   └── usecases/          # Casos de uso (reglas de negocio)
│       └── presentation/          # Presentation Layer (UI)
│           ├── bloc/              # BLoC (eventos, estados, lógica)
│           ├── pages/             # Pantallas/Páginas
│           └── widgets/           # Widgets específicos del feature
│
├── l10n/                          # Internacionalización (i18n)
│   ├── app_en.arb                 # Traducciones en inglés
│   └── app_es.arb                 # Traducciones en español
│
└── main.dart                      # Entry point principal
```

## 📦 Cómo Agregar un Nuevo Feature/Módulo

Para mantener la consistencia y modularidad, sigue estos pasos al crear un nuevo feature:

### 1. Crear la estructura de carpetas

```bash
mkdir -p lib/features/nombre_modulo/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}
```

### 2. Domain Layer (Empezar aquí)

**Orden recomendado:**

1. **Entities** (`domain/entities/`)
   - Objetos de dominio puros (sin dependencias externas)
   - Usar `Equatable` para comparaciones
   
   ```dart
   class Product extends Equatable {
     final String id;
     final String name;
     final double price;
     
     const Product({required this.id, required this.name, required this.price});
     
     @override
     List<Object?> get props => [id, name, price];
   }
   ```

2. **Repository Contracts** (`domain/repositories/`)
   - Interfaces abstractas
   - Retornan `Either<Failure, T>` (de dartz)
   
   ```dart
   abstract class ProductRepository {
     Future<Either<Failure, List<Product>>> getProducts();
     Future<Either<Failure, Product>> getProductById(String id);
   }
   ```

3. **UseCases** (`domain/usecases/`)
   - Un caso de uso = una acción específica
   - Principio de Responsabilidad Única
   
   ```dart
   class GetProducts {
     final ProductRepository repository;
     
     GetProducts(this.repository);
     
     Future<Either<Failure, List<Product>>> call() {
       return repository.getProducts();
     }
   }
   ```

### 3. Data Layer

1. **Models** (`data/models/`)
   - Extienden de las Entities
   - Incluyen `fromJson` y `toJson`
   - Usar `freezed` para code generation
   
   ```dart
   @freezed
   class ProductModel with _$ProductModel {
     factory ProductModel({
       required String id,
       required String name,
       required double price,
     }) = _ProductModel;
     
     factory ProductModel.fromJson(Map<String, dynamic> json) =>
         _$ProductModelFromJson(json);
   }
   
   extension ProductModelX on ProductModel {
     Product toEntity() => Product(id: id, name: name, price: price);
   }
   ```

2. **DataSources** (`data/datasources/`)
   - Remote: llamadas a API (usando Retrofit + Dio)
   - Local: cache (usando Hive)
   
   ```dart
   abstract class ProductRemoteDataSource {
     Future<List<ProductModel>> getProducts();
   }
   
   abstract class ProductLocalDataSource {
     Future<List<ProductModel>> getCachedProducts();
     Future<void> cacheProducts(List<ProductModel> products);
   }
   ```

3. **Repository Implementation** (`data/repositories/`)
   - Implementa el contrato del domain
   - Maneja lógica de cache + remote
   - Convierte Exceptions → Failures
   
   ```dart
   class ProductRepositoryImpl implements ProductRepository {
     final ProductRemoteDataSource remoteDataSource;
     final ProductLocalDataSource localDataSource;
     
     ProductRepositoryImpl({
       required this.remoteDataSource,
       required this.localDataSource,
     });
     
     @override
     Future<Either<Failure, List<Product>>> getProducts() async {
       try {
         final remoteProducts = await remoteDataSource.getProducts();
         await localDataSource.cacheProducts(remoteProducts);
         return Right(remoteProducts.map((m) => m.toEntity()).toList());
       } on ServerException {
         return Left(ServerFailure());
       } on CacheException {
         return Left(CacheFailure());
       }
     }
   }
   ```

### 4. Presentation Layer

1. **BLoC** (`presentation/bloc/`)
   - Events: acciones del usuario
   - States: estados de la UI
   - Logic: transformaciones y llamadas a UseCases
   
   ```dart
   // Events
   abstract class ProductEvent {}
   class LoadProducts extends ProductEvent {}
   
   // States
   abstract class ProductState {}
   class ProductInitial extends ProductState {}
   class ProductLoading extends ProductState {}
   class ProductLoaded extends ProductState {
     final List<Product> products;
     ProductLoaded(this.products);
   }
   class ProductError extends ProductState {
     final String message;
     ProductError(this.message);
   }
   
   // BLoC
   class ProductBloc extends Bloc<ProductEvent, ProductState> {
     final GetProducts getProducts;
     
     ProductBloc({required this.getProducts}) : super(ProductInitial()) {
       on<LoadProducts>(_onLoadProducts);
     }
     
     Future<void> _onLoadProducts(
       LoadProducts event,
       Emitter<ProductState> emit,
     ) async {
       emit(ProductLoading());
       final result = await getProducts();
       result.fold(
         (failure) => emit(ProductError(failure.message)),
         (products) => emit(ProductLoaded(products)),
       );
     }
   }
   ```

2. **Pages** (`presentation/pages/`)
   - Screens principales
   - Contienen BlocProvider y BlocBuilder/BlocListener
   
3. **Widgets** (`presentation/widgets/`)
   - Componentes reutilizables del feature

### 5. Registrar Dependencias

En `lib/core/di/injection.dart`:

```dart
@module
abstract class ProductModule {
  @lazySingleton
  ProductRemoteDataSource get remoteDataSource => ProductRemoteDataSourceImpl();
  
  @lazySingleton
  ProductLocalDataSource get localDataSource => ProductLocalDataSourceImpl();
  
  @lazySingleton
  ProductRepository get repository => ProductRepositoryImpl(
    remoteDataSource: get(),
    localDataSource: get(),
  );
  
  @lazySingleton
  GetProducts get getProducts => GetProducts(get());
}
```

### 6. Agregar Rutas

En `lib/core/config/routes/app_router.dart`:

```dart
GoRoute(
  path: '/products',
  name: 'products',
  builder: (context, state) => const ProductsPage(),
),
```

### 7. Crear Tests

Estructura de tests debe reflejar la estructura del código:

```
test/features/nombre_modulo/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   └── usecases/
└── presentation/
    └── bloc/
```

## 🔄 Flujo de Datos

```
User Action (UI)
    ↓
BLoC Event
    ↓
BLoC calls UseCase
    ↓
UseCase calls Repository (interface)
    ↓
Repository Implementation
    ↓
DataSource (Remote API / Local Cache)
    ↓
Response (Model)
    ↓
Converted to Entity
    ↓
Wrapped in Either<Failure, Entity>
    ↓
Returned to UseCase
    ↓
Returned to BLoC
    ↓
BLoC emits new State
    ↓
UI rebuilds
```

## 🎯 Principios Clave

### 1. Dependency Rule
- Las capas internas NO conocen las capas externas
- Domain no conoce Data ni Presentation
- Data y Presentation conocen Domain

### 2. Separation of Concerns
- Cada capa tiene su responsabilidad única
- No mezclar lógica de negocio con UI
- No mezclar lógica de datos con lógica de negocio

### 3. Testability
- Domain layer 100% testeable (sin dependencias externas)
- Data layer testeable con mocks
- Presentation testeable con BlocTest

### 4. Scalability
- Agregar features sin afectar otros
- Estructura predecible y consistente
- Fácil onboarding para nuevos desarrolladores

## 📚 Referencias

- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Library](https://bloclibrary.dev/)
- [Reso Coder - Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
