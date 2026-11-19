import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/cubit/notes_cubit.dart';

void main() {
  test('Editing and deleting preserve the correct note and importance', () {
    final cubit = NotesCubit();
    addTearDown(cubit.close);
    cubit.saveNote('Первая');
    cubit.saveNote('Вторая');
    cubit.setImportant(1, true);
    cubit.startEditing(1);
    cubit.deleteNote(0);
    expect(cubit.state.editingIndex, 0);
    expect(cubit.state.notes.single.isImportant, isTrue);
    cubit.saveNote('Изменённая');
    expect(cubit.state.notes.single.text, 'Изменённая');
    expect(cubit.state.notes.single.isImportant, isTrue);
    expect(cubit.state.isEditing, isFalse);
    cubit.setImportant(0, false);
    expect(cubit.state.notes.single.isImportant, isFalse);
    cubit.startEditing(0);
    cubit.deleteNote(0);
    expect(cubit.state.notes, isEmpty);
    expect(cubit.state.isEditing, isFalse);
  });

  testWidgets('All five note gestures work together', (tester) async {
    await tester.pumpWidget(const NotesApp());
    await tester.enterText(find.byType(TextField), 'Полный текст заметки');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Полный текст заметки'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Полный текст заметки'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Полный текст заметки'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Полный текст заметки'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.longPress(find.text('Полный текст заметки'));
    await tester.pumpAndSettle();
    expect(find.text('Обновить'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Полный текст заметки',
    );
    await tester.enterText(find.byType(TextField), 'Новый текст');
    await tester.tap(find.text('Обновить'));
    await tester.pumpAndSettle();
    expect(find.text('Новый текст'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);

    await tester.drag(find.byType(Dismissible), const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.text('Новый текст'), findsOneWidget);

    await tester.drag(find.byType(Dismissible), const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Новый текст'), findsOneWidget);

    await tester.drag(find.byType(Dismissible), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Новый текст'), findsNothing);
    expect(find.text('Заметок пока нет'), findsOneWidget);
  });
}
