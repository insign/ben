import 'dart:async';
import 'dart:isolate';

class CPUBenchmark {
  static const int loopCount = 100000000;
  static const int threadCount = 4;

  Future<int> singleThreadTest() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    for (int i = 0; i < loopCount; i++) {}
    stopwatch.stop();
    return loopCount * 1000 ~/ stopwatch.elapsedMilliseconds;
  }

  Future<int> multiThreadTest() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    final List<Isolate> isolates = [];
    final List<ReceivePort> ports = [];
    for (int i = 0; i < threadCount; i++) {
      final ReceivePort receivePort = ReceivePort();
      ports.add(receivePort);
      isolates.add(await Isolate.spawn(_isolateLoop, receivePort.sendPort));
    }
    await Future.wait(ports.map((port) => port.first));
    stopwatch.stop();
    for (final isolate in isolates) {
      isolate.kill();
    }
    return loopCount * threadCount * 1000 ~/ stopwatch.elapsedMilliseconds;
  }

  static void _isolateLoop(SendPort sendPort) {
    for (int i = 0; i < loopCount; i++) {}
    sendPort.send(null);
  }

  String formatScore(int score) {
    if (score < 1000) {
      return '${score}B';
    } else if (score < 1000000) {
      return '${(score / 1000).toStringAsFixed(2)}KB';
    } else if (score < 1000000000) {
      return '${(score / 1000000).toStringAsFixed(2)}MB';
    } else {
      return '${(score / 1000000000).toStringAsFixed(2)}GB';
    }
  }

  Future<void> run() async {
    final int singleThreadScore = await singleThreadTest();
    print('Single-thread score: ${formatScore(singleThreadScore)}');
    final int multiThreadScore = await multiThreadTest();
    print('Multi-thread score: ${formatScore(multiThreadScore)}');
    final int totalScore = singleThreadScore + multiThreadScore;
    print('Total score: ${formatScore(totalScore)}');
  }
}

void main() {
  final benchmark = CPUBenchmark();
  benchmark.run();
}
