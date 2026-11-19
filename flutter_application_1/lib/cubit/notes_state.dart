part of 'notes_cubit.dart';

@immutable
class NotesState {
  final List<Note> notes;
  final int? editingIndex;

  const NotesState({this.notes = const [], this.editingIndex});

  bool get isEditing => editingIndex != null;

  NotesState copyWith({
    List<Note>? notes,
    int? editingIndex,
    bool clearEditingIndex = false,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      editingIndex: clearEditingIndex
          ? null
          : (editingIndex ?? this.editingIndex),
    );
  }
}
