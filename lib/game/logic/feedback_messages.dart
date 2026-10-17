import 'puzzle_session.dart';

/// Soft, non-judgmental phrases shown after an attempt.
String rejectionMessage(RejectReason reason) => switch (reason) {
  RejectReason.notAllowed =>
    'Эти точки не тянутся друг к другу. Попробуй другую пару.',
  RejectReason.duplicate => 'Эта нить уже натянута.',
  RejectReason.wrongOrder =>
    'Пара верная, но нить пока не держится. Возможно, сначала нужна другая.',
};

const String connectedMessage = 'Нить натянулась.';
const String solvedMessage = 'Механизм просыпается…';
