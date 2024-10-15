import 'package:flutter/material.dart';
import 'todo.dart';
import 'todoaddpage.dart';
import 'todoeditpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todos = [];
  TodoFilter filter = TodoFilter.all;
  final _prefsKey = 'todos';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _saveTodos();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo', style: TextStyle(fontSize: 25, color:  Colors.black)),
        actions: [
          PopupMenuButton<TodoFilter>(
            onSelected: (newFilter) {
              setState(() {
                filter = newFilter;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TodoFilter.all,
                child: const Text('Все', style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: TodoFilter.completed,
                child: const Text('Выполненные', style: TextStyle(color: Colors.orange)),
              ),
              PopupMenuItem(
                value: TodoFilter.incomplete,
                child: const Text('Невыполненные', style: TextStyle(color: Colors.orange)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (filteredTodos.isEmpty)
            const Center(
              child: Text('Нет запланированных задач',
                  style: TextStyle(fontSize:20,color: Colors.white)),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredTodos.length,
                itemBuilder: (context, index) {
                  final todo = filteredTodos[index];
                  return Dismissible(
                    key: Key(todo.title),
                    onDismissed: (direction) {
                      setState(() {
                        todos.remove(todo);
                        _saveTodos();
                      });
                    },
                    background: Container(
                      color: Colors.orange,
                      alignment: Alignment.centerRight,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.black,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        todo.description,
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: todo.isCompleted,
                            onChanged: (value) {
                              setState(() {
                                todo.isCompleted = value!;
                                _saveTodos();
                              });
                            },
                            activeColor: Colors.orange,
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TodoEditPage(
                                    todo: todo,
                                    onEdit: (updatedTodo) {
                                      setState(() {
                                        if (updatedTodo == null) {
                                          todos.remove(todo);
                                        } else {
                                          todos[todos.indexOf(todo)] =
                                              updatedTodo;
                                        }
                                        _saveTodos();
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Удалить задачу',
                                        style: TextStyle(color: Colors.white)),
                                    content: const Text(
                                        'Вы уверены, что хотите удалить эту задачу?',
                                        style: TextStyle(color: Colors.orange)),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Отмена',
                                            style:
                                                TextStyle(color: Colors.orange)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            todos.remove(todo);
                                            _saveTodos();
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Удалить',
                                            style:
                                                TextStyle(color: Colors.orange)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.delete, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoAddPage(
                onAdd: (newTodo) {
                  setState(() {
                    todos.add(newTodo);
                    _saveTodos();
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  List<Todo> get filteredTodos {
    switch (filter) {
      case TodoFilter.all:
        return todos;
      case TodoFilter.completed:
        return todos.where((todo) => todo.isCompleted).toList();
      case TodoFilter.incomplete:
        return todos.where((todo) => !todo.isCompleted).toList();
    }
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    todos = [];
    for (int i = 0; i < 100; i++) { 
      final jsonTodo = prefs.getString('${_prefsKey}_$i');
      if (jsonTodo != null) {
        todos.add(Todo.fromJson(jsonTodo));
      }
    }
    setState(() {});
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonTodos = todos.map((todo) => jsonEncode(todo.toJson())).toList();

    for (int i = 0; i < jsonTodos.length; i++) {
      prefs.setString('${_prefsKey}_$i', jsonTodos[i]);
    }
  }
}

enum TodoFilter { all, completed, incomplete }
