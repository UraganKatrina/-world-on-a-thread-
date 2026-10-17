import '../models/connection.dart';

/// Short-lived visual effects. Kept outside the puzzle logic: the session
/// knows *what* happened, this class remembers *when*, for animation.
class BoardVisualState {
  final Map<Connection, Duration> threadStarted = {};
  final Map<String, Duration> nodeFlashed = {};
  final Map<String, Duration> nodeSelectedAt = {};
  Connection? rejected;
  Duration? rejectedAt;
  Duration? solvedAt;

  void clear() {
    threadStarted.clear();
    nodeFlashed.clear();
    nodeSelectedAt.clear();
    rejected = null;
    rejectedAt = null;
    solvedAt = null;
  }
}
