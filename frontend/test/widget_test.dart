import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/ebook_library_controller.dart';
import 'package:frontend/screens/library_screen.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/widgets/bookshelf_view.dart';

class FakeApiClient extends ApiClient {
  final List<dynamic> books;

  FakeApiClient(this.books) : super(baseUrl: 'http://localhost:3000');

  @override
  Future<List<dynamic>> getEbooks({String? query, String? fileType, String? sortBy}) async {
    return books;
  }

  @override
  Future<void> deleteEbook(int id) async {
    books.removeWhere((b) => b['id'] == id);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );
  });

  testWidgets('should display empty shelf message when no books exist', (WidgetTester tester) async {
    final fakeClient = FakeApiClient([]);
    final controller = EbookLibraryController(apiClient: fakeClient);

    await tester.pumpWidget(MaterialApp(
      home: LibraryScreen(controller: controller),
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Your library is empty'), findsOneWidget);
    expect(find.byType(BookshelfView), findsOneWidget);
  });

  testWidgets('should display ebook cards on shelf when books exist', (WidgetTester tester) async {
    final fakeClient = FakeApiClient([
      {
        'id': 101,
        'title': 'Test Driven Development',
        'author': 'Kent Beck',
        'file_type': 'pdf',
        'file_size': 500000,
        'upload_date': '2026-07-18T10:00:00Z',
        'cover_image_url': null,
      }
    ]);
    final controller = EbookLibraryController(apiClient: fakeClient);

    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
        home: LibraryScreen(controller: controller),
      ));
      await Future.delayed(const Duration(milliseconds: 200));
    });

    await tester.pump();

    expect(find.text('Test Driven Development'), findsNWidgets(2));
    expect(find.text('Kent Beck'), findsNWidgets(2));
    expect(find.text('Your library is empty'), findsNothing);
  });

  testWidgets('should trigger delete confirmation bottom sheet on book long press', (WidgetTester tester) async {
    final fakeClient = FakeApiClient([
      {
        'id': 202,
        'title': 'Clean Architecture',
        'author': 'Uncle Bob',
        'file_type': 'pdf',
        'file_size': 900000,
        'upload_date': '2026-07-18T10:00:00Z',
        'cover_image_url': null,
      }
    ]);
    final controller = EbookLibraryController(apiClient: fakeClient);

    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
        home: LibraryScreen(controller: controller),
      ));
      await Future.delayed(const Duration(milliseconds: 200));
    });

    await tester.pump();

    final bookFinder = find.text('Clean Architecture').first;
    expect(bookFinder, findsOneWidget);

    await tester.longPress(bookFinder, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Delete from Library'), findsOneWidget);

    await tester.tap(find.text('Delete from Library'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Confirm Delete'), findsOneWidget);
    expect(find.text('Are you sure you want to delete "Clean Architecture"? This action cannot be undone.'), findsOneWidget);
  });
}
