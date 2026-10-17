import 'dart:math' as math;
import 'dart:typed_data';

/// Generates small original sounds as 16-bit mono WAV files, so the game
/// ships without any third-party audio assets.
class ToneSynth {
  const ToneSynth({this.sampleRate = 22050});

  final int sampleRate;

  /// A soft bell-like note: sine plus a quiet octave, exponential decay.
  Float64List bell(double frequency, double seconds, {double volume = 0.5}) {
    final n = (seconds * sampleRate).round();
    final out = Float64List(n);
    for (var i = 0; i < n; i++) {
      final t = i / sampleRate;
      final attack = math.min(1.0, t / 0.008);
      final decay = math.exp(-t * 5.5 / seconds);
      final s =
          math.sin(2 * math.pi * frequency * t) +
          0.3 * math.sin(2 * math.pi * frequency * 2 * t);
      out[i] = s * attack * decay * volume / 1.3;
    }
    return out;
  }

  /// Notes played one after another with overlap.
  Float64List arpeggio(
    List<double> freqs,
    double step,
    double tail, {
    double volume = 0.45,
  }) {
    final total = step * (freqs.length - 1) + tail;
    final out = Float64List((total * sampleRate).round());
    for (var k = 0; k < freqs.length; k++) {
      final note = bell(freqs[k], tail, volume: volume);
      final offset = (k * step * sampleRate).round();
      for (var i = 0; i < note.length && offset + i < out.length; i++) {
        out[offset + i] += note[i];
      }
    }
    return out;
  }

  /// A slow, seamless ambient pad: a chord whose voices breathe in and out.
  /// The loop length is a whole number of every voice's breathing period.
  Float64List pad({double seconds = 12, double volume = 0.18}) {
    const voices = [130.81, 196.0, 246.94, 329.63]; // C3 G3 B3 E4
    final n = (seconds * sampleRate).round();
    final out = Float64List(n);
    for (var i = 0; i < n; i++) {
      final t = i / sampleRate;
      var s = 0.0;
      for (var v = 0; v < voices.length; v++) {
        // Round frequencies so each voice completes whole cycles in the loop.
        final f = (voices[v] * seconds).roundToDouble() / seconds;
        final breathe =
            0.55 + 0.45 * math.sin(2 * math.pi * (v + 1) * t / seconds + v);
        s += math.sin(2 * math.pi * f * t) * breathe;
      }
      out[i] = s / voices.length * volume;
    }
    return out;
  }

  Uint8List toWav(Float64List samples) {
    final dataLength = samples.length * 2;
    final bytes = ByteData(44 + dataLength);
    void ascii(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        bytes.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    bytes.setUint32(4, 36 + dataLength, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little); // PCM
    bytes.setUint16(22, 1, Endian.little); // mono
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    bytes.setUint32(40, dataLength, Endian.little);
    for (var i = 0; i < samples.length; i++) {
      final v = (samples[i].clamp(-1.0, 1.0) * 32767).round();
      bytes.setInt16(44 + i * 2, v, Endian.little);
    }
    return bytes.buffer.asUint8List();
  }
}
