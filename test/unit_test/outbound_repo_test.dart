import 'package:flutter_test/flutter_test.dart';
import 'package:tm/protos/google/protobuf/any.pb.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:tm/protos/protos/proxy/vmess.pb.dart';
import 'package:vx/app/outbound/outbound_repo.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// the file defined above, you can test any drift database of course
import 'package:vx/data/database.dart';
import 'package:matcher/matcher.dart' as matcher;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late OutboundRepo repo;

  setUp(() {
    database = AppDatabase(DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ));
    repo = OutboundRepo(database);
  });

  tearDown(() async {
    await database.close();
  });

  // Helper function to create test handler data
  OutboundHandler createTestHandler({
    int id = 0,
    bool selected = false,
    bool enabled = true,
    String? countryCode,
    String remark = 'Test Handler',
    String protocol = 'vmess',
    String address = '192.168.1.1',
    String ports = '443',
    double speed1MB = 0,
    int ping = 0,
  }) {
    // Create a simple byte array for testing instead of using Freedom

    return OutboundHandler(
      id: id,
      selected: selected,
      enabled: enabled,
      countryCode: countryCode,
      remark: remark,
      config: OutboundHandlerConfig(
          address: address, port: 443, protocol: Any.pack(VmessClientConfig())),
      speed1MB: speed1MB,
      ping: ping,
    );
  }

  group('OutboundHandler CRUD operations', () {
    test('insertHandler should add a handler to the database', () async {
      final handler = createTestHandler();
      await repo.insertHandler(handler);

      final handlers = await repo.getAllHandlers();
      expect(handlers.length, 1);
      expect(handlers.first.remark, 'Test Handler');
      expect(handlers.first.config.address, '192.168.1.1');
    });

    test('getHandlerById should return correct handler', () async {
      final handler = createTestHandler();
      await repo.insertHandler(handler);

      final handlers = await repo.getAllHandlers();
      final id = handlers.first.id;

      final retrievedHandler = await repo.getHandlerById(id);
      expect(retrievedHandler, matcher.isNotNull);
      expect(retrievedHandler!.id, id);
      expect(retrievedHandler.remark, 'Test Handler');
    });

    test('updateHandler should update handler fields', () async {
      final handler = createTestHandler();
      await repo.insertHandler(handler);

      final handlers = await repo.getAllHandlers();
      final id = handlers.first.id;

      // Update the handler
      repo.updateHandler(id, speed: 100.0, ping: 50, country: 'US');

      final updatedHandler = await repo.getHandlerById(id);
      expect(updatedHandler!.speed, 100.0);
      expect(updatedHandler.ping, 50);
      expect(updatedHandler.countryCode, 'US');
    });

    test('removeHandlerById should delete the handler', () async {
      final handler = createTestHandler();
      await repo.insertHandler(handler);

      final handlers = await repo.getAllHandlers();
      final id = handlers.first.id;

      await repo.removeHandlerById(id);

      final handlersAfterRemoval = await repo.getAllHandlers();
      expect(handlersAfterRemoval.length, 0);
    });

    test('insertHandlers should add multiple handlers', () async {
      final handlers = [
        createTestHandler(remark: 'Handler 1', protocol: 'vmess'),
        createTestHandler(remark: 'Handler 2', protocol: 'trojan'),
        createTestHandler(remark: 'Handler 3', protocol: 'shadowsocks'),
      ];

      await repo.insertHandlers(handlers);

      final savedHandlers = await repo.getAllHandlers();
      expect(savedHandlers.length, 3);

      // Verify the handlers were saved correctly
      expect(savedHandlers.map((h) => h.remark).toList()..sort(),
          ['Handler 1', 'Handler 2', 'Handler 3']);
    });

    test('clearHandlerFields should reset specified fields to zero', () async {
      final handler = createTestHandler(speed1MB: 100.0, ping: 50);
      await repo.insertHandler(handler);

      final handlers = await repo.getAllHandlers();
      final id = handlers.first.id;

      // Clear speed and ping
      await repo.updateHandlerFields([id], speed: true, ping: true);

      final updatedHandler = await repo.getHandlerById(id);
      expect(updatedHandler!.speed, 0.0);
      expect(updatedHandler.ping, 0);
    });

    test('replaceHandler should completely replace a handler', () async {
      // Insert initial handler
      final initialHandler = createTestHandler(
        remark: 'Initial Handler',
        protocol: 'vmess',
        address: '192.168.1.1',
        ports: '443',
      );
      await repo.insertHandler(initialHandler);

      // Get the handler with its assigned ID
      final handlers = await repo.getAllHandlers();
      final id = handlers.first.id;

      // Create a replacement handler with the same ID
      final replacementHandler = createTestHandler(
        id: id,
        remark: 'Replaced Handler',
        protocol: 'trojan',
        address: '10.0.0.1',
        ports: '8443',
        selected: true,
        countryCode: 'JP',
      );

      // Replace the handler
      await repo.replaceHandler(replacementHandler);

      // Verify the handler was replaced
      final updatedHandler = await repo.getHandlerById(id);
      expect(updatedHandler!.id, id);
      expect(updatedHandler.remark, 'Replaced Handler');
      expect(updatedHandler.config.address, '10.0.0.1');
      expect(updatedHandler.config.port, 8443);
      expect(updatedHandler.selected, true);
      expect(updatedHandler.countryCode, 'JP');
    });
  });

  group('Filtering and querying handlers', () {
    setUp(() async {
      // Insert test data
      final handlers = [
        createTestHandler(
            remark: 'Fast',
            protocol: 'vmess',
            selected: true,
            speed1MB: 100.0,
            ping: 20),
        createTestHandler(
            remark: 'Medium',
            protocol: 'trojan',
            enabled: true,
            speed1MB: 50.0,
            ping: 50),
        createTestHandler(
            remark: 'Slow',
            protocol: 'shadowsocks',
            enabled: false,
            speed1MB: 10.0,
            ping: 200),
      ];

      await repo.insertHandlers(handlers);
    });

    test('getHandlers with speed1MBLessEqual filter', () async {
      final handlers = await repo.getHandlers(speed1MBLessEqual: 60.0);
      expect(handlers.length, 2);
      expect(handlers.every((h) => h.speed1MB <= 60.0), true);
    });

    test('getHandlers with selected filter', () async {
      final handlers = await repo.getHandlers(selected: true);
      expect(handlers.length, 1);
      expect(handlers.first.remark, 'Fast');
      expect(handlers.first.selected, true);
    });

    test('getHandlers with enabled filter', () async {
      final handlers = await repo.getHandlers(enabled: true);
      expect(handlers.length, 2);
      expect(handlers.every((h) => h.enabled), true);
    });

    test('getHandlers with orderBySpeed1MBDesc', () async {
      final handlers = await repo.getHandlers(orderBySpeed1MBDesc: true);
      expect(handlers.length, 3);
      expect(
          handlers.map((h) => h.remark).toList(), ['Fast', 'Medium', 'Slow']);
    });

    test('getHandlers with limit', () async {
      final handlers = await repo.getHandlers(limit: 2);
      expect(handlers.length, 2);
    });

    test(
        'getHandlersStream with selected filter should emit only selected handlers',
        () async {
      // First, remove any existing selected handlers
      final allHandlers = await repo.getAllHandlers();
      for (var handler in allHandlers.where((h) => h.selected)) {
        final updatedHandler = handler.copyWith(selected: false);
        await repo.replaceHandler(updatedHandler);
      }

      // Insert a single selected handler
      await repo.insertHandler(createTestHandler(
        remark: 'Selected Handler',
        selected: true,
      ));

      // Create a stream that filters for selected handlers
      final stream = repo.getHandlersStream(selected: true);

      // Initial emission should have only the one selected handler we just added
      expect(
          stream,
          emits(isA<List<OutboundHandler>>()
              .having((list) => list.length, 'selected handler count', 1)));

      // Add another selected handler
      await repo.insertHandler(createTestHandler(
        remark: 'Another Selected',
        selected: true,
      ));

      // Stream should emit a list containing both selected handlers
      expect(
          stream,
          emits(isA<List<OutboundHandler>>()
              .having((list) => list.length, 'selected handler count', 2)));
    });
  });

  group('Subscription operations', () {
    test('insertSubscription should add a subscription to the database',
        () async {
      final sub = SubscriptionsCompanion.insert(
        name: 'Test Sub',
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
        link: 'https://example.com/sub',
        updateInterval: const Value(24),
      );

      await repo.insertSubscription(sub);

      final subs = await repo.getAllSubs();
      expect(subs.length, 1);
      expect(subs.first.name, 'Test Sub');
      expect(subs.first.link, 'https://example.com/sub');
    });

    test('getSubsByName should return subscriptions with matching name',
        () async {
      final sub1 = SubscriptionsCompanion.insert(
        name: 'Sub A',
        link: 'https://example.com/a',
        updateInterval: const Value(24),
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
      );

      final sub2 = SubscriptionsCompanion.insert(
        name: 'Sub B',
        link: 'https://example.com/b',
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
        updateInterval: const Value(12),
      );

      await repo.insertSubscription(sub1);
      await repo.insertSubscription(sub2);

      final subs = await repo.getSubsByName('Sub A');
      expect(subs.length, 1);
      expect(subs.first.name, 'Sub A');
    });

    test('removeSubscription should delete the subscription', () async {
      final sub = SubscriptionsCompanion.insert(
        name: 'Test Sub',
        link: 'https://example.com/sub',
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
        updateInterval: const Value(24),
      );

      await repo.insertSubscription(sub);

      final subs = await repo.getAllSubs();
      final id = subs.first.id;

      await repo.removeSubscription(id);

      final subsAfterRemoval = await repo.getAllSubs();
      expect(subsAfterRemoval.length, 0);
    });

    test('insertSubscription with handlers should create relationship',
        () async {
      final sub = SubscriptionsCompanion.insert(
        name: 'Test Sub',
        link: 'https://example.com/sub',
        updateInterval: const Value(24),
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
      );

      final handlers = [
        createTestHandler(remark: 'Handler 1'),
        createTestHandler(remark: 'Handler 2'),
      ];

      await repo.insertSubscription(sub, handlers: handlers);

      // Get all handlers
      final allHandlers = await repo.getAllHandlers();
      expect(allHandlers.length, 2);

      // Get subscriptions
      final subs = await repo.getAllSubs();
      expect(subs.length, 1);

      // TODO: Add test for relationship verification if you add a method to get handlers by subscription
    });

    test('updateSubscription should update subscription fields', () async {
      // Insert initial subscription
      final sub = SubscriptionsCompanion.insert(
        name: 'Test Sub',
        link: 'https://example.com/sub',
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
        updateInterval: const Value(24),
      );

      await repo.insertSubscription(sub);

      // Get the subscription with its assigned ID
      final subs = await repo.getAllSubs();
      final subscription = subs.first;

      // Create an updated subscription
      final updatedSubscription = Subscription(
        id: subscription.id,
        name: 'Updated Sub',
        link: 'https://example.com/updated',
        updateInterval: 12,
        lastUpdate: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        remainingData: '500MB',
        endTime: '2023-12-31',
        website: 'https://example.com',
      );

      // Update the subscription
      await repo.replaceSubscription(updatedSubscription);

      // Verify the subscription was updated
      final updatedSubs = await repo.getAllSubs();
      expect(updatedSubs.length, 1);
      expect(updatedSubs.first.name, 'Updated Sub');
      expect(updatedSubs.first.link, 'https://example.com/updated');
      expect(updatedSubs.first.updateInterval, 12);
      expect(updatedSubs.first.remainingData, '500MB');
      expect(updatedSubs.first.endTime, '2023-12-31');
      expect(updatedSubs.first.website, 'https://example.com');
    });
  });

  group('Stream operations', () {
    test('getHandlersStream should emit handlers when data changes', () async {
      // First, clear the database completely
      final allHandlers = await repo.getAllHandlers();
      for (final handler in allHandlers) {
        await repo.removeHandlerById(handler.id);
      }

      // Now create a stream - it should be empty
      final stream = repo.getHandlersStream();
      expect(stream, emits(isEmpty));

      // Insert a handler
      await repo.insertHandler(createTestHandler(remark: 'Stream Test'));

      // The stream should emit the new list with the handler
      expect(
          stream,
          emits(isA<List<OutboundHandler>>()
              .having((list) => list.length, 'length', 1)));
    });

    test('getStreamOfSubs should emit subscriptions when data changes',
        () async {
      // First, clear the database completely
      final allSubs = await repo.getAllSubs();
      for (final sub in allSubs) {
        await repo.removeSubscription(sub.id);
      }

      final stream = repo.getStreamOfSubs();

      expect(stream, emits(isEmpty));

      // Insert a subscription
      final sub = SubscriptionsCompanion.insert(
        name: 'Stream Test Sub',
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
        lastSuccessUpdate: DateTime.now().millisecondsSinceEpoch,
        link: 'https://example.com/stream',
      );
      await repo.insertSubscription(sub);

      // The stream should emit the new list with the subscription
      expect(
          stream,
          emits(isA<List<Subscription>>()
              .having((list) => list.length, 'length', 1)));
    });
  });

  group('Utility functions', () {
    test('handlersToHandlerConfig should convert handlers to config', () async {
      // Create test handlers
      final handlers = [
        createTestHandler(id: 1, remark: 'Handler 1'),
        createTestHandler(id: 2, remark: 'Handler 2'),
      ];

      // Convert to config
      final config = handlersToHandlerConfig(handlers);

      // Verify the conversion
      expect(config.handlers.length, 2);
      expect(config.handlers[0].tag, '1');
      expect(config.handlers[1].tag, '2');
    });
  });
}
