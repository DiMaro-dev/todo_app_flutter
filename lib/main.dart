import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'To Do List'),
    );
  }
}

// classe creazione Task
class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> tasks = []; // lista di oggetti

  // Mostra un dialog per aggiungere un'attività
  void _showAddTaskDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nuova attività'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Titolo attività',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop(); // Chiude il dialog
              },
            ),
            ElevatedButton(
              child: const Text('Aggiungi'),
              onPressed: () {
                final String title = controller.text.trim();
                if (title.isNotEmpty) {
                  setState(() {
                    tasks.add(Task(title: title)); // aggiunge un oggetto Task alla list
                  });
                }
                Navigator.of(context).pop(); // Chiude il dialog
              },
            ),
          ],
        );
      },
    );
  }

  // cambia lo stato delle Task
  void _setTask(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Text(
          'Non ci sono attività',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            leading: IconButton(
              icon: Icon(
                task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                color: task.isDone ? Colors.green : null,
              ),
              onPressed: () => _setTask(index),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: task.isDone ? Colors.grey : null,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        tooltip: 'Aggiungi attività',
        label: const Text('Add new'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
