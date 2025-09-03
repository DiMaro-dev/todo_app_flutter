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
  bool _showCompletionMessage = false; // controlla se mostrare il messaggio di completamento

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

                      // Gestione data/ora migliorata
                      if (selectedDate != null && selectedTime != null) {
                        // Se sono selezionati sia data che ora
                        finalDateTime = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        );
                      } else if (selectedDate != null) {
                        // Se è selezionata solo la data (imposta mezzanotte come orario predefinito)
                        finalDateTime = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                        );
                      } else if (selectedTime != null) {
                        // Se è selezionato solo l'orario (usa la data corrente)
                        final now = DateTime.now();
                        finalDateTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        );
                      }

                      Navigator.of(context).pop(); // Chiude prima il dialog

                      // Poi aggiorna la lista
                      setState(() {
                        tasks.add(Task(
                          title: title,
                          taskDate: finalDateTime,
                        ));

                        // Controlla se tutte le task sono completate dopo l'aggiunta
                        _checkAllTasksCompleted();
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

      // Controlla se tutte le task sono completate
      _checkAllTasksCompleted();
    });
  }

  // Controlla se tutte le task sono completate e mostra il messaggio temporaneo
  void _checkAllTasksCompleted() {
    final allTasksCompleted = tasks.isNotEmpty && tasks.every((task) => task.isDone);

    if (allTasksCompleted) {
      // Mostra il messaggio di completamento
      setState(() {
        _showCompletionMessage = true;
      });

      // Nasconde il messaggio dopo 3 secondi
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showCompletionMessage = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // fornisce la struttura base dell'interfaccia
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          // Mostra la lista di task o il messaggio di nessuna attività
          tasks.isEmpty // se non ci sono task
              ? const Center(
            child: Text(
              'Non ci sono attività', // scrive questo
              // magaria aggiungere anche animazione o gif..
              style: TextStyle(fontSize: 18),
            ),
          )
          // altrimenti mostra la lista di tutte le task disponibili
              : ListView.builder( // crea solo i widget visibili.
            itemCount: tasks.length, // lunghezza della lista basata su quante Task
            itemBuilder: (context, index) { // accede alla task all'indice index
              final task = tasks[index];
              return ListTile(
                leading: IconButton(
                  icon: Icon(
                    task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                    color: task.isDone ? Colors.green : null,
                  ),
                  onPressed: () => _setTask(index), // imposta lo stato della task a fatto e viceversa
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

          // Mostra il messaggio di completamento temporaneo sopra la lista -- da migliorare con qualche animazione carina invece di un banner
          if (_showCompletionMessage)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Hai completato tutto, ora riposati',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended( // widget pulsante icona + testo
        onPressed: _showAddTaskDialog, // richiama il dialog
        tooltip: 'Aggiungi attività',
        label: const Text('Add new'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}