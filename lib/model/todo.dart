class TaskFields {
  static final List<String> values = [
    id,
    title,
    description,
    priority,
    dueDate,
    completed
  ];
  static const String id = '_id';
  static const String title = 'title';
  static const String description = 'description';
  static const String priority = 'priority';
  static const String dueDate = 'dueDate';
  static const String completed = 'completed';
}

class Task {
  bool completed = false;
  String title;
  String description;
  DateTime dueDate;
  String priority;
  int? id;

  Task(
      {required this.title,
      required this.description,
      required this.dueDate,
      this.priority = 'Low',
      this.id,
      this.completed = false});

  static Task fromJson(Map<String, Object?> json) => Task(
        id: json[TaskFields.id] as int?,
        title: json[TaskFields.title] as String,
        description: json[TaskFields.description] as String,
        dueDate: DateTime.parse(json[TaskFields.dueDate] as String),
        priority: json[TaskFields.priority] as String,
        completed: json[TaskFields.completed] == 1,
      );

  Map<String, Object?> toJson() => {
        TaskFields.id: id,
        TaskFields.title: title,
        TaskFields.description: description,
        TaskFields.priority: priority,
        TaskFields.dueDate: dueDate.toIso8601String(),
        TaskFields.completed: completed ? 1 : 0,
      };

  copy({
    int? id,
    bool? completed,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
  }) =>
      Task(
          title: title ?? this.title,
          description: description ?? this.description,
          dueDate: dueDate ?? this.dueDate,
          priority: priority ?? this.priority,
          id: id ?? this.id);
}
/*

List<Task> _todoList = <Task>[];

void addTodoItem(Task task) {
  _todoList.add(task);
}

List<Task> getList() {
  return _todoList;
}

void setList(List<Task> _list) {
  _todoList = _list;
}
*/