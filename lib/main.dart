import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

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
        title: const Text('AI Voice & Poetry Studio'),
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
              'Convert your poetry into voice.',
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
                      'Create a voice from your poetry.',
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
  bool _isSavingAudio = false;
  bool _loadingVoices = true;

  List<dynamic> _voices = [];
  dynamic _selectedVoice;

  double _speechRate = 0.45;
  double _pitch = 1.0;
  double _volume = 1.0;

  String? _savedAudioPath;

  @override
  void initState() {
    super.initState();
    _setupTts();
  }

  Future<void> _setupTts() async {
    try {
      await _flutterTts.awaitSpeakCompletion(true);

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
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingVoices = false;
        });
      }
    }
  }

  Future<void> _loadVoices() async {
    try {
      final voices = await _flutterTts.getVoices;

      if (voices is List) {
        final filteredVoices = voices.where((voice) {
          if (voice is Map) {
            return voice['name'] != null &&
                voice['locale'] != null;
          }
          return false;
        }).toList();

        if (mounted) {
          setState(() {
            _voices = filteredVoices;
            _loadingVoices = false;

            dynamic urduVoice;

            for (final voice in _voices) {
              final locale =
                  voice['locale']?.toString().toLowerCase() ?? '';

              final name =
                  voice['name']?.toString().toLowerCase() ?? '';

              if (locale == 'ur-pk' ||
                  locale.startsWith('ur-pk') ||
                  name.contains('ur-pk')) {
                urduVoice = voice;
                break;
              }
            }

            if (urduVoice != null) {
              _selectedVoice = urduVoice;
            } else if (_voices.isNotEmpty) {
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
    } catch (_) {
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
        'name': name.toString(),
        'locale': locale.toString(),
      });

      if (mounted) {
        setState(() {
          _selectedVoice = voice;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This voice could not be selected on this device.',
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

  Future<void> _applyCurrentVoice() async {
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setVolume(_volume);

    if (_selectedVoice is Map) {
      final name = _selectedVoice['name'];
      final locale = _selectedVoice['locale'];

      if (name != null && locale != null) {
        try {
          await _flutterTts.setVoice({
            'name': name.toString(),
            'locale': locale.toString(),
          });
        } catch (_) {}
      }
    }
  }

  Future<void> _forceUrduPakistanVoice() async {
    dynamic urduVoice;

    for (final voice in _voices) {
      if (voice is Map) {
        final locale =
            voice['locale']?.toString().toLowerCase() ?? '';

        final name =
            voice['name']?.toString().toLowerCase() ?? '';

        if (locale == 'ur-pk' ||
            locale.startsWith('ur-pk') ||
            name.contains('ur-pk')) {
          urduVoice = voice;
          break;
        }
      }
    }

    if (urduVoice != null) {
      final name = urduVoice['name'];
      final locale = urduVoice['locale'];

      try {
        await _flutterTts.setLanguage(locale.toString());

        await _flutterTts.setVoice({
          'name': name.toString(),
          'locale': locale.toString(),
        });
      } catch (_) {}
    } else {
      try {
        await _flutterTts.setLanguage('ur-PK');
      } catch (_) {}
    }
  }

  Future<void> _applyExpressionControls() async {
    final description =
        _descriptionController.text.trim().toLowerCase();

    final direction =
        _voiceDirectionController.text.trim().toLowerCase();

    double rate = _speechRate;
    double pitch = _pitch;

    if (description.contains('sad') ||
        description.contains('dard') ||
        description.contains('deep')) {
      rate = rate.clamp(0.25, 0.40).toDouble();
      pitch =
          (pitch - 0.08).clamp(0.50, 1.50).toDouble();
    }

    if (description.contains('soft')) {
      rate = rate.clamp(0.25, 0.42).toDouble();
    }

    if (description.contains('happy') ||
        description.contains('excited') ||
        description.contains('purjosh')) {
      rate = rate.clamp(0.45, 0.65).toDouble();
      pitch =
          (pitch + 0.05).clamp(0.50, 1.50).toDouble();
    }

    if (description.contains('calm')) {
      rate = rate.clamp(0.30, 0.45).toDouble();
    }

    if (direction.contains('aahista') ||
        direction.contains('slow')) {
      rate = rate.clamp(0.25, 0.38).toDouble();
    }

    if (direction.contains('tez') ||
        direction.contains('fast')) {
      rate = rate.clamp(0.50, 0.75).toDouble();
    }

    if (direction.contains('deep')) {
      pitch =
          (pitch - 0.08).clamp(0.50, 1.50).toDouble();
    }

    if (direction.contains('soft')) {
      rate = rate.clamp(0.25, 0.42).toDouble();
    }

    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setVolume(_volume);
  }

  String _preparePoetryForSpeech(String poetry) {
    var text = poetry.trim();

    if (text.isEmpty) {
      return '';
    }

    text = text.replaceAll(RegExp(r'\r\n'), '\n');
    text = text.replaceAll(RegExp(r'\n{2,}'), '\n');

    text = text.replaceAll('،', '، ');
    text = text.replaceAll('۔', '۔ ');
    text = text.replaceAll('؟', '؟ ');
    text = text.replaceAll('!', '! ');

    text = text.replaceAll(RegExp(r' +'), ' ');

    return text.trim();
  }

  Future<String?> _prepareSpeechText() async {
    final poetry = _poetryController.text.trim();

    if (poetry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your poetry first.',
          ),
        ),
      );

      return null;
    }

    return _preparePoetryForSpeech(poetry);
  }

  Future<void> _generateVoice() async {
    final poetry = await _prepareSpeechText();

    if (poetry == null || poetry.isEmpty) {
      return;
    }

    try {
      await _flutterTts.stop();
      await _forceUrduPakistanVoice();
      await _applyExpressionControls();
      await _flutterTts.speak(poetry);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Voice error: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _stopVoice() async {
    await _flutterTts.stop();

    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  Future<void> _saveAudio() async {
    final poetry = await _prepareSpeechText();

    if (poetry == null || poetry.isEmpty) {
      return;
    }

    if (_isSavingAudio) {
      return;
    }

    setState(() {
      _isSavingAudio = true;
    });

    try {
      await _flutterTts.stop();

      await _forceUrduPakistanVoice();
      await _applyExpressionControls();

      final directory =
          await getApplicationDocumentsDirectory();

      final timestamp =
          DateTime.now().millisecondsSinceEpoch;

      final filePath =
          '${directory.path}/poetry_voice_$timestamp.wav';

      final result = await _flutterTts.synthesizeToFile(
        poetry,
        filePath,
      );

      if (!mounted) {
        return;
      }

      if (result == 1 || result == true) {
        setState(() {
          _savedAudioPath = filePath;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Audio saved successfully.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Audio could not be saved. Please check the device TTS service.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Audio save error: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingAudio = false;
        });
      }
    }
  }

  Future<void> _playSavedAudio() async {
    final path = _savedAudioPath;

    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please save the audio first.',
          ),
        ),
      );

      return;
    }

    final file = File(path);

    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Saved audio file was not found.',
          ),
        ),
      );

      return;
    }

    try {
      await _flutterTts.stop();

      await _forceUrduPakistanVoice();
      await _applyExpressionControls();

      final poetry = _preparePoetryForSpeech(
        _poetryController.text.trim(),
      );

      await _flutterTts.speak(poetry);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Audio play error: $e',
            ),
          ),
        );
      }
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
              'Describe the mood and feeling of the voice.',
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
                    'Example: Sad, deep and emotional voice...',
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
              'Write Your Poetry',
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
                    'Write your poetry here...',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Voice Direction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Describe how the poetry should be spoken.',
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
                    'Example: Slow, emotional, deep voice, emphasize important words...',
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
                          'No TTS voices are available on this device.',
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
                        const Icon(
                          Icons.slow_motion_video,
                        ),
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
                    _isSpeaking || _isSavingAudio
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
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed:
                    _isSavingAudio
                        ? null
                        : _saveAudio,
                icon: _isSavingAudio
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.save_alt,
                      ),
                label: Text(
                  _isSavingAudio
                      ? 'Saving Audio...'
                      : 'Save Audio',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2563EB),
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
            if (_savedAudioPath != null) ...[
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color:
                                Colors.green,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Audio Saved Successfully',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _savedAudioPath!,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              _playSavedAudio,
                          icon: const Icon(
                            Icons.play_arrow,
                          ),
                          label: const Text(
                            'Play Saved Voice',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
