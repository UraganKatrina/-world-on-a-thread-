import 'package:flutter/foundation.dart';

import '../models/connection.dart';
import '../models/level_definition.dart';
import 'light.dart';
import 'thread_geometry.dart';

/// Why a thread could not be made. None of these are punished: the player
/// simply gets a gentle explanation and may try again immediately.
enum RejectReason {
  /// The two points are not meant to be joined in this puzzle.
  notAllowed,

  /// The thread already exists.
  duplicate,

  /// The pair is right, but another thread has to come first.
  wrongOrder,

  /// One of the nodes already holds as many threads as the level allows.
  nodeBusy,

  /// The new thread would cross an existing one.
  crossing,

  /// Neither end glows yet, and threads only grow from light.
  dark,
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

/// An existing thread was released (levels with [PuzzleRules.allowUntie]).
class ThreadUntied extends TapOutcome {
  const ThreadUntied(this.connection);
  final Connection connection;
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

  int get goalCount => level.winCondition.goal(level);
  int get progressCount => level.winCondition.progress(_made, level);
  double get progress => goalCount == 0 ? 0 : progressCount / goalCount;

  bool isConnected(Connection c) => _made.contains(c);

  /// Nodes that glow. In levels without light sources every node that
  /// holds a thread counts as glowing.
  Set<String> get litNodeIds => level.rules.usesLight
      ? litNodes(level.rules.lightSources, _made)
      : {
          for (final c in _made) ...[c.first, c.second],
        };

  int threadsAt(String nodeId) => _made.where((c) => c.involves(nodeId)).length;

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
    final rules = level.rules;
    if (_made.contains(connection) && rules.allowUntie) {
      _made.remove(connection);
      notifyListeners();
      return ThreadUntied(connection);
    }
    final reason = _rejectionFor(connection);
    if (reason != null) {
      _rejections++;
      notifyListeners();
      return ThreadRejected(connection, reason);
    }

    _made.add(connection);
    _solved = level.winCondition.isSatisfied(_made, level);
    notifyListeners();
    return ThreadConnected(connection, solvedNow: _solved);
  }

  /// The first rule [connection] breaks, or null when it may be made.
  RejectReason? _rejectionFor(Connection connection) {
    final rules = level.rules;
    if (_made.contains(connection)) return RejectReason.duplicate;
    if (!level.allowedConnections.contains(connection)) {
      return RejectReason.notAllowed;
    }
    final max = rules.maxThreadsPerNode;
    if (max != null &&
        (threadsAt(connection.first) >= max ||
            threadsAt(connection.second) >= max)) {
      return RejectReason.nodeBusy;
    }
    if (rules.forbidCrossing && _crossesExisting(connection)) {
      return RejectReason.crossing;
    }
    if (rules.usesLight) {
      final lit = litNodeIds;
      if (!lit.contains(connection.first) && !lit.contains(connection.second)) {
        return RejectReason.dark;
      }
    }
    if (!level.winCondition.acceptsNext(connection, _made)) {
      return RejectReason.wrongOrder;
    }
    return null;
  }

  bool _crossesExisting(Connection c) {
    final a = level.nodeById(c.first).position;
    final b = level.nodeById(c.second).position;
    return _made.any(
      (t) => segmentsCross(
        a,
        b,
        level.nodeById(t.first).position,
        level.nodeById(t.second).position,
      ),
    );
  }

  void reset() {
    _made.clear();
    _selected = null;
    _solved = false;
    _rejections = 0;
    notifyListeners();
  }
}
