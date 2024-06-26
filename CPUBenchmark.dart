import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

class CPUBenchmark {
  final int _defaultIterations = 1000000;
  final int _numThreads = Platform.numberOfProcessors;

  Future<double> runSingleThreaded() async {
    double score = 1.0;
    score *= await _runMathOperations();
    score *= await _runStringManipulation();
    score *= await _runListOperations();
    score *= await _runBitManipulation();
    return score;
  }

  Future<double> runMultiThreaded() async {
    List<Future<double>> tasks = [];
    for (int i = 0; i < _numThreads; i++) {
      tasks.add(_runIsolate());
    }
    List<double> results = await Future.wait(tasks);
    return results.reduce((a, b) => a * b);
  }

  Future<Map<String, String>> runBenchmark({int numTrials = 3}) async {
    List<double> singleThreadScores = [];
    List<double> multiThreadScores = [];

    for (int i = 0; i < numTrials; i++) {
      singleThreadScores.add(await runSingleThreaded());
      multiThreadScores.add(await runMultiThreaded());
    }

    double singleThreadMedian = _calculateMedian(singleThreadScores);
    double multiThreadMedian = _calculateMedian(multiThreadScores);
    double totalScore = singleThreadMedian * multiThreadMedian;

    return {
      'Single-threaded': _formatScore(singleThreadMedian),
      'Multi-threaded': _formatScore(multiThreadMedian),
      'Total': _formatScore(totalScore),
    };
  }

  double _calculateMedian(List<double> scores) {
    scores.sort();
    int middle = scores.length ~/ 2;
    if (scores.length % 2 == 0) {
      return (scores[middle - 1] + scores[middle]) / 2;
    } else {
      return scores[middle];
    }
  }

  Future<double> _runMathOperations() async {
    int iterations = _defaultIterations;
    Stopwatch stopwatch = Stopwatch()..start();

    for (int i = 0; i < iterations; i++) {
      double result = sqrt(i) + log(i + 1) + sin(i) + cos(i) + tan(i);
      if (result == double.infinity) break;
    }

    stopwatch.stop();
    return iterations / stopwatch.elapsedMicroseconds;
  }

  Future<double> _runStringManipulation() async {
    int iterations = _defaultIterations ~/ 10;
    Stopwatch stopwatch = Stopwatch()..start();

    String testString = 'Hello, World! ' * 100;
    for (int i = 0; i < iterations; i++) {
      String result = testString.replaceAll('o', 'x')
          .toUpperCase()
          .split(' ')
          .reversed
          .join('-');
      if (result.isEmpty) break;
    }

    stopwatch.stop();
    return iterations / stopwatch.elapsedMicroseconds;
  }

  Future<double> _runListOperations() async {
    int iterations = _defaultIterations ~/ 100;
    Stopwatch stopwatch = Stopwatch()..start();

    List<int> testList = List.generate(1000, (index) => index);
    for (int i = 0; i < iterations; i++) {
      List<int> result = testList.where((element) => element % 2 == 0)
          .map((e) => e * 2)
          .toList()
        ..sort();
      if (result.isEmpty) break;
    }

    stopwatch.stop();
    return iterations / stopwatch.elapsedMicroseconds;
  }

  Future<double> _runBitManipulation() async {
    int iterations = _defaultIterations;
    Stopwatch stopwatch = Stopwatch()..start();

    int value = 1;
    for (int i = 0; i < iterations; i++) {
      value = (value << 1) | (value >> 1);
      value ^= i;
      value &= 0xFFFFFFFF;
    }

    stopwatch.stop();
    return iterations / stopwatch.elapsedMicroseconds;
  }

  Future<double> _runIsolate() async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_isolateEntryPoint, receivePort.sendPort);

    double result = await receivePort.first as double;
    return result;
  }

  static void _isolateEntryPoint(SendPort sendPort) async {
    CPUBenchmark benchmark = CPUBenchmark();
    double score = 1.0;
    score *= await benchmark._runMathOperations();
    score *= await benchmark._runStringManipulation();
    score *= await benchmark._runListOperations();
    score *= await benchmark._runBitManipulation();
    sendPort.send(score);
  }

  String _formatScore(double score) {
    if (score < 1024) {
      return '${score.toStringAsFixed(2)}B';
    } else if (score < 1024 * 1024) {
      return '${(score / 1024).toStringAsFixed(2)}KB';
    } else if (score < 1024 * 1024 * 1024) {
      return '${(score / (1024 * 1024)).toStringAsFixed(2)}MB';
    } else if (score < 1024 * 1024 * 1024 * 1024) {
      return '${(score / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
    } else {
      return '${(score / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(2)}TB';
    }
  }
}
