import '../models/connection.dart';

/// Nodes reached by light: the sources plus everything connected to them
/// through threads.
Set<String> litNodes(Set<String> sources, Iterable<Connection> threads) {
  final lit = {...sources};
  var grew = true;
  while (grew) {
    grew = false;
    for (final t in threads) {
      final a = lit.contains(t.first);
      final b = lit.contains(t.second);
      if (a != b) {
        lit.add(a ? t.second : t.first);
        grew = true;
      }
    }
  }
  return lit;
}
