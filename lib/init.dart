part of 'main.dart';

Future<void> _initDatabase({QueryInterceptor? interceptor}) async {
  try {
    database = AppDatabase(interceptor: interceptor);
  } catch (e) {
    logger.e('Error initializing database', error: e);
    reportError("init database", e);
  }

  logger.d('Database initialized');
}
