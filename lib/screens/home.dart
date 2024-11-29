import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notes_app/screens/note_description.dart';
import '../Database/notes_database_service.dart';
import '../commomwidgets/note_container.dart';
import '../commomwidgets/note_model_class.dart';
import 'note.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _NotesAppState();
}

class _NotesAppState extends State<Home> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabExpanded = true;
  NotesDbService notesDbService = NotesDbService();

  // State variable
  Future<List<Notes>>? notesList; // List to hold notes

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isFabExpanded) {
          setState(() {
            _isFabExpanded = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFabExpanded) {
          setState(() {
            _isFabExpanded = true;
          });
        }
      }
    });
    // Initialize the notesList Future directly without setState
    notesList = notesDbService.fetch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    //var width = size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          //1
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
          //2
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Delete All Notes"),
                    content: const Text(
                        "Are you sure you want to delete all notes?"),
                    actions: [
                      TextButton(
                        child: const Text("No"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                          onPressed: deleteButtonPress,
                          child: const Text("Yes")),
                    ],
                  );
                },
              );
            },
          ),
//3

          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Notes>>(
              future: notesList, // The future to be resolved
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator()); // Show loading indicator
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          "Error: ${snapshot.error}")); // Show error message
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text(
                    'No notes available',
                    style: TextStyle(color: Colors.white),
                  )); // Show message if no notes
                } else {
                  // If data is available
                  final notess = snapshot.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: notess.length,
                    itemBuilder: (context, index) {
                      final note = notess[index];
                      return InkWell(
                        onTap: () async {
                          var result = await Navigator.of(context)
                              .push(MaterialPageRoute(
                            builder: (context) {
                              return NoteDescription(
                                title: note.title!,
                                description: note.note!,
                                savedDateTime: note.dateTime!,
                              );
                            },
                          ));
                          if (result == true) {
                            // If a note was deleted, refresh the list
                            setState(() {
                              notesList =
                                  notesDbService.fetch(); // Re-fetch the notes
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Note Deleted successfully')),
                            );
                          } else {
                            setState(() {
                              notesList =
                                  notesDbService.fetch(); // Re-fetch the notes
                            });
                          }
                        },
                        //
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text('Delete'),
                                      onTap: () async {
                                        await notesDbService.delete(note);
                                        setState(() {
                                          notesList = notesDbService.fetch();
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Note Deleted successfully')),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.push_pin),
                                      title: const Text('Pin'),
                                      onTap: () {
                                        // Handle pin logic here
                                        Navigator.pop(
                                            context); // Close the modal
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },

                        //
                        child: Column(
                          children: [
                            NoteContainer(
                              title: note.title!,
                              note: note.note!,
                              dateTime: note.dateTime!,
                            ),
                            SizedBox(
                              height: height * 0.01,
                            )
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isFabExpanded ? 56.0 : 70.0,
        height: _isFabExpanded ? 56.0 : 70.0,
        child: FloatingActionButton(
          onPressed: onButtonPress,
          shape: _isFabExpanded
              ? const CircleBorder()
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void onButtonPress() async {
    final result = await Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) {
        return const Note();
      },
    ));

    if (result == true) {
      setState(() {
        notesList =
            notesDbService.fetch(); // Fetch notes again after adding a new one
      });
    }
  }

  void deleteButtonPress() async {
    await NotesDbService().deleteAllNotes();

    Navigator.of(context).pop();
    setState(() {
      notesList = notesDbService.fetch();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note Deleted successfully')),
      ); // Re-fetch the notes
    });
  }
}
