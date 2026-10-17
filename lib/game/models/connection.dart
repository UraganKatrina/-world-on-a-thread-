/// An undirected thread between two nodes.
///
/// `Connection('a', 'b') == Connection('b', 'a')`, which is what makes
/// duplicate detection independent of the order in which nodes were tapped.
class Connection {
  Connection(String a, String b)
    : assert(a != b, 'A thread needs two different nodes'),
      first = a.compareTo(b) <= 0 ? a : b,
      second = a.compareTo(b) <= 0 ? b : a;

  final String first;
  final String second;

  String get key => '$first|$second';

  bool involves(String nodeId) => first == nodeId || second == nodeId;

  @override
  bool operator ==(Object other) =>
      other is Connection && other.first == first && other.second == second;

  @override
  int get hashCode => Object.hash(first, second);

  @override
  String toString() => 'Connection($first — $second)';
}
