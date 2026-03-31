class AppConstants {
  // Firestore Collections
  static const String usersCollection = 'Users';
  static const String categoriesCollection = 'Categories';
  static const String productsCollection = 'Products';
  static const String bookingsCollection = 'Bookings';

  // Storage Paths
  static const String categoryImagesPath = 'categories/';
  static const String productImagesPath = 'products/';
  static const String userAvatarsPath = 'avatars/';

  // Pagination
  static const int pageSize = 20;

  // Layout
  static const double sidebarWidth = 260.0;
  static const double sidebarCollapsedWidth = 72.0;
  static const double topbarHeight = 64.0;
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;

  // Booking Status Values
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Admin Email (guard)
  static const String adminEmail = 'admin@medigo.com';
}
