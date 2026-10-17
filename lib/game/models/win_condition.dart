import 'connection.dart';

/// Rule that decides when a puzzle is solved.
///
/// Conditions are pure data plus pure functions, so they can be checked in
/// tests without any rendering.
sealed class WinCondition {
  const WinCondition();

  /// Connections that must exist for the puzzle to be solved.
  List<Connection> get required;

  /// Whether [connection] may be added right now, given the threads that
  /// already exist (in the order they were made).
  bool acceptsNext(Connection connection, List<Connection> made);

  bool isSatisfied(List<Connection> made);
}

/// Every required connection must exist; order does not matter.
class AllConnectionsCondition extends WinCondition {
  const AllConnectionsCondition(this.required);

  @override
  final List<Connection> required;

  @override
  bool acceptsNext(Connection connection, List<Connection> made) => true;

  @override
  bool isSatisfied(List<Connection> made) {
    final madeSet = made.toSet();
    return required.every(madeSet.contains);
  }
}

/// Required connections must be made exactly in the listed order.
class SequenceCondition extends WinCondition {
  const SequenceCondition(this.required);

  @override
  final List<Connection> required;

  @override
  bool acceptsNext(Connection connection, List<Connection> made) {
    final index = required.indexOf(connection);
    if (index < 0) return true; // not part of the sequence, order-agnostic
    final progress = required.where(made.contains).length;
    return index == progress;
  }

  @override
  bool isSatisfied(List<Connection> made) {
    final inOrder = made.where(required.contains).toList();
    if (inOrder.length != required.length) return false;
    for (var i = 0; i < required.length; i++) {
      if (inOrder[i] != required[i]) return false;
    }
    return true;
  }
}
