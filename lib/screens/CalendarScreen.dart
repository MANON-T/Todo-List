import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Todo> _todosForSelectedDate = [];

  @override
  void initState() {
    super.initState();
    loadTodoListForDate(_selectedDate);
  }

  Future<void> loadTodoListForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final todoListJson = prefs.getString('todoList');
    if (todoListJson != null) {
      setState(() {
        Iterable list = json.decode(todoListJson);
        _todosForSelectedDate = list
            .map((model) => Todo.fromJson(model))
            .where((todo) =>
                todo.dueDate.year == date.year &&
                todo.dueDate.month == date.month &&
                todo.dueDate.day == date.day)
            .toList();
        // เรียงลำดับรายการ Todo ตามเวลาที่กำหนดไว้ใน dueDate จากน้อยไปมาก
        _todosForSelectedDate.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(Duration(days: 1));
                      loadTodoListForDate(_selectedDate);
                    });
                  },
                ),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: TextStyle(fontSize: 20.0),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(Duration(days: 1));
                      loadTodoListForDate(_selectedDate);
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todosForSelectedDate.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_todosForSelectedDate[index].title),
                  subtitle: Text(_todosForSelectedDate[index].content),
                  trailing: Text(
                    '${_todosForSelectedDate[index].dueDate.hour}:${_todosForSelectedDate[index].dueDate.minute}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
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
