part of 'main.dart';

Future<AppDatabase?> _initDatabase(SharedPreferences pref,
    {QueryInterceptor? interceptor}) async {
  try {
    final path = await getDbPath(pref);
    return AppDatabase(path: path, interceptor: interceptor);
  } catch (e) {
    logger.e('Error initializing database', error: e);
    reportError("init database", e);
  }

  logger.d('Database initialized');
}
