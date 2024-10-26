import 'package:flutter/material.dart';
import 'todo_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TodoDatabase _todoDatabase;
  List<Map<String, dynamic>> _todos = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _todoDatabase = TodoDatabase.instance;
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await _todoDatabase.getTodos();
    setState(() {
      _todos = todos;
    });
  }

  Future<void> _addTodo() async {
    final title = _controller.text;
    if (title.isNotEmpty) {
      await _todoDatabase.insertTodo(title);
      _controller.clear(); // Clear the input field after adding
      await _loadTodos();
    }
  }

  Future<void> _deleteTodoById(int id) async {
    await _todoDatabase.deleteTodoById(id);
    await _loadTodos();
  }

  // Confirmation dialog for deletion
  void _confirmDelete(int index, int todoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete item?"),
          content: const Text("Do you want to delete this item?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without deleting
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                _deleteTodoById(todoId); // Delete the item
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
        backgroundColor: Colors.deepPurple.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Add button and input field
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _addTodo,
                    child: const Text("Add"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "Enter a search term",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.deepPurple, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            // Display list or message when list is empty
            Expanded(
              child: _todos.isEmpty
                  ? const Center(child: Text('No items available!'))
                  : ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];
                  return GestureDetector(
                    onLongPress: () => _confirmDelete(index, todo['id']),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the text
                        children: [
                          Text('Item $index: '),
                          const SizedBox(width: 50), // Reduced spacing between the texts
                          Text(todo['title']),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}






