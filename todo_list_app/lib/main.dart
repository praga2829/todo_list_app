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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2764D7),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F6FC),
      ),
      home: const TodoHomePage(),
    );
  }
}

class TodoTask {
  TodoTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final int id;
  final String title;
  bool isCompleted;
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController _taskController = TextEditingController();
  final List<TodoTask> _tasks = <TodoTask>[];
  int _nextId = 0;
  String _filter = 'All';

  int get _completedCount =>
      _tasks.where((task) => task.isCompleted).length;

  int get _activeCount => _tasks.length - _completedCount;

  List<TodoTask> get _visibleTasks {
    switch (_filter) {
      case 'Active':
        return _tasks.where((task) => !task.isCompleted).toList();
      case 'Completed':
        return _tasks.where((task) => task.isCompleted).toList();
      default:
        return List<TodoTask>.from(_tasks);
    }
  }

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task first.')),
      );
      return;
    }

    setState(() {
      _tasks.insert(
        0,
        TodoTask(id: _nextId++, title: title),
      );
      _taskController.clear();
      _filter = 'All';
    });
    FocusScope.of(context).unfocus();
  }

  void _toggleTask(TodoTask task, bool? value) {
    setState(() {
      task.isCompleted = value ?? !task.isCompleted;
    });
  }

  void _deleteTask(TodoTask task) {
    setState(() {
      _tasks.removeWhere((item) => item.id == task.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.title}" deleted'),
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
      _tasks.removeWhere((task) => task.isCompleted);
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = _visibleTasks;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF174A9C),
        foregroundColor: Colors.white,
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          if (_completedCount > 0)
            TextButton.icon(
              onPressed: _clearCompleted,
              icon: const Icon(Icons.cleaning_services_outlined,
                  color: Colors.white),
              label: const Text(
                'Clear done',
                style: TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(width: 8),
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
                _buildAddTaskBox(),
                const SizedBox(height: 18),
                _buildSummary(),
                const SizedBox(height: 14),
                _buildFilters(),
                const SizedBox(height: 8),
                Expanded(
                  child: visibleTasks.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: visibleTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final task = visibleTasks[index];
                            return _buildTaskTile(task);
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
          colors: [Color(0xFF174A9C), Color(0xFF3478EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay focused.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'One task at a time. You’ve got this!',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskBox() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add a new task',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addTask(),
                    decoration: InputDecoration(
                      hintText: 'e.g. Complete Flutter assignment',
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                      filled: true,
                      fillColor: const Color(0xFFF7F9FD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _addTask,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Total tasks',
            value: '${_tasks.length}',
            icon: Icons.list_alt_rounded,
            iconColor: const Color(0xFF2764D7),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'To do',
            value: '$_activeCount',
            icon: Icons.pending_actions_rounded,
            iconColor: const Color(0xFFE08A18),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Completed',
            value: '$_completedCount',
            icon: Icons.task_alt_rounded,
            iconColor: const Color(0xFF1A9A68),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    const filters = ['All', 'Active', 'Completed'];

    return Wrap(
      spacing: 8,
      children: filters.map((filter) {
        return ChoiceChip(
          label: Text(filter),
          selected: _filter == filter,
          onSelected: (_) => setState(() => _filter = filter),
        );
      }).toList(),
    );
  }

  Widget _buildTaskTile(TodoTask task) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => _toggleTask(task, value),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration:
                task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.black45 : const Color(0xFF17233B),
          ),
        ),
        subtitle: Text(task.isCompleted ? 'Completed' : 'In progress'),
        trailing: IconButton(
          tooltip: 'Delete task',
          onPressed: () => _deleteTask(task),
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFD64545),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final message = _filter == 'Completed'
        ? 'No completed tasks yet.'
        : _filter == 'Active'
            ? 'You have no active tasks.'
            : 'Your task list is empty.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _filter == 'Completed'
                  ? Icons.task_alt_rounded
                  : Icons.checklist_rounded,
              size: 64,
              color: const Color(0xFF9AAAC2),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF34435B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add a task above to get started.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 23),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF17233B),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
