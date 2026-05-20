import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

/// Port of the voice note system from app.js:
/// startVoice(), stopVoice(), clearVoice(), fmtSec()
class VoiceService {
  static final AudioRecorder _recorder = AudioRecorder();
  static final AudioPlayer _player = AudioPlayer();

  static String? _recordingPath;
  static bool _isRecording = false;
  static bool _isPlaying = false;
  static int _recSec = 0;
  static Timer? _secTimer;

  static bool get isRecording => _isRecording;
  static bool get isPlaying => _isPlaying;
  static int get recSec => _recSec;
  static String? get recordingPath => _recordingPath;

  static Function()? onTick; // called every second during recording

  /// Port of startVoice() — request mic, start recording
  static Future<bool> startRecording() async {
    if (_isRecording) return false;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return false;

    final dir = await getTemporaryDirectory();
    _recordingPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,  // m4a — works on both iOS and Android
        sampleRate: 44100,
        bitRate: 64000,
        noiseCancel: true,
        echoCancel: true,
      ),
      path: _recordingPath!,
    );

    _isRecording = true;
    _recSec = 0;
    _secTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _recSec++;
      onTick?.call();
    });
    return true;
  }

  /// Port of stopVoice() — stop recording, get file path
  static Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    _secTimer?.cancel();
    _secTimer = null;
    _isRecording = false;

    final path = await _recorder.stop();
    _recordingPath = path;
    return path;
  }

  /// Port of clearVoice()
  static Future<void> clearRecording() async {
    _secTimer?.cancel();
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;
    }
    if (_recordingPath != null) {
      try { await File(_recordingPath!).delete(); } catch (_) {}
      _recordingPath = null;
    }
    _recSec = 0;
  }

  /// Play a voice note from a URL or local path
  static Future<void> playVoice(String urlOrPath) async {
    await _player.stop();
    if (urlOrPath.startsWith('http')) {
      await _player.play(UrlSource(urlOrPath));
    } else {
      await _player.play(DeviceFileSource(urlOrPath));
    }
    _isPlaying = true;
    _player.onPlayerComplete.listen((_) => _isPlaying = false);
  }

  static Future<void> stopPlayback() async {
    await _player.stop();
    _isPlaying = false;
  }

  /// Port of fmtSec(s)
  static String fmtSec(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return m > 0 ? '${m}m ${r}s' : '${r}s';
  }

  static Future<void> dispose() async {
    _secTimer?.cancel();
    await _recorder.dispose();
    await _player.dispose();
  }
}
