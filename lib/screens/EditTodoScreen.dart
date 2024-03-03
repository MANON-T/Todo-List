import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_3/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditTodoScreen extends StatefulWidget {
  final Todo todo;

  EditTodoScreen({required this.todo});

  @override
  _EditTodoScreenState createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _contentController = TextEditingController(text: widget.todo.content);
    _selectedDate = widget.todo.dueDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.todo.dueDate);
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _presentTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Due Date: ${DateFormat('dd-MM-yyyy').format(_selectedDate)} ${_selectedTime.hour}:${_selectedTime.minute}', // Format due date and time
                  ),
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: Text('Choose Date'),
                ),
                TextButton(
                  onPressed: _presentTimePicker,
                  child: Text('Choose Time'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final enteredTitle = _titleController.text;
                final enteredContent = _contentController.text;

                if (enteredTitle.isEmpty || enteredContent.isEmpty) {
                  return;
                }

                final editedTodo = Todo(
                  title: enteredTitle,
                  content: enteredContent,
                  dueDate: DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  ),
                );

                Navigator.pop(context, editedTodo);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
