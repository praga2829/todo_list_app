
import 'package:flutter/material.dart';

void main() {
  runApp(const TodoListApp());
}

class TodoListApp extends StatelessWidget {
  const TodoListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

class Task {
  Task({
    required this.id,
    required this.title,
    this.completed = false,
  });

  final int id;
  final String title;
  bool completed;
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Task> _tasks = [];

  int _nextId = 0;
  String _filter = 'All';

  int get _completedCount =>
      _tasks.where((task) => task.completed).length;

  int get _activeCount => _tasks.length - _completedCount;

  List<Task> get _visibleTasks {
    if (_filter == 'Active') {
      return _tasks.where((task) => !task.completed).toList();
    }

    if (_filter == 'Completed') {
      return _tasks.where((task) => task.completed).toList();
    }

    return _tasks;
  }

  void _addTask() {
    final title = _controller.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task first.'),
        ),
      );
      return;
    }

    setState(() {
      _tasks.insert(
        0,
        Task(
          id: _nextId++,
          title: title,
        ),
      );

      _controller.clear();
      _filter = 'All';
    });

    FocusScope.of(context).unfocus();
  }

  void _toggleTask(Task task, bool? value) {
    setState(() {
      task.completed = value ?? false;
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.removeWhere((item) => item.id == task.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${task.title} deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _tasks.insert(0, task);
            });
          },
        ),
      ),
    );
  }

  void _clearCompleted() {
    setState(() {
      _tasks.removeWhere((task) => task.completed);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = _visibleTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF174A9C),
        foregroundColor: Colors.white,
        actions: [
          if (_completedCount > 0)
            TextButton(
              onPressed: _clearCompleted,
              child: const Text(
                'Clear done',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 18),
                _buildAddTaskCard(),
                const SizedBox(height: 18),
                _buildSummaryCards(),
                const SizedBox(height: 14),
                _buildFilters(),
                const SizedBox(height: 10),
                Expanded(
                  child: visibleTasks.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: visibleTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return _buildTaskCard(
                              visibleTasks[index],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF174A9C),
            Color(0xFF3478EE),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay focused!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'One task at a time. You can do it!',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.checklist_rounded,
            color: Colors.white,
            size: 45,
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskCard() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add a new task',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addTask(),
                    decoration: InputDecoration(
                      hintText: 'Enter your task...',
                      prefixIcon: const Icon(Icons.edit_note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            'Total tasks',
            _tasks.length,
            Icons.list_alt,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            'To do',
            _activeCount,
            Icons.pending_actions,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            'Completed',
            _completedCount,
            Icons.task_alt,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      children: ['All', 'Active', 'Completed'].map((filter) {
        return ChoiceChip(
          label: Text(filter),
          selected: _filter == filter,
          onSelected: (_) {
            setState(() {
              _filter = filter;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: Checkbox(
          value: task.completed,
          onChanged: (value) => _toggleTask(task, value),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.completed
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.completed ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Text(
          task.completed ? 'Completed' : 'In progress',
        ),
        trailing: IconButton(
          tooltip: 'Delete task',
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
          onPressed: () => _deleteTask(task),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = 'Your task list is empty.';

    if (_filter == 'Active') {
      message = 'No active tasks.';
    } else if (_filter == 'Completed') {
      message = 'No completed tasks yet.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.checklist_rounded,
            size: 65,
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text('Add a task above to get started.'),
        ],
      ),
    );
  }
}

