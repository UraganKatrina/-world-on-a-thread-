import 'package:flutter/foundation.dart';

import '../models/connection.dart';
import '../models/level_definition.dart';

/// Why a thread could not be made. None of these are punished: the player
/// simply gets a gentle explanation and may try again immediately.
enum RejectReason {
  /// The two points are not meant to be joined in this puzzle.
  notAllowed,

  /// The thread already exists.
  duplicate,

  /// The pair is right, but another thread has to come first.
  wrongOrder,
}

/// Result of a single tap on a node.
sealed class TapOutcome {
  const TapOutcome();
}

class NodeSelected extends TapOutcome {
  const NodeSelected(this.nodeId);
  final String nodeId;
}

class SelectionCleared extends TapOutcome {
  const SelectionCleared();
}

class ThreadConnected extends TapOutcome {
  const ThreadConnected(this.connection, {required this.solvedNow});
  final Connection connection;
  final bool solvedNow;
}

class ThreadRejected extends TapOutcome {
  const ThreadRejected(this.connection, this.reason);
  final Connection connection;
  final RejectReason reason;
}

/// Taps are ignored (puzzle already solved or input locked).
class TapIgnored extends TapOutcome {
  const TapIgnored();
}

/// Pure puzzle state machine for one level. Contains no rendering code, so
/// every rule can be unit-tested.
class PuzzleSession extends ChangeNotifier {
  PuzzleSession(this.level);

  final LevelDefinition level;

  final List<Connection> _made = [];
  String? _selected;
  bool _solved = false;
  int _rejections = 0;

  List<Connection> get connections => List.unmodifiable(_made);
  String? get selectedNodeId => _selected;
  bool get isSolved => _solved;

  /// How many unsuccessful attempts were made since the last reset; used to
  /// make the hint a little more noticeable, never to penalize.
  int get rejectionCount => _rejections;

  int get requiredCount => level.winCondition.required.length;
  int get completedRequiredCount =>
      level.winCondition.required.where(_made.contains).length;
  double get progress =>
      requiredCount == 0 ? 0 : completedRequiredCount / requiredCount;

  bool isConnected(Connection c) => _made.contains(c);

  /// The required connection that should be made next, if the level is
  /// sequential. Used by the hint and by the mechanism's sockets.
  Connection? get nextRequired {
    for (final c in level.winCondition.required) {
      if (!_made.contains(c)) return c;
    }
    return null;
  }

  TapOutcome tapNode(String nodeId) {
    if (_solved || !level.hasNode(nodeId)) return const TapIgnored();

    final selected = _selected;
    if (selected == null) {
      _selected = nodeId;
      notifyListeners();
      return NodeSelected(nodeId);
    }
    if (selected == nodeId) {
      _selected = null;
      notifyListeners();
      return const SelectionCleared();
    }
    _selected = null;
    final outcome = tryConnect(selected, nodeId);
    notifyListeners();
    return outcome;
  }

  void clearSelection() {
    if (_selected == null) return;
    _selected = null;
    notifyListeners();
  }

  /// Attempts to stretch a thread between [a] and [b].
  TapOutcome tryConnect(String a, String b) {
    if (_solved || a == b || !level.hasNode(a) || !level.hasNode(b)) {
      return const TapIgnored();
    }
    final connection = Connection(a, b);
    RejectReason? reason;
    if (_made.contains(connection)) {
      reason = RejectReason.duplicate;
    } else if (!level.allowedConnections.contains(connection)) {
      reason = RejectReason.notAllowed;
    } else if (!level.winCondition.acceptsNext(connection, _made)) {
      reason = RejectReason.wrongOrder;
    }
    if (reason != null) {
      _rejections++;
      notifyListeners();
      return ThreadRejected(connection, reason);
    }

    _made.add(connection);
    _solved = level.winCondition.isSatisfied(_made);
    notifyListeners();
    return ThreadConnected(connection, solvedNow: _solved);
  }

  void reset() {
    _made.clear();
    _selected = null;
    _solved = false;
    _rejections = 0;
    notifyListeners();
  }
}
