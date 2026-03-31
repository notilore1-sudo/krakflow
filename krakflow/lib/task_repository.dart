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

class TaskRepository {
  static List<Task> tasks = [
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
}