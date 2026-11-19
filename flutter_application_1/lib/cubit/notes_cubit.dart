import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/note.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(const NotesState());

  int _nextId = 0;

  void saveNote(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final updatedNotes = List<Note>.from(state.notes);
    final editingIndex = state.editingIndex;

    if (editingIndex == null) {
      updatedNotes.add(Note(id: _nextId++, text: trimmed));
    } else {
      updatedNotes[editingIndex] = updatedNotes[editingIndex].copyWith(
        text: trimmed,
      );
    }

    emit(state.copyWith(notes: updatedNotes, clearEditingIndex: true));
  }

  void setImportant(int index, bool isImportant) {
    final updatedNotes = List<Note>.from(state.notes);
    updatedNotes[index] = updatedNotes[index].copyWith(
      isImportant: isImportant,
    );
    emit(state.copyWith(notes: updatedNotes));
  }

  void startEditing(int index) {
    emit(state.copyWith(editingIndex: index));
  }

  void cancelEditing() {
    emit(state.copyWith(clearEditingIndex: true));
  }

  void deleteNote(int index) {
    final updatedNotes = List<Note>.from(state.notes)..removeAt(index);
    int? newEditingIndex = state.editingIndex;

    if (newEditingIndex != null) {
      if (newEditingIndex == index) {
        newEditingIndex = null;
      } else if (newEditingIndex > index) {
        newEditingIndex = newEditingIndex - 1;
      }
    }

    emit(NotesState(notes: updatedNotes, editingIndex: newEditingIndex));
  }
}
