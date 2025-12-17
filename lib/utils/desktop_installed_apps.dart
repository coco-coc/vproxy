import 'dart:io';
import 'package:win32_registry/win32_registry.dart';

/// Information about an installed desktop application
class DesktopAppInfo {
  final String name;
  final String? displayName;
  final String? installLocation;
  final String? executablePath;
  final String? icon;
  final String? version;

  DesktopAppInfo({
    required this.name,
    this.displayName,
    this.installLocation,
    this.executablePath,
    this.icon,
    this.version,
  });

  @override
  String toString() {
    return 'DesktopAppInfo(name: $name, executablePath: $executablePath)';
  }
}

/// Get installed applications on desktop platforms
class DesktopInstalledApps {
  /// Get list of installed applications
  static Future<List<DesktopAppInfo>> getInstalledApps() async {
    if (Platform.isWindows) {
      return _getWindowsInstalledApps();
    } else if (Platform.isMacOS) {
      return _getMacOSInstalledApps();
    } else if (Platform.isLinux) {
      return _getLinuxInstalledApps();
    }
    return [];
  }

  /// Get installed applications on Windows from Registry
  static Future<List<DesktopAppInfo>> _getWindowsInstalledApps() async {
    final apps = <DesktopAppInfo>[];
    final seenNames = <String>{};

    // Registry paths to check for installed applications
    final registryPaths = [
      r'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
      r'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
    ];

    for (final path in registryPaths) {
      try {
        final key = Registry.openPath(RegistryHive.localMachine, path: path);
        final subKeyNames = key.subkeyNames;

        for (final subKeyName in subKeyNames) {
          try {
            final subKey = Registry.openPath(
              RegistryHive.localMachine,
              path: '$path\\$subKeyName',
            );

            // Get display name
            final displayName = _getRegistryValue(subKey, 'DisplayName');
            if (displayName == null || displayName.isEmpty) {
              subKey.close();
              continue;
            }

            // Skip if we've already seen this app name
            if (seenNames.contains(displayName)) {
              subKey.close();
              continue;
            }

            // Skip Windows updates and system components
            final systemComponent = _getRegistryValue(subKey, 'SystemComponent');
            if (systemComponent == '1') {
              subKey.close();
              continue;
            }

            final parentKeyName = _getRegistryValue(subKey, 'ParentKeyName');
            if (parentKeyName != null) {
              subKey.close();
              continue;
            }

            // Get installation location and executable
            final installLocation = _getRegistryValue(subKey, 'InstallLocation');
            final displayIcon = _getRegistryValue(subKey, 'DisplayIcon');
            final version = _getRegistryValue(subKey, 'DisplayVersion');
            
            String? executablePath;
            
            // Try to find executable from DisplayIcon first
            if (displayIcon != null && displayIcon.isNotEmpty) {
              // DisplayIcon often contains the path to the exe
              final iconPath = displayIcon.split(',')[0].trim().replaceAll('"', '');
              if (iconPath.toLowerCase().endsWith('.exe') && File(iconPath).existsSync()) {
                executablePath = iconPath;
              }
            }

            // If no exe found from icon, try InstallLocation
            if (executablePath == null && installLocation != null && installLocation.isNotEmpty) {
              final dir = Directory(installLocation);
              if (dir.existsSync()) {
                // Look for .exe files in install location
                final exeFiles = dir
                    .listSync(recursive: false)
                    .whereType<File>()
                    .where((f) => f.path.toLowerCase().endsWith('.exe'))
                    .toList();
                
                if (exeFiles.isNotEmpty) {
                  // Prefer exe with similar name to the app
                  final matchingExe = exeFiles.where((f) {
                    final fileName = f.uri.pathSegments.last.toLowerCase();
                    final appNameLower = displayName.toLowerCase();
                    return fileName.contains(appNameLower.split(' ')[0]);
                  }).firstOrNull;
                  
                  executablePath = (matchingExe ?? exeFiles.first).path;
                }
              }
            }

            seenNames.add(displayName);
            apps.add(DesktopAppInfo(
              name: subKeyName,
              displayName: displayName,
              installLocation: installLocation,
              executablePath: executablePath,
              icon: displayIcon,
              version: version,
            ));

            subKey.close();
          } catch (e) {
            // Skip apps that can't be read
            continue;
          }
        }

        key.close();
      } catch (e) {
        // Registry path not accessible, skip
        continue;
      }
    }

    // Sort by display name
    apps.sort((a, b) => (a.displayName ?? a.name).compareTo(b.displayName ?? b.name));
    
    return apps;
  }

