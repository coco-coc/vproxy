import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:vx/app/blocs/proxy_selector/proxy_selector_bloc.dart';
import 'package:vx/auth/auth_provider.dart';
import 'package:vx/data/database.dart';
import 'package:vx/main.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/file.dart';
import 'package:vx/utils/logger.dart';
import 'package:vx/utils/path.dart';

class BackupSerevice extends ChangeNotifier {
  BackupSerevice(
      {required AuthProvider authProvider, required PrefHelper prefHelper})
      : _authProvider = authProvider,
        _prefHelper = prefHelper {
    // if (_prefHelper.autoBackup) {
    //   startPeriodicBackup();
    // }
  }
  final AuthProvider _authProvider;
  final PrefHelper _prefHelper;

  bool get canUpload => _authProvider.currentUser?.pro ?? false;
  String get _userId => _authProvider.currentUser?.id ?? '';
  bool uploading = false;
  bool restoring = false;

  // Periodic sync fields
  Timer? _periodicBackupTimer;
  final Duration _periodicSyncInterval = const Duration(minutes: 5);

  void startPeriodicBackup() {
    _periodicBackupTimer = Timer.periodic(_periodicSyncInterval, (timer) {
      uploadBackup();
    });
  }

  void stopPeriodicBackup() {
    _periodicBackupTimer?.cancel();
    _periodicBackupTimer = null;
  }

  Future<String?> uploadBackup() async {
    final userId = _userId;
    if (userId.isEmpty) {
      return null;
    }

    uploading = true;
    notifyListeners();

    final dst = await dbVacuumDest();
    File? encryptedFile;

    try {
      if (await File(dst).exists()) {
        await File(dst).delete();
      }

      await database.customStatement('VACUUM INTO ?', [dst]);

      // Get backup password from secure storage
      final password = await storage.read(key: 'backupPassword');

      File fileToUpload = File(dst);

      // Encrypt the database file if password is set
      if (password != null && password.isNotEmpty) {
        encryptedFile = await encryptFile(File(dst), password);
        fileToUpload = encryptedFile;
        logger.i('Database encrypted for backup');
      } else {
        logger.w('No backup password set, uploading unencrypted database');
      }

      final fileName = '${DateTime.now().toIso8601String()}.db';
      await supabase.storage
          .from('backup')
          .upload('$userId/$fileName', fileToUpload);

      // Clean up old backups asynchronously
      unawaited(Future(() async {
        final existingFiles =
            await supabase.storage.from('backup').list(path: userId);
        if (existingFiles.isNotEmpty) {
          existingFiles.removeWhere((element) => element.name == fileName);
          await supabase.storage
              .from('backup')
              .remove(existingFiles.map((e) => '$userId/${e.name}').toList());
        }
      }));

      return fileName;
    } catch (e) {
      logger.e('Failed to upload backup', error: e);
      rethrow;
    } finally {
      uploading = false;
      notifyListeners();

      // Clean up temporary files
      if (await File(dst).exists()) {
        await File(dst).delete();
      }
      if (encryptedFile != null && await encryptedFile.exists()) {
        await encryptedFile.delete();
      }
    }
  }

  Future<String?> getLatestBackup() async {
    final userId = _userId;
    if (userId.isEmpty) {
      return null;
    }
    final existingFiles =
        await supabase.storage.from('backup').list(path: userId);
    if (existingFiles.isEmpty) {
      return null;
    }
    final backupFile = existingFiles.first;
    return backupFile.name;
  }

  Future<void> deleteBackup() async {
    final userId = _userId;
    if (userId.isEmpty) {
      return;
    }
    final existingFiles =
        await supabase.storage.from('backup').list(path: userId);
    if (existingFiles.isEmpty) {
      return;
    }
    await supabase.storage
        .from('backup')
        .remove(existingFiles.map((e) => '$userId/${e.name}').toList());
  }

  Future<void> restoreBackup({String? path}) async {
    final userId = _userId;
    if (userId.isEmpty) {
      return;
    }

    restoring = true;
    notifyListeners();

    List<File> filesToDelete = [];

    try {
      path ??= await getLatestBackup();
      if (path == null) {
        throw Exception('No backup found');
      }

      // Download the backup file
      final storageResponse =
          await supabase.storage.from('backup').download('$userId/$path');
      final tmpLocation = await tempFilePath();
      final tmpFile = await File(tmpLocation).writeAsBytes(storageResponse);
      filesToDelete.add(tmpFile);

      File dbFileToRestore = tmpFile;

      // Try to decrypt the file if password is set
      final password = await storage.read(key: 'backupPassword');
      if (password != null && password.isNotEmpty) {
        try {
          final decryptedFile = await decryptFile(tmpFile, password);
          filesToDelete.add(decryptedFile);
          dbFileToRestore = decryptedFile;
          logger.i('Backup decrypted successfully');
        } catch (e) {
          logger.e('Failed to decrypt backup', error: e);
          throw Exception(
              'Failed to decrypt backup. Please check your password.');
        }
      } else {
        logger.w('No backup password set, assuming unencrypted backup');
      }

      // Open the database and vacuum it
      final backupDb = sqlite3.open(dbFileToRestore.path);
      final tmpDb = '${tmpLocation}.db';
      backupDb
        ..execute('VACUUM INTO ?', [tmpDb])
        ..dispose();

      // Then replace the existing database file with it.
      final tempDbFile = File(tmpDb);
      filesToDelete.add(tempDbFile);

      await xController.waitForConnectedIfConnecting();
      if (xController.status == XStatus.connected) {
        await xController.stop();
      }
      await database.close(); // close the current database
      await xApiClient.closeDb();

      late String newDbPath;
      if (Platform.isWindows) {
        // copy the new database file to the standard location
        final newDbName = persistentStateRepo.dbName == 'x_database.sqlite'
            ? '1.sqlite'
            : '${int.parse(persistentStateRepo.dbName.split('.')[0]) + 1}.sqlite';
        newDbPath = join(resourceDirectory.path, newDbName);
        print(newDbPath);
      } else {
        newDbPath = await getDbPath();
      }

      await tempDbFile.copy(newDbPath);

      if (Platform.isWindows) {
        persistentStateRepo.setDbName(newDbPath.split('\\').last);
      }

      database = AppDatabase();
      await xApiClient.openDb();
    } catch (e) {
      rethrow;
    } finally {
      restoring = false;
      notifyListeners();
      unawaited(Future(() async {
        // remove old db
        // get all files ended with .sqlite
        final currentDbPath = await getDbPath();
        final sqliteFiles = resourceDirectory.listSync().where((e) {
          return e.path.endsWith('.sqlite') && e.path != currentDbPath;
        }).map((e) => File(e.path));
        filesToDelete.addAll(sqliteFiles);
        // delete the temporary database file
        for (final file in filesToDelete) {
          file.delete();
        }
      }));
    }
  }
}
