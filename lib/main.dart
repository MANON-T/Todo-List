import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/AddTodoScreen.dart';
import 'package:flutter_application_3/screens/EditTodoScreen.dart';
import 'package:flutter_application_3/screens/CalendarScreen.dart'; // เพิ่ม import
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Todo {
  String title;
  String content;
  DateTime dueDate;

  Todo({
    required this.title,
    required this.content,
    required this.dueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'dueDate': dueDate.toIso8601String(),
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      content: json['content'],
      dueDate: DateTime.parse(json['dueDate']),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> todos = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadTodoList();
  }

  Future<void> loadTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListJson = prefs.getString('todoList');
    if (todoListJson != null) {
      setState(() {
        Iterable list = json.decode(todoListJson);
        todos = list.map((model) => Todo.fromJson(model)).toList();
        // เรียงลำดับรายการ Todo ตามวันและเวลาที่กำหนดไว้ใน dueDate จากน้อยไปมาก
        todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      });
    }
  }

  Future<void> saveTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListJson = json.encode(todos.map((e) => e.toJson()).toList());
    prefs.setString('todoList', todoListJson);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalendarScreen()), // นำทางไปยังหน้าปฏิทิน
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(todos[index].title),
            background: Container(
              color: Colors.red,
              child: Icon(Icons.delete),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20.0),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Confirm"),
                    content: Text("Are you sure you want to delete this item?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text("DELETE"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("CANCEL"),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) {
              setState(() {
                todos.removeAt(index); // Remove the item from the data source
                saveTodoList(); // Save todo list after removal
              });
            },
            child: ListTile(
              title: Text(
                todos[index].title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    'Content: ${todos[index].content}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Due Date: ${todos[index].dueDate.toString()}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              onTap: () async {
                final editedTodo = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditTodoScreen(todo: todos[index]),
                  ),
                );

                if (editedTodo != null) {
                  setState(() {
                    todos[index] = editedTodo;
                    saveTodoList(); // Save todo list after editing todo
                  });
                }
              },
              trailing: IconButton(
                icon: Icon(Icons.info),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Todo Details'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Title: ${todos[index].title}'),
                            SizedBox(height: 5),
                            Text('Content: ${todos[index].content}'),
                            SizedBox(height: 5),
                            Text('Due Date: ${todos[index].dueDate.toString()}'),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('CLOSE'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTodo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTodoScreen()),
          );

          if (newTodo != null) {
            setState(() {
              todos.add(newTodo);
              saveTodoList(); // Save todo list after adding new todo
            });
          }
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add Todo',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
