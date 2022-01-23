import 'package:flutter/material.dart';
import 'package:todo/model/todo.dart';
import 'package:todo/db/todo_database.dart';
import 'package:todo/widgets/dialog.dart';
import 'package:todo/constants/db.dart';

class TodoDetailPage extends StatefulWidget {
  final Task task;
  const TodoDetailPage(this.task, {Key? key}) : super(key: key);

  @override
  _TodoDetailPageState createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  late DateTime _dueDate;
  late String _priority;

  Future<DateTime> _selectDate(BuildContext context, Task task) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101, 12),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
    return _dueDate;
  }

  Future _updateTodo(Task task) async {
    task.title = _controller.text;
    task.description = _controller2.text;
    task.priority = _priority;
    task.dueDate = _dueDate;
    await TodoDatabase.instance.update(task);
    setState(
      () {
        _controller.clear();
        _controller2.clear();
      },
    );
    Navigator.of(context).pop(task);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SuccessDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Task task = widget.task;
    _dueDate = task.dueDate;
    _priority = task.priority;
    _controller.text = task.title;
    _controller2.text = task.description;
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _updateTodo(task);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Center(
            child: Flex(
          direction: Axis.vertical,
          children: [
            const Text('Todo name'),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter todo name',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Todo description'),
            TextField(
              controller: _controller2,
              decoration: const InputDecoration(
                hintText: 'Enter todo description',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Due date'),
            const SizedBox(width: 20),
            ElevatedButton(
              child: Text(_dueDate.toIso8601String()),
              onPressed: () async {
                task.dueDate = await (_selectDate(context, task));
              },
            ),
            const SizedBox(height: 20),
            const Text('Priority'),
            const SizedBox(width: 20),
            DropdownButton<String>(
              items: prioritys.map(
                (String value) {
                  return DropdownMenuItem(child: Text(value), value: value);
                },
              ).toList(),
              value: task.priority,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    task.priority = value;
                  });
                }
              },
            )
          ],
        )),
      ),
    );
  }
}
