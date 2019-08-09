import 'package:connect_5/util.dart';

class StatGroup {
  String title;
  List<Stat> stats;
  StatGroup(this.title, this.stats);
}

abstract class Stat {
  final String title;
  String get value;

  Stat(this.title);
}

class StoredStat extends Stat {
  final String key;
  int storedValue = 0;

  String get value => '$storedValue';

  StoredStat(String title, this.key) : super(title);
}

class ComputedStat extends Stat {
  final ReturnFunction<String> compute;

  String get value => compute();

  ComputedStat(String title, this.compute) : super(title);
}
