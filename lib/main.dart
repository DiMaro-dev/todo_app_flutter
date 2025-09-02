import 'package:flutter/material.dart'; // design google android

void main() {
  runApp(const MyApp()); // entry point app
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
      home: const MyHomePage(title: 'To Do List'), // pagina inziale
    );
  }
}

// classe creazione Task
class Task {
  String title;
  bool isDone;
  DateTime? taskDate; // opzionale

  Task({required this.title, this.isDone = false, this.taskDate});
}

class MyHomePage extends StatefulWidget { // widget con stato
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
  // creazione dello stato associato al widget
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> tasks = []; // lista di oggetti appartenenti a Task

  // Funzione che mostra un dialog per aggiungere una task
  void _showAddTaskDialog() {
    final TextEditingController controller = TextEditingController(); // messo per gestire input text
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // finestra dialogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // serve per creare e gestire stati semplici per un dialog - temporanei
          builder: (context, setDialogState) {
            return AlertDialog( // widget dialog - title, content ecc
              title: const Text('Nuova attività'),
              content: Column(
                mainAxisSize: MainAxisSize.min, // adatta il dialog al minimo spazio (verticale)
                children: [
                  TextField( // input utente, controller già assegnato
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Titolo attività', // simile ad un "placeholder"
                    ),
                  ),
                  const SizedBox(height: 16),

                  // pulsante con icona calendario
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async { // funzione anonima che apre la scelta della data
                          final DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setDialogState(() {
                              selectedDate = date;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8), // aggiorna e mostra data selezionata
                      Text(
                        selectedDate == null
                            ? 'Nessuna data selezionata'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      ),
                    ],
                  ),

                  // Pulsante con icona orologio
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async { // funzione anonima sta volta per scelta ora
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() {
                              selectedTime = time;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedTime == null
                            ? 'Nessun orario selezionato'
                            : selectedTime!.format(context),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [  // di AlertDialog
                TextButton(
                  child: const Text('Annulla'),
                  onPressed: () { // funzione anonima, se premuto esce dal dialog
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Aggiungi'),
                  onPressed: () {
                    final String title = controller.text.trim();
                    if (title.isNotEmpty) {
                      DateTime? finalDateTime;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////7
                     /////CONTINUARE DA QUI
                      // sistemare -- anche se selezionato solo la data va bene niente orario, mentre se solo orario mette di default data corrente.
                      if (selectedDate != null && selectedTime != null) {
                        finalDateTime = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        );
                      }

                      Navigator.of(context).pop(); // Chiude prima il dialog

                      // Poi aggiorna la lista nel vero setState
                      setState(() {
                        tasks.add(Task(
                          title: title,
                          taskDate: finalDateTime,
                        ));
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // cambia lo stato della task
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
            subtitle: task.taskDate != null
                ? Text(
              '${task.taskDate!.day}/${task.taskDate!.month}/${task.taskDate!.year} ${task.taskDate!.hour}:${task.taskDate!.minute.toString().padLeft(2, '0')}',
            )
                : null,
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