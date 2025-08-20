// This file is only compiled on web via conditional import.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';

class WebAudioRecorder {
  html.MediaRecorder? _mediaRecorder;
  final List<html.Blob> _chunks = <html.Blob>[];

  Future<void> start() async {
    final stream = await html.window.navigator.mediaDevices!
        .getUserMedia(<String, bool>{'audio': true});

    _chunks.clear();

    _mediaRecorder = html.MediaRecorder(stream, <String, String>{'mimeType': 'audio/webm'});

    _mediaRecorder!.addEventListener('dataavailable', (event) {
      final ev = event as html.BlobEvent;
      final dataBlob = ev.data;
      if (dataBlob != null && (dataBlob.size ?? 0) > 0) {
        _chunks.add(dataBlob);
      }
    });

    _mediaRecorder!.start();
  }

  Future<Uint8List?> stopAndGetBytes() async {
    final recorder = _mediaRecorder;
    if (recorder == null) return null;

    final stopCompleter = Completer<void>();
    void onStop(html.Event _) {
      stopCompleter.complete();
    }

    recorder.addEventListener('stop', onStop);
    recorder.stop();
    await stopCompleter.future;
    recorder.removeEventListener('stop', onStop);

    if (_chunks.isEmpty) return null;

    final blob = html.Blob(_chunks, 'audio/webm');
    final reader = html.FileReader();
    final readCompleter = Completer<void>();
    reader.onLoadEnd.listen((_) => readCompleter.complete());
    reader.readAsArrayBuffer(blob);
    await readCompleter.future;
    final data = reader.result as ByteBuffer;
    return data.asUint8List();
  }

  void cancel() {
    try {
      _mediaRecorder?.stop();
    } catch (_) {}
  }
}


