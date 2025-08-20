// Fallback for non-web platforms. Provides a no-op implementation.
import 'dart:typed_data';

class WebAudioRecorder {
  Future<void> start() async {}
  Future<Uint8List?> stopAndGetBytes() async => null;
  void cancel() {}
}


