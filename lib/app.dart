import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/category_provider.dart';
import 'providers/product_provider.dart';
import 'providers/user_provider.dart';
import 'repositories/booking_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/user_repository.dart';
import 'routes/app_routes.dart';

class MedigoAdminApp extends StatefulWidget {
  const MedigoAdminApp({super.key});

  @override
  State<MedigoAdminApp> createState() => _MedigoAdminAppState();
}

class _MedigoAdminAppState extends State<MedigoAdminApp> {
  // Services
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  // Repositories
  late final UserRepository _userRepo;
  late final CategoryRepository _categoryRepo;
  late final ProductRepository _productRepo;
  late final BookingRepository _bookingRepo;

  // Providers
  late final AuthProvider _authProvider;
  late final UserProvider _userProvider;
  late final CategoryProvider _categoryProvider;
  late final ProductProvider _productProvider;
  late final BookingProvider _bookingProvider;

  StreamSubscription? _authSub;

  @override
  void initState() {
    super.initState();
    _userRepo = UserRepository(_firestoreService);
    _categoryRepo = CategoryRepository(_firestoreService);
    _productRepo = ProductRepository(_firestoreService);
    _bookingRepo = BookingRepository(_firestoreService);

    _authProvider = AuthProvider(_authService);
    _userProvider = UserProvider(_userRepo);
    _categoryProvider = CategoryProvider(_categoryRepo);
    _productProvider = ProductProvider(_productRepo);
    _bookingProvider = BookingProvider(_bookingRepo);

    _authSub = _authProvider.authStateChanges.listen((user) {
      if (user != null) {
        _startStreams();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  bool _streamsStarted = false;

  void _startStreams() {
    if (_streamsStarted) return;
    _streamsStarted = true;
    _userProvider.streamUsers();
    _categoryProvider.streamCategories();
    _productProvider.streamProducts();
    _bookingProvider.streamBookings();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _userProvider),
        ChangeNotifierProvider.value(value: _categoryProvider),
        ChangeNotifierProvider.value(value: _productProvider),
        ChangeNotifierProvider.value(value: _bookingProvider),
        Provider.value(value: _storageService),
      ],
      child: Builder(
        builder: (context) {
          final router = createRouter(context);
          return MaterialApp.router(
            title: 'Medigo Admin',
            theme: AppTheme.light,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
