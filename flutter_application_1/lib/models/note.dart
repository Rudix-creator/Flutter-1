class Note {
  final int id;
  final String text;
  final bool isImportant;

  const Note({required this.id, required this.text, this.isImportant = false});

  Note copyWith({String? text, bool? isImportant}) {
    return Note(
      id: id,
      text: text ?? this.text,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}
