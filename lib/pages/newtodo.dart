import 'package:flutter/material.dart';
import 'package:todo/model/todo.dart';
import 'package:todo/widgets/dialog.dart';
import 'package:todo/db/todo_database.dart';
import 'package:todo/constants/db.dart';

class Newtodo extends StatefulWidget {
  const Newtodo({Key? key}) : super(key: key);

  @override
  State<Newtodo> createState() => _NewtodoState();
}

class _NewtodoState extends State<Newtodo> {
  DateTime _duedate = DateTime.now();
  String _priority = 'Low';
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _duedate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101, 12),
    );
    if (picked != null && picked != _duedate) {
      setState(() {
        _duedate = picked;
      });
    }
  }

  Future _newTodo() async {
    final String _title = _controller.text;
    final String _description = _controller2.text;
    if (_title.isNotEmpty && _description.isNotEmpty) {
      final Task newTask = Task(
          title: _title,
          description: _description,
          dueDate: _duedate,
          priority: _priority);
      await TodoDatabase.instance.create(newTask);
      setState(() {
        _controller.clear();
        _controller2.clear();
      });
      Navigator.of(context).pop(newTask);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const SuccessDialog();
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New todo'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _newTodo,
          )
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
              child: Text(_duedate.toIso8601String()),
              onPressed: () {
                _selectDate(context);
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
              value: _priority,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _priority = value;
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
