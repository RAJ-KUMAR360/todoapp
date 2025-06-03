import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:project/pages/details_page.dart';
import 'package:project/task.dart';
import 'add_task_page.dart';
import 'profile_page.dart';
import 'package:intl/intl.dart'; // Add this import

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tasksCollection = FirebaseFirestore.instance.collection('tasks');

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            tasksCollection.orderBy('priority', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks =
              snapshot.data!.docs
                  .map(
                    (doc) => Task.fromMap(
                      doc.data()! as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList();

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first task',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isOverdue =
                  task.dueDate != null &&
                  task.dueDate!.isBefore(DateTime.now()) &&
                  !task.isDone;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Slidable(
                  key: Key(task.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          await tasksCollection.doc(task.id).delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Deleted "${task.title}"'),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () async {
                                  await tasksCollection
                                      .doc(task.id)
                                      .set(task.toMap());
                                },
                              ),
                            ),
                          );
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 2,
                    color:
                        isOverdue
                            ? Theme.of(context).colorScheme.errorContainer
                            : null,
                    child: ListTile(
                      leading: Container(
                        width: 8,
                        decoration: BoxDecoration(
                          color: task.priorityColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration:
                              task.isDone ? TextDecoration.lineThrough : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description.isNotEmpty)
                            Text(
                              task.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (task.dueDate != null)
                            Text(
                              DateFormat.yMMMd().format(task.dueDate!),
                              style: TextStyle(
                                color:
                                    isOverdue
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer
                                        : null,
                              ),
                            ),
                        ],
                      ),
                      trailing: Checkbox(
                        value: task.isDone,
                        onChanged: (value) async {
                          await tasksCollection.doc(task.id).update({
                            'isDone': value,
                          });
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailsPage(taskId: task.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
