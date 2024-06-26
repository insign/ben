import 'CPUBenchmark.dart';

void main() async {
  CPUBenchmark benchmark = CPUBenchmark();
  Map<String, String> results = await benchmark.runBenchmark(numTrials: 10);

  print('Single-threaded score (median of 3 runs): ${results['Single-threaded']}');
  print('Multi-threaded score (median of 3 runs): ${results['Multi-threaded']}');
  print('Total score: ${results['Total']}');
}
