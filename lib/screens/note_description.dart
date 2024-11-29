import 'package:flutter/material.dart';
import 'package:notes_app/Database/notes_database_service.dart';

import '../commomwidgets/note_model_class.dart';

class NoteDescription extends StatefulWidget {
  NoteDescription({
    super.key,
    required this.savedDateTime,
    required this.title,
    required this.description,
  });

  final String savedDateTime;
  final String title;
  String description;

  @override
  State<NoteDescription> createState() => _NoteDescriptionState();
}

class _NoteDescriptionState extends State<NoteDescription> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  NotesDbService notesDbService = NotesDbService();
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // Title in AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_downward),
            onPressed: () {
              updateButtonPress(context);
              // Handle calendar action
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Delete Note"),
                    content: const Text(
                        "Are you sure you want to delete this note?"),
                    actions: [
                      TextButton(
                        child: const Text("No"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                          onPressed: () {
                            deleteButtonPress(context);
                          },
                          child: const Text("Yes")),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Handle rewrite/edit action
            },
          ),
        ],
      ),
      //  resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displaying the title as a Text widget
            // TextField(
            //   controller: _titleController,
            //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 16.0),
            // Displaying the description
            Expanded(
              child: TextField(
                controller: _descriptionController,
                style: const TextStyle(fontSize: 16),
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (value) {
                  widget.description = value;
                },
              ),
            ),
            const SizedBox(height: 16.0),
            // Displaying saved date and time
            Text(
              "Saved on: ${widget.savedDateTime}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void deleteButtonPress(BuildContext context) async {
    Notes notes = Notes(
        title: widget.title,
        dateTime: widget.savedDateTime,
        note: widget.description);
    NotesDbService notesDbService = NotesDbService();
    await notesDbService.delete(notes);
    // First pop to dismiss the alert dialog
    Navigator.of(context).pop();

    // Then pop to go back to the previous page
    Navigator.of(context).pop(true);
  }

  void updateButtonPress(BuildContext context) async {
    Notes notes = Notes(
        title: widget.title,
        dateTime: widget.savedDateTime,
        note: widget.description);
    await notesDbService.update(notes);
    Navigator.of(context).pop(false);
  }
}