  /// Get installed applications on macOS
  static Future<List<DesktopAppInfo>> _getMacOSInstalledApps() async {
    final apps = <DesktopAppInfo>[];
    final applicationDirs = [
      Directory('/Applications'),
      Directory('${Platform.environment['HOME']}/Applications'),
    ];

    for (final dir in applicationDirs) {
      if (!dir.existsSync()) continue;

      try {
        final entities = dir.listSync(recursive: false);
        for (final entity in entities) {
          if (entity is Directory && entity.path.endsWith('.app')) {
            final appName = entity.uri.pathSegments[entity.uri.pathSegments.length - 2]
                .replaceAll('.app', '');
            
            // Try to find the executable in Contents/MacOS/
            final macosDir = Directory('${entity.path}/Contents/MacOS');
            String? executablePath;
            
            if (macosDir.existsSync()) {
              final executables = macosDir
                  .listSync(recursive: false)
                  .whereType<File>()
                  .where((f) => _isExecutable(f.path))
                  .toList();
              
              if (executables.isNotEmpty) {
                executablePath = executables.first.path;
              }
            }

            apps.add(DesktopAppInfo(
              name: appName,
              displayName: appName,
              installLocation: entity.path,
              executablePath: executablePath,
            ));
          }
        }
      } catch (e) {
        // Skip directories that can't be read
        continue;
      }
    }

    apps.sort((a, b) => a.name.compareTo(b.name));
    return apps;
  }

  /// Get installed applications on Linux
  static Future<List<DesktopAppInfo>> _getLinuxInstalledApps() async {
    final apps = <DesktopAppInfo>[];
    final desktopFileDirs = [
      Directory('/usr/share/applications'),
      Directory('/usr/local/share/applications'),
      Directory('${Platform.environment['HOME']}/.local/share/applications'),
    ];

    for (final dir in desktopFileDirs) {
      if (!dir.existsSync()) continue;

      try {
        final entities = dir.listSync(recursive: false);
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.desktop')) {
            try {
              final content = entity.readAsStringSync();
              final lines = content.split('\n');
              
              String? name;
              String? exec;
              String? icon;
              
              for (final line in lines) {
                if (line.startsWith('Name=')) {
                  name = line.substring(5).trim();
                } else if (line.startsWith('Exec=')) {
                  exec = line.substring(5).trim();
                  // Remove field codes like %U, %F, etc.
                  exec = exec.replaceAll(RegExp(r'%[a-zA-Z]'), '').trim();
                } else if (line.startsWith('Icon=')) {
                  icon = line.substring(5).trim();
                }
              }

              if (name != null && name.isNotEmpty) {
                apps.add(DesktopAppInfo(
                  name: entity.uri.pathSegments.last.replaceAll('.desktop', ''),
                  displayName: name,
                  executablePath: exec,
                  icon: icon,
                ));
              }
            } catch (e) {
              // Skip invalid desktop files
              continue;
            }
          }
        }
      } catch (e) {
        // Skip directories that can't be read
        continue;
      }
    }

    apps.sort((a, b) => (a.displayName ?? a.name).compareTo(b.displayName ?? b.name));
    return apps;
  }

  /// Helper to get registry value
  static String? _getRegistryValue(RegistryKey key, String valueName) {
    try {
      final value = key.getValueAsString(valueName);
      return value;
    } catch (e) {
      return null;
    }
  }

  /// Check if a file is executable (macOS/Linux)
  static bool _isExecutable(String path) {
    if (Platform.isWindows) {
      return path.toLowerCase().endsWith('.exe');
    }
    
    try {
      final result = Process.runSync('test', ['-x', path]);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}

