import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    List<Task> tasks = [
      Task(
        title: "Przygotować prezentację",
        deadline: "jutro",
        priority: "wysoki",
        done: false,
      ),
      Task(
        title: "Oddać raport z laboratoriów",
        deadline: "dzisiaj",
        priority: "wysoki",
        done: true,
      ),
      Task(
        title: "Powtórzyć widgety Flutter",
        deadline: "w piątek",
        priority: "średni",
        done: false,
      ),
      Task(
        title: "Napisać notatki do kolokwium",
        deadline: "w weekend",
        priority: "niski",
        done: false,
      ),
    ];

    int completedTasks = tasks.where((task) => task.done).length;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("KrakFlow"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Masz dziś ${tasks.length} zadania (wykonano: $completedTasks)",
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
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(task: tasks[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          task.done ? Icons.check_circle : Icons.radio_button_unchecked,
        ),
        title: Text(task.title),
        subtitle: Text("termin: ${task.deadline} | priorytet: ${task.priority}"),
      ),
    );
  }
}
