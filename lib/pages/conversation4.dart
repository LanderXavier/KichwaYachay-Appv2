import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ConversationApp());

class ConversationApp extends StatelessWidget {
  const ConversationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Conversación",
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const ConversationScreen(),
    );
  }
}

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({Key? key}) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<Map<String, dynamic>> conversation = [];
  int currentIndex = 0; // Inicia en -1 para mostrar la primera línea al hacer clic en NEXT
  List<Widget> displayedConversation = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> loadConversation() async {
    final String response = await rootBundle.loadString('assets/database/conversation4.json');
    final data = json.decode(response) as List;
    setState(() {
      conversation = data.map((item) => item as Map<String, dynamic>).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadConversation();
  }

  void showNextMessage() {
    if (currentIndex < conversation.length - 1) {
      setState(() {
        currentIndex++;
        displayedConversation.add(
          _buildMessage(
            conversation[currentIndex]['speaker'],
            conversation[currentIndex]['bot'],
            conversation[currentIndex]['translation'],
          ),
        );
      });

      // Reproducir audio asociado a la línea de diálogo
      _playAudio(conversation[currentIndex]['audio']);
    }
  }

  Future<void> _playAudio(String audioPath) async {
    await _audioPlayer.stop(); // Detener audio previo
    await _audioPlayer.play(AssetSource(audioPath)); // Reproducir nuevo audio
  }

  Widget _buildMessage(String speaker, String message, String? translation) {
    bool isSisa = speaker == "Sisa"; // Diferenciar los personajes

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isSisa ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isSisa)
            const CircleAvatar(
              child: Icon(Icons.smart_toy, color: Colors.white),
              backgroundColor: Colors.teal,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isSisa ? Colors.teal[100] : Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    speaker,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSisa ? Colors.teal : Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (translation != null)
                    Text(translation, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
          ),
          if (!isSisa) const SizedBox(width: 10),
          if (!isSisa)
            const CircleAvatar(
              child: Icon(Icons.person, color: Colors.white),
              backgroundColor: Colors.teal,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Liberar recursos del reproductor de audio
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversación"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: displayedConversation.length,
                itemBuilder: (context, index) {
                  return displayedConversation[index];
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: currentIndex < conversation.length - 1 ? showNextMessage : null,
              child: const Text("NEXT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
