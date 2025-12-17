import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tm/protos/protos/outbound.pb.dart';
import 'package:tm/protos/protos/proxy/vmess.pb.dart';
import 'package:tm/protos/google/protobuf/any.pb.dart';
import 'package:vx/widgets/outbound_handler_form/outbound_handler_form.dart';
import 'package:vx/data/database.dart';

void main() {
  group('OutboundHandlerForm', () {
    late GlobalKey<FormState> formKey;

    setUp(() {
      formKey = GlobalKey<FormState>();
    });

    testWidgets('renders with default values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutboundHandlerForm(
              formKey: formKey,
            ),
          ),
        ),
      );

      // Verify initial protocol is VMess
      expect(find.text('VMess'), findsOneWidget);
      
      // Verify form fields are present
      expect(find.byType(TextFormField), findsNWidgets(3)); // Name, address, port
      
      // Verify Mux switch is present
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('validates required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutboundHandlerForm(
              formKey: formKey,
            ),
          ),
        ),
      );

      // Try to submit empty form
      formKey.currentState?.validate();
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Server address cannot be empty'), findsOneWidget);
      expect(find.text('Port cannot be empty'), findsOneWidget);
    });

    testWidgets('switches protocols correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutboundHandlerForm(
              formKey: formKey,
            ),
          ),
        ),
      );

      // Open protocol dropdown
      await tester.tap(find.byType(DropdownMenu));
      await tester.pumpAndSettle();

      // Select VLESS
      await tester.tap(find.text('VLESS'));
      await tester.pumpAndSettle();

      // Verify VLESS specific fields are shown
      expect(find.byType(TextFormField), findsNWidgets(3)); // Should still have 3 text fields

      // Select Trojan
      await tester.tap(find.byType(DropdownMenu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trojan'));
      await tester.pumpAndSettle();

      // Verify Trojan specific fields are shown
      expect(find.byType(TextFormField), findsNWidgets(3)); // Should still have 3 text fields
    });

    testWidgets('generates correct OutboundHandler', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutboundHandlerForm(
              formKey: formKey,
            ),
          ),
        ),
      );

      // Fill in form fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Name');
      await tester.enterText(find.byType(TextFormField).at(1), 'example.com');
      await tester.enterText(find.byType(TextFormField).at(2), '443');

      // Get the form state
      final formState = tester.state<OutboundHandlerFormState>(
        find.byType(OutboundHandlerForm),
      );

      // Verify generated OutboundHandler
      final handler = formState.outboundHandler;
      expect(handler.config.tag, equals('Test Name'));
      expect(handler.config.address, equals('example.com'));
      expect(handler.config.port, equals(443));
      expect(handler.config.enableMux, isFalse);
    });

    testWidgets('initializes with existing handler', (WidgetTester tester) async {
      final existingHandler = OutboundHandler(
        config: OutboundHandlerConfig(
          tag: 'Existing',
          address: 'existing.com',
          port: 8080,
          enableMux: true,
          protocol: Any.pack(VmessClientConfig()),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutboundHandlerForm(
              formKey: formKey,
              config: existingHandler,
            ),
          ),
        ),
      );

      // Verify form is populated with existing values
      expect(find.text('Existing'), findsOneWidget);
      expect(find.text('existing.com'), findsOneWidget);
      expect(find.text('8080'), findsOneWidget);
      
      // Verify Mux is enabled
      final switchFinder = find.byType(Switch);
      expect(tester.widget<Switch>(switchFinder).value, isTrue);
    });
  });
} 