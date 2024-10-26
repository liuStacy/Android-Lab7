import 'package:flutter_test/flutter_test.dart';
import 'package:lab07/main.dart';
import 'package:lab07/todo_database.dart'; // Import your TodoDatabase
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize the database before the tests run
  final todoDatabase = TodoDatabase.instance;

  setUp(() async {
    // Clear the database before each test
    await todoDatabase.deleteTodoById(1); // Clear existing todos if needed
  });

  testWidgets('Adding a Todo item updates the database and ListView', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Check for empty state (assumes a message like 'No Todos' is shown initially)
    expect(find.text('No Todos'), findsOneWidget); // Adjust according to your UI

    // Tap the '+' icon to add a new todo item
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Assume there is a TextField to enter the todo title
    await tester.enterText(find.byType(TextField), 'New Todo'); // Enter a new todo title
    await tester.tap(find.text('Save')); // Simulate tapping the 'Save' button
    await tester.pumpAndSettle();

    // Check that the new todo appears in the ListView
    expect(find.text('New Todo'), findsOneWidget);

    // Check if the database contains the new entry
    final todos = await todoDatabase.getTodos();
    expect(todos.length, 1);
    expect(todos[0]['title'], 'New Todo');
  });

  testWidgets('Loading todos from database on app restart', (WidgetTester tester) async {
    // Add a todo item directly to the database
    await todoDatabase.insertTodo('Persisted Todo');

    // Rebuild the app and trigger a frame
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Check that the previously saved todo is displayed
    expect(find.text('Persisted Todo'), findsOneWidget);
  });

  testWidgets('Deleting a Todo item removes it from the database and ListView', (WidgetTester tester) async {
    // Add a todo item to the database
    await todoDatabase.insertTodo('Todo to Delete');

    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Verify that the todo is present
    expect(find.text('Todo to Delete'), findsOneWidget);

    // Long press to delete the todo
    await tester.longPress(find.text('Todo to Delete'));
    await tester.pumpAndSettle();

    // Verify that the todo is no longer in the ListView
    expect(find.text('Todo to Delete'), findsNothing);

    // Verify that the todo is deleted from the database
    final todos = await todoDatabase.getTodos();
    expect(todos.length, 0); // Ensure the database is empty
  });
}
