import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import '../Database/notes_database_service.dart';
import '../commomwidgets/note_model_class.dart';

class Note extends StatefulWidget {
  const Note({super.key});

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  String? savedDateTime;
  String? title;
  String? description;

  // Speech-to-text variables
  final SpeechToText speechToText = SpeechToText();
  bool isSpeechEnabled = false;
  bool isListening = false;
  double confidence = 0;

  // Image text recognition variables
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeSpeech();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Handle calendar action
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Handle delete action
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                title = value;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      icon: Icon(isListening ? Icons.mic_off : Icons.mic),
                      onPressed: isListening ? stopListening : startListening,
                    ),
                  ],
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            Text(
              savedDateTime != null
                  ? "Saved on: $savedDateTime"
                  : "No date saved",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Text(
              "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: _saveDateTime,
          child: const Icon(Icons.check),
        ),
      ),
    );
  }

  // Initialize speech recognition
  void initializeSpeech() async {
    isSpeechEnabled = await speechToText.initialize();
    setState(() {});
  }

  // Start listening to the user’s voice
  void startListening() {
    if (isSpeechEnabled) {
      setState(() => isListening = true);
      speechToText.listen(onResult: (result) {
        setState(() {
          description = result.recognizedWords;
          _descriptionController.text = description ?? '';
          confidence = result.confidence;
        });
      });
    }
  }

  // Stop listening to the user’s voice
  void stopListening() {
    speechToText.stop();
    setState(() => isListening = false);
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
      _detectText(File(pickedFile.path));
    }
  }

  // Detect text from the image
  Future<void> _detectText(File image) async {
    final textDetector = TextRecognizer();
    final inputImage = InputImage.fromFile(image);
    final recognizedText = await textDetector.processImage(inputImage);

    setState(() {
      description = recognizedText.text;
      _descriptionController.text = description ?? '';
    });

    textDetector.close();
  }

  // Save the note's date and time
  void _saveDateTime() {
    // Ensure the controller text is used for validation
    if (title == null ||
        title!.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and Description cannot be empty')),
      );
      return;
    }

    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd – hh:mm a').format(now);
    setState(() {
      savedDateTime = formattedDateTime;
      description = _descriptionController.text; // Sync the description
    });
    insertNote(formattedDateTime);
  }

  // Insert the note into the database
  void insertNote(String formattedDateTime) async {
    Notes note =
        Notes(title: title!, note: description!, dateTime: formattedDateTime);
    NotesDbService notesDbService = NotesDbService();

    await notesDbService.insert(note); // Ensure insertion is awaited

    Navigator.of(context)
        .pop(true); // Return true to indicate a new note was saved
  }
}
