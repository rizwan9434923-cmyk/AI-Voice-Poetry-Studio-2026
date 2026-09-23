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
              'Apni poetry ko voice mein convert karein.',
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
                      'Apni poetry ko voice mein convert karein.',
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
                          backgroundColor:
                              const Color(0xFF6B21A8),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
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

class _PoetryEditorScreenState
    extends State<PoetryEditorScreen> {
  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _poetryController =
      TextEditingController();

  final TextEditingController _voiceDirectionController =
      TextEditingController();

  final FlutterTts _flutterTts = FlutterTts();

  bool _isSpeaking = false;
  bool _loadingVoices = true;

  List<dynamic> _voices = [];
  dynamic _selectedVoice;

  double _speechRate = 0.45;
  double _pitch = 1.0;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _setupTts();
  }

  Future<void> _setupTts() async {
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(_pitch);

    await _loadVoices();

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

  Future<void> _loadVoices() async {
    try {
      final voices = await _flutterTts.getVoices;

      if (voices is List) {
        final filteredVoices = voices.where((voice) {
          if (voice is Map) {
            return voice['name'] != null;
          }
          return false;
        }).toList();

        if (mounted) {
          setState(() {
            _voices = filteredVoices;
            _loadingVoices = false;

            if (_voices.isNotEmpty) {
              _selectedVoice = _voices.first;
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingVoices = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingVoices = false;
        });
      }
    }
  }

  Future<void> _selectVoice(dynamic voice) async {
    if (voice is! Map) return;

    final name = voice['name'];
    final locale = voice['locale'];

    if (name == null || locale == null) {
      return;
    }

    try {
      await _flutterTts.setVoice({
        'name': name,
        'locale': locale,
      });

      if (mounted) {
        setState(() {
          _selectedVoice = voice;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ye voice device par select nahi ho saki.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _updateSpeechRate(double value) async {
    setState(() {
      _speechRate = value;
    });

    await _flutterTts.setSpeechRate(value);
  }

  Future<void> _updatePitch(double value) async {
    setState(() {
      _pitch = value;
    });

    await _flutterTts.setPitch(value);
  }

  Future<void> _updateVolume(double value) async {
    setState(() {
      _volume = value;
    });

    await _flutterTts.setVolume(value);
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
          content: Text(
            'Pehle apni poetry likhein.',
          ),
        ),
      );
      return;
    }

    await _flutterTts.stop();

    // Description aur Voice Direction abhi
    // AI engine ke liye instructions hain.
    // Real AI/Natural voice next phase mein connect hogi.

    String speechText = poetry;

    // In fields ko read-aloud text mein add nahi kar rahe,
    // taake user ki poetry hi boli jaye.
    //
    // Ye variables next AI engine ke prompt mein use honge.
    if (description.isNotEmpty ||
        voiceDirection.isNotEmpty) {
      speechText = poetry;
    }

    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setVolume(_volume);

    if (_selectedVoice is Map) {
      final name = _selectedVoice['name'];
      final locale = _selectedVoice['locale'];

      if (name != null && locale != null) {
        try {
          await _flutterTts.setVoice({
            'name': name,
            'locale': locale,
          });
        } catch (_) {}
      }
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
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
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
              'Voice ka mood aur feeling batayein.',
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
                prefixIcon:
                    const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
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
                  borderRadius:
                      BorderRadius.circular(16),
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
              'Batayein poetry kis tarah bolni hai.',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  _voiceDirectionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Misal: Aahista, jazbati, dard bhari awaaz, aham alfaaz par zor...',
                prefixIcon: const Icon(
                  Icons.record_voice_over,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Voice Settings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.record_voice_over,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Voice Selection',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (_loadingVoices)
                      const Padding(
                        padding:
                            EdgeInsets.all(12),
                        child: Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      )
                    else if (_voices.isEmpty)
                      const Padding(
                        padding:
                            EdgeInsets.all(8),
                        child: Text(
                          'Device ki TTS voices available nahi hain.',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      )
                    else
                      DropdownButtonFormField<dynamic>(
                        value: _selectedVoice,
                        isExpanded: true,
                        decoration:
                            InputDecoration(
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        items: _voices.map((voice) {
                          final name =
                              voice['name']
                                  ?.toString() ??
                                  'Unknown Voice';

                          final locale =
                              voice['locale']
                                  ?.toString() ??
                                  '';

                          return DropdownMenuItem<
                              dynamic>(
                            value: voice,
                            child: Text(
                              '$name ($locale)',
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (voice) {
                          if (voice != null) {
                            _selectVoice(voice);
                          }
                        },
                      ),

                    const SizedBox(height: 24),

                    const Text(
                      'Speed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Row(
                      children: [
                        const Icon(Icons.slow_motion_video),
                        Expanded(
                          child: Slider(
                            min: 0.20,
                            max: 0.80,
                            divisions: 12,
                            value: _speechRate,
                            onChanged:
                                _updateSpeechRate,
                          ),
                        ),
                        Text(
                          _speechRate
                              .toStringAsFixed(2),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Pitch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Row(
                      children: [
                        const Icon(Icons.graphic_eq),
                        Expanded(
                          child: Slider(
                            min: 0.50,
                            max: 1.50,
                            divisions: 20,
                            value: _pitch,
                            onChanged:
                                _updatePitch,
                          ),
                        ),
                        Text(
                          _pitch
                              .toStringAsFixed(2),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Volume',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Row(
                      children: [
                        const Icon(Icons.volume_up),
                        Expanded(
                          child: Slider(
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            value: _volume,
                            onChanged:
                                _updateVolume,
                          ),
                        ),
                        Text(
                          '${(_volume * 100).round()}%',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(
                      Icons.auto_awesome,
                    ),
                    title: Text('Natural / Emotional'),
                    subtitle: Text(
                      'AI Natural Voice - Next Phase',
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.threed_rotation,
                    ),
                    title: Text('3D / Spatial Voice'),
                    subtitle: Text(
                      'Spatial audio - Next Phase',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed:
                    _isSpeaking
                        ? null
                        : _generateVoice,
                icon: const Icon(
                  Icons.play_arrow,
                ),
                label: const Text(
                  'Generate Voice',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF6B21A8),
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed:
                    _isSpeaking
                        ? _stopVoice
                        : null,
                icon: const Icon(Icons.stop),
                label: const Text(
                  'Stop Voice',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
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
