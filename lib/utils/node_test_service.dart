import 'dart:async';
import 'package:vx/app/outbound/outbound_repo.dart';
import 'package:vx/app/outbound/outbounds_bloc.dart';
import 'package:vx/data/database.dart';
import 'package:vx/pref_helper.dart';
import 'package:vx/utils/logger.dart';

/// Service that periodically tests nodes if their latency/speed data is old
class NodeTestService {
  NodeTestService({
    required this.outboundRepo,
    required this.outboundBloc,
    required this.prefHelper,
  });

  final OutboundRepo outboundRepo;
  final OutboundBloc outboundBloc;
  final PrefHelper prefHelper;

  Timer? _timer;
  bool _isRunning = false;

  /// Start the periodic testing service
  void start() {
    if (_isRunning) {
      logger.d('NodeTestService already running');
      return;
    }

    _isRunning = true;
    _scheduleUpdate();
  }

  void _scheduleUpdate() {
    if (!prefHelper.autoTestNodes) {
      return;
    }

    Duration interval = Duration(minutes: prefHelper.nodeTestInterval);
    late DateTime nextTestTime;
    final lastTestTime = prefHelper.lastNodeTestTime;
    if (lastTestTime == null) {
      nextTestTime = DateTime.now();
    } else {
      nextTestTime = lastTestTime.add(interval);
    }

    late final Duration initialDelay;
    if (nextTestTime.isBefore(DateTime.now())) {
      initialDelay = const Duration();
    } else {
      initialDelay = nextTestTime.difference(DateTime.now());
    }

    logger.d('next test in: ${initialDelay.inMinutes} minutes');
    _timer = Timer(initialDelay, _checkAndTestNodes);
  }

  /// Stop the periodic testing service
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    logger.d('NodeTestService stopped');
  }

  /// Restart the service (useful when settings change)
  void restart() {
    stop();
    if (prefHelper.autoTestNodes) {
      start();
    }
  }

  /// Check nodes and test those with old data
  Future<void> _checkAndTestNodes() async {
    if (!prefHelper.autoTestNodes) {
      return;
    }
    
    prefHelper.setLastNodeTestTime(DateTime.now());
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/
          1000; // Unix timestamp in seconds

      // Get all handlers
      final handlers = await outboundRepo.getHandlers();

      // Filter handlers that need testing
      final handlersToTest = <OutboundHandler>[];

      for (final handler in handlers) {
        bool needsPingTest = false;
        bool needsSpeedTest = false;

        // Check if ping data is old or missing
        if (handler.pingTestTime == 0 || (now - handler.pingTestTime) > 1800) {
          needsPingTest = true;
        }

        // Check if speed data is old or missing
        if (handler.speedTestTime == 0 ||
            (now - handler.speedTestTime) > 1800) {
          needsSpeedTest = true;
        }

        // If either test is needed, add to list
        if (needsPingTest || needsSpeedTest) {
          handlersToTest.add(handler);
        }
      }

      if (handlersToTest.isEmpty) {
        logger.d('No nodes need testing (all data is fresh)');
        return;
      }

      logger.d('Testing ${handlersToTest.length} nodes with old data');

      // Test latency first (faster)
      final handlersNeedingPing = handlersToTest.where((h) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        return h.pingTestTime == 0 || (now - h.pingTestTime) > 1800;
      }).toList();

      if (handlersNeedingPing.isNotEmpty) {
        logger.d('Testing ping for ${handlersNeedingPing.length} nodes');
        outboundBloc.add(StatusTestEvent(handlers: handlersNeedingPing));
      }

      // Test speed for nodes that need it (slower, so do it after ping)
      final handlersNeedingSpeed = handlersToTest.where((h) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        return h.speedTestTime == 0 || (now - h.speedTestTime) > 1800;
      }).toList();

      if (handlersNeedingSpeed.isNotEmpty) {
        // Wait a bit before speed test to avoid overwhelming the system
        await Future.delayed(const Duration(seconds: 2));
        logger.d('Testing speed for ${handlersNeedingSpeed.length} nodes');
        outboundBloc.add(SpeedTestEvent(handlers: handlersNeedingSpeed));
      }
    } catch (e) {
      logger.e('Error in NodeTestService._checkAndTestNodes', error: e);
    }
    _scheduleUpdate();
  }
}
