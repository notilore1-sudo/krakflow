import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';


class Task {
  String title;
  String deadline;
  String priority;
  bool done;

  Task({
    required this.title,
    required this.deadline,
    required this.priority,
    this.done = false,
  });
}

class TaskRepository {
  static List<Task> tasks = [];
}

class TaskApiService {
  static const String baseUrl = "https://dummyjson.com";

  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse("$baseUrl/todos"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List todos = data["todos"];

      final random = Random();
      final priorities = ["niski", "średni", "wysoki"];
      final deadlines = ["dzisiaj", "jutro", "za tydzień", "w piątek"];

      return todos.map((todo) {
        final priority = priorities[random.nextInt(priorities.length)];
        final deadline = deadlines[random.nextInt(deadlines.length)];

        return Task(
          title: todo["todo"],
          deadline: deadline,
          priority: priority,
          done: todo["completed"],
        );
      }).toList();
    } else {
      throw Exception("Błąd pobierania danych z serwera");
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie";
  late Future<List<Task>> _futureTasks;

  @override
  void initState() {
    super.initState();
    _futureTasks = _loadInitialTasks();
  }

  Future<List<Task>> _loadInitialTasks() async {
    if (TaskRepository.tasks.isEmpty) {
      TaskRepository.tasks = await TaskApiService.fetchTasks();
    }
    return TaskRepository.tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Potwierdzenie"),
                    content: const Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Anuluj"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            TaskRepository.tasks.clear();
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Wszystkie zadania usunięte")),
                          );
                        },
                        child: const Text("Usuń"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: _futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          }
          else if (snapshot.hasData) {
            int completedTasks = TaskRepository.tasks.where((task) => task.done).length;

            List<Task> filteredTasks = TaskRepository.tasks;
            if (selectedFilter == "wykonane") {
              filteredTasks = TaskRepository.tasks.where((task) => task.done).toList();
            } else if (selectedFilter == "do zrobienia") {
              filteredTasks = TaskRepository.tasks.where((task) => !task.done).toList();
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("KrakFlow"),
                  const Text("Organizacja studiów"),
                  const Text("Dzisiejsze zadania"),
                  Text(
                    "Masz dziś ${TaskRepository.tasks.length} zadania (wykonano: $completedTasks)",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Dzisiejsze zadania",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = "wszystkie";
                          });
                        },
                        child: Text(
                          "Wszystkie",
                          style: TextStyle(
                            color: selectedFilter == "wszystkie" ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = "do zrobienia";
                          });
                        },
                        child: Text(
                          "Do zrobienia",
                          style: TextStyle(
                            color: selectedFilter == "do zrobienia" ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = "wykonane";
                          });
                        },
                        child: Text(
                          "Wykonane",
                          style: TextStyle(
                            color: selectedFilter == "wykonane" ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Dismissible(
                          key: ValueKey(task.title + index.toString()),
                          onDismissed: (direction) {
                            setState(() {
                              TaskRepository.tasks.remove(task);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Zadanie usunięte")),
                            );
                          },
                          child: TaskCard(
                            task: task,
                            onChanged: (value) {
                              setState(() {
                                task.done = value ?? false;
                              });
                            },
                            onTap: () async {
                              final updatedTask = await Navigator.push<Task>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTaskScreen(task: task),
                                ),
                              );

                              if (updatedTask != null) {
                                setState(() {
                                  final taskIndex = TaskRepository.tasks.indexOf(task);
                                  if (taskIndex != -1) {
                                    TaskRepository.tasks[taskIndex] = updatedTask;
                                  }
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("Brak zadań"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(),
            ),
          );

          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.done,
          onChanged: onChanged,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : TextDecoration.none,
            color: task.done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text("termin: ${task.deadline} | priorytet: ${task.priority}"),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nowe zadanie"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final newTask = Task(
                    title: titleController.text,
                    deadline: deadlineController.text,
                    priority: priorityController.text,
                    done: false,
                  );
                  Navigator.pop(context, newTask);
                },
                child: const Text("Zapisz"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController deadlineController;
  late TextEditingController priorityController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    deadlineController = TextEditingController(text: widget.task.deadline);
    priorityController = TextEditingController(text: widget.task.priority);
  }

  @override
  void dispose() {
    titleController.dispose();
    deadlineController.dispose();
    priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edytuj zadanie"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final updatedTask = Task(
                    title: titleController.text,
                    deadline: deadlineController.text,
                    priority: priorityController.text,
                    done: widget.task.done,
                  );
                  Navigator.pop(context, updatedTask);
                },
                child: const Text("Zapisz zmiany"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}