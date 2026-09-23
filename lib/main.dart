import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const AIVoicePoetryStudio());
}

class AIVoicePoetryStudio extends StatelessWidget {
  const AIVoicePoetryStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Voice & Poetry Studio',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B21A8),
        ),
      ),
      home: const PoetryStudio(),
    );
  }
}

class PoetryStudio extends StatelessWidget {
  const PoetryStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Al Voice & Poetry Studio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Poetry Studio',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Apni poetry ko natural AI voice mein convert karein.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.record_voice_over,
                      size: 60,
                      color: Color(0xFF6B21A8),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Poetry Studio',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Apni poetry ko natural AI voice mein convert karein.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PoetryEditorScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B21A8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Start Creating',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PoetryEditorScreen extends StatefulWidget {
  const PoetryEditorScreen({super.key});

  @override
  State<PoetryEditorScreen> createState() =>
      _PoetryEditorScreenState();
}

class _PoetryEditorScreenState extends State<PoetryEditorScreen> {
  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _poetryController =
      TextEditingController();

  final TextEditingController _voiceDirectionController =
      TextEditingController();

  final FlutterTts _flutterTts = FlutterTts();

  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _setupTts();
  }

  Future<void> _setupTts() async {
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = true;
        });
      }
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });

    _flutterTts.setCancelHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });

    _flutterTts.setErrorHandler((message) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice error: $message'),
          ),
        );
      }
    });
  }

  Future<void> _generateVoice() async {
    final description =
        _descriptionController.text.trim();

    final poetry =
        _poetryController.text.trim();

    final voiceDirection =
        _voiceDirectionController.text.trim();

    if (poetry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pehle apni poetry likhein.'),
        ),
      );
      return;
    }

    await _flutterTts.stop();

    // Current version uses device TTS.
    // Description and Voice Direction are saved as user instructions
    // and will be connected to the real AI voice engine in the next phase.

    String speechText = poetry;

    if (description.isNotEmpty ||
        voiceDirection.isNotEmpty) {
      speechText =
          '$poetry';
    }

    await _flutterTts.speak(speechText);
  }

  Future<void> _stopVoice() async {
    await _flutterTts.stop();

    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _descriptionController.dispose();
    _poetryController.dispose();
    _voiceDirectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poetry Editor'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Voice Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Batayein ke voice ka mood aur feeling kaisi honi chahiye.',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Misal: Udaas, gehri aur dil ko chhoo lene wali poetry...',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Apni Poetry Likhein',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _poetryController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText:
                    'Yahan apni poetry likhein...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Voice Direction / Bolne Ka Andaz',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'AI ko batayein ke poetry kis tarah bolni hai.',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _voiceDirectionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Misal: Aahista, jazbati, dard bhari awaaz, aham alfaaz par zor...',
                prefixIcon: const Icon(Icons.record_voice_over),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Voice Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    ListTile(
                      leading: Icon(
                        Icons.record_voice_over,
                      ),
                      title: Text('AI Voice'),
                      subtitle: Text(
                        'Device TTS Voice - Temporary',
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.speed),
                      title: Text('Voice Style'),
                      subtitle: Text(
                        'Natural / Emotional',
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.threed_rotation),
                      title: Text('3D / Spatial Voice'),
                      subtitle: Text(
                        'AI Spatial Voice - Next Phase',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                    _isSpeaking ? null : _generateVoice,
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'Generate Voice',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF6B21A8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed:
                    _isSpeaking ? _stopVoice : null,
                icon: const Icon(Icons.stop),
                label: const Text(
                  'Stop Voice',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
