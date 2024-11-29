import 'package:flutter/material.dart';

class NoteContainer extends StatelessWidget {
  final String title;
  final String note;
  final String dateTime;

  const NoteContainer({
    super.key,
    required this.title,
    required this.note,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        //  color: Colors.grey[850],
        color: Colors.white70,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Note section
          Text(
            note,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          // DateTime at bottom right
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              dateTime,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
