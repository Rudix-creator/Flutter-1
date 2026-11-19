import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/notes_cubit.dart';

void main() => runApp(const NotesApp());

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: BlocProvider(create: (_) => NotesCubit(), child: const NotesPage()),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();

  void _setControllerText(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заметки')),
      body: BlocListener<NotesCubit, NotesState>(
        listenWhen: (previous, current) =>
            previous.editingIndex != current.editingIndex,
        listener: (context, state) {
          if (state.editingIndex != null) {
            _setControllerText(state.notes[state.editingIndex!].text);
          } else {
            _controller.clear();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<NotesCubit, NotesState>(
            builder: (context, state) {
              final isEditing = state.isEditing;

              return Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: isEditing
                          ? 'Редактирование заметки'
                          : 'Введите заметку',
                      border: const OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_controller.text.trim().isEmpty) return;
                            context.read<NotesCubit>().saveNote(
                              _controller.text,
                            );
                            _controller.clear();
                          },
                          child: Text(isEditing ? 'Обновить' : 'Сохранить'),
                        ),
                      ),
                      if (isEditing) ...[
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () =>
                              context.read<NotesCubit>().cancelEditing(),
                          child: const Text('Отмена'),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: state.notes.isEmpty
                        ? const Center(child: Text('Заметок пока нет'))
                        : ListView.builder(
                            itemCount: state.notes.length,
                            itemBuilder: (context, index) {
                              final note = state.notes[index];

                              return Dismissible(
                                key: ValueKey(note.id),
                                background: Container(
                                  color: Colors.blueGrey,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Icon(
                                    Icons.star_border,
                                    color: Colors.white,
                                  ),
                                ),
                                secondaryBackground: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    context.read<NotesCubit>().setImportant(
                                      index,
                                      false,
                                    );
                                    return false;
                                  }
                                  return true;
                                },
                                onDismissed: (_) => context
                                    .read<NotesCubit>()
                                    .deleteNote(index),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Заметка'),
                                        content: SingleChildScrollView(
                                          child: Text(note.text),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Закрыть'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  onDoubleTap: () => context
                                      .read<NotesCubit>()
                                      .setImportant(index, true),
                                  onLongPress: () => context
                                      .read<NotesCubit>()
                                      .startEditing(index),
                                  child: Card(
                                    color: note.isImportant
                                        ? Colors.amber.shade100
                                        : null,
                                    child: ListTile(
                                      leading: note.isImportant
                                          ? const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            )
                                          : null,
                                      title: Text(
                                        note.text,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => context
                                                .read<NotesCubit>()
                                                .startEditing(index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => context
                                                .read<NotesCubit>()
                                                .deleteNote(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
