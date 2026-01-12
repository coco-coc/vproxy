import 'package:flutter/foundation.dart';
import 'package:vx/data/database.dart';

class DatabaseProvider extends ChangeNotifier {
  DatabaseProvider({required this.database});

  AppDatabase database;

  void setDatabase(AppDatabase database) {
    this.database = database;
    notifyListeners();
  }
}
