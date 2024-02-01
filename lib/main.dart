import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:todo_list/PriorityLevel.dart';
import 'Task.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskDashboard(),
    );
  }
}

class TaskDashboard extends StatefulWidget {
  @override
  State<TaskDashboard> createState() => _TaskDashboardState();
}

class _TaskDashboardState extends State<TaskDashboard> {
  late InAppWebViewController _webViewController;
  List<Task> taskList = [];
  TextEditingController taskNameController = TextEditingController();
  SharedPreferences? _prefs;
  String _selectedPriority = PriorityLevel.low;

  void addTask() {
    String taskName = taskNameController.text;
    if (taskName.isNotEmpty) {
      setState(() {
        Task newTask = Task(name: taskName, priority: _selectedPriority);

        // taskList.insert(0, newTask);
        taskList.insert(0, newTask);
        // taskList.sort((a, b) => _comparePriority(a.priority, b.priority));
      });
      _saveTaskData();

      taskNameController.clear();
    }
  }

  Widget spinner() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 5, 0, 0),
            child: Text(
              'Choose Priority',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
          child: DropdownButtonFormField(
              value: _selectedPriority,
              items: [
                DropdownMenuItem(
                  child: Text(PriorityLevel.low),
                  value: PriorityLevel.low,
                ),
                DropdownMenuItem(
                  child: Text(PriorityLevel.medium),
                  value: PriorityLevel.medium,
                ),
                DropdownMenuItem(
                  child: Text(PriorityLevel.high),
                  value: PriorityLevel.high,
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPriority = newValue!;
                });
              }),
        ),
      ],
    );
  }

  // Widget _dropMenuItem(String priorityLevel) {
  //   return Container(
  //     color: PriorityLevel.getColor(priorityLevel),
  //     padding: EdgeInsets.all(10),
  //     child: Text(
  //       priorityLevel,
  //       style: TextStyle(color: Colors.white),
  //     ),
  //   );
  // }

  int _comparePriority(String priorityA, String priorityB) {
    final priorityOrder = {
      PriorityLevel.low: 0,
      PriorityLevel.medium: 1,
      PriorityLevel.high: 2
    };
    return priorityOrder[priorityA]!.compareTo(priorityOrder[priorityB]!);
  }

  void markTaskComplete(int index) {
    setState(() {
      taskList[index].isCompleted = !taskList[index].isCompleted;
    });
    _saveTaskData();
  }

  void deleteTask(int index) {
    setState(() {
      taskList.removeAt(index);
    });
    _saveTaskData();
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete the task'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: TextStyle(color: Color.fromARGB(255, 234, 88, 81))),
            ),
            TextButton(
                onPressed: () {
                  deleteTask(index);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.blue),
                ))
          ],
        );
      },
    );
  }

  Widget addText() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: taskNameController,
              decoration: InputDecoration(
                labelText: 'Task Name',
              ),
            ),
          ),
          SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: addTask,
            child: Text('Add Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return Expanded(
        child: ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        Task task = taskList[index];
        Color color = PriorityLevel.getColor(task.priority);

        return Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(5)),
          child: ListTile(
            title: Text(
              task.name,
              style: TextStyle(
                color: Colors.black,
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (newValue) {
                markTaskComplete(index);
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(index);
              },
            ),
          ),
        );
      },
    ));
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadTaskDatabase() async {
    await _initSharedPreferences();
    List<String>? taskData = _prefs?.getStringList('taskData');
    if (taskData != null) {
      setState(() {
        taskList = taskData
            .map((taskJson) => Task.fromJson(jsonDecode(taskJson)))
            .toList();
        // taskList.sort((a, b) => a.priority.compareTo(b.priority));
        taskList = taskList.toList();
      });
    }
  }

  void initState() {
    super.initState();
    _initSharedPreferences();
    _loadTaskDatabase();
  }

  // Future<void> _loadTaskDatabase() async {
  //   String? taskDataString =
  //       js.context['localStorage'].callMethod('getItem', ['taskData']);
  //   if (taskDataString != null) {
  //     List<dynamic> taskData = jsonDecode(taskDataString);
  //     setState(() {
  //       taskList = taskData.map((taskJson) => Task.fromJson(taskJson)).toList();
  //     });
  //   }
  // }

  Future<void> _saveTaskData() async {
    await _initSharedPreferences();
    List<String> taskData =
        taskList.map((task) => jsonEncode(task.toJson())).toList();
    // taskList.sort((a, b) => _comparePriority(a.priority, b.priority));

    // taskList.sort((a, b) => a.priority.compareTo(b.priority));

    //to save data on browser
    // js.context['localStorage']
    //     .callMethod('setItem', ['taskData', jsonEncode(taskData)]);

    await _prefs?.setStringList('taskData', taskData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [addText(), spinner(), _buildTaskList()]),
    );
  }
}
