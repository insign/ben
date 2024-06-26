import 'dart:async';
import 'dart:isolate';
import 'dart:math';

class CpuBenchmark {
  final int iterations = 1000000; // Default iterations for consistent results
  late int singleThreadScore;
  late int multiThreadScore;

  Future<void> runBenchmark() async {
    singleThreadScore = await _runSingleThreadTest();
    multiThreadScore = await _runMultiThreadTest();
    var totalScore = singleThreadScore + multiThreadScore;

    print('Single-thread score: ${_formatBytes(singleThreadScore)}');
    print('Multi-thread score: ${_formatBytes(multiThreadScore)}');
    print('Total score: ${_formatBytes(totalScore)}');
  }

  Future<int> _runSingleThreadTest() async {
    var stopwatch = Stopwatch()..start();
    await _compute();
    stopwatch.stop();
    return iterations * 1000 ~/ stopwatch.elapsedMilliseconds;
  }

  Future<void> _compute() async {
    for (int i = 0; i < iterations; i++) {
      var calc = sqrt(i) * pow(i, 2);
    }
  }

  Future<int> _runMultiThreadTest() async {
    var stopwatch = Stopwatch()..start();
    var isolates = List.generate(4, (_) => _spawnIsolate());
    await Future.wait(isolates);
    stopwatch.stop();
    return (iterations * 4 * 1000) ~/ stopwatch.elapsedMilliseconds;
  }

  Future<void> _isolateEntry(SendPort sendPort) async {
    for (int i = 0; i < iterations; i++) {
      var calc = sqrt(i) * pow(i, 2);
    }
    sendPort.send(null);
  }

  Future<void> _spawnIsolate() async {
    var receivePort = ReceivePort();
    await Isolate.spawn(_isolateEntry, receivePort.sendPort);
    await receivePort.first;
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }
}

void main() async {
  var benchmark = CpuBenchmark();
  await benchmark.runBenchmark();
}
