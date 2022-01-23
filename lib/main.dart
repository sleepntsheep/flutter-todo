import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/pages/newtodo.dart';
import 'package:todo/pages/tododetail.dart';
import 'package:todo/model/todo.dart';
import 'package:todo/db/todo_database.dart';
import 'package:todo/widgets/dialog.dart';
import 'package:todo/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // ignore: prefer_const_constructors
  runApp(MaterialApp(title: 'Todo', home: Todo(), theme: theme));
}

class Todo extends StatefulWidget {
  const Todo({Key? key}) : super(key: key);

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  bool _isLoading = false;
  late List<Task> _todoList;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _refresh() async {
    setState(() => _isLoading = true);
    _todoList = await TodoDatabase.instance.readAllTask();
    setState(() => _isLoading = false);
  }

  void _newTodo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Newtodo()),
    ).then((val) {
      _refresh();
    });
  }

  Future _editTodo(item) async {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => TodoDetailPage(item),
      ),
    )
        .then(
      (val) {
        setState(() {
          _refresh();
        });
      },
    );
  }

  Widget _buildTodoList() => Builder(
        builder: (context) => ListView.builder(
          itemCount: _todoList.length,
          itemBuilder: (context, index) {
            final item = _todoList[index];
            return Dismissible(
              confirmDismiss: (DismissDirection direction) async {
                return await confirmDismissDialog(context);
              },
              key: UniqueKey(),
              onDismissed: (direction) async {
                await TodoDatabase.instance.delete(item.id ?? -1);
                setState(() {
                  _refresh();
                });
              },
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(item.description),
                leading: Checkbox(
                  value: item.completed,
                  onChanged: (value) {
                    setState(() {
                      item.completed = value!;
                      TodoDatabase.instance.update(item);
                    });
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _editTodo(item);
                  },
                ),
              ),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    // return CupertinoApp(
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: _isLoading
                ? const Text('Loading database...')
                : _buildTodoList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newTodo,
        tooltip: 'Add a new task',
        child: const Icon(CupertinoIcons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
