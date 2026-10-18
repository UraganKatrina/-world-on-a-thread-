import 'puzzle_session.dart';

/// Soft, non-judgmental phrases shown after an attempt.
String rejectionMessage(RejectReason reason) => switch (reason) {
  RejectReason.notAllowed =>
    'Эти точки не тянутся друг к другу. Попробуй другую пару.',
  RejectReason.duplicate => 'Эта нить уже натянута.',
  RejectReason.wrongOrder =>
    'Пара верная, но нить пока не держится. Возможно, сначала нужна другая.',
  RejectReason.nodeBusy =>
    'У этой точки уже есть нить. Чтобы отпустить её, коснись обоих её концов.',
  RejectReason.crossing => 'Нити не могут пересекаться. Поищи другой путь.',
  RejectReason.dark => 'Нить тянется только от светящейся точки.',
  RejectReason.spoolEmpty =>
    'Моток пуст. Отпусти одну из нитей, чтобы натянуть её в другом месте.',
};

const String connectedMessage = 'Нить натянулась.';
const String untiedMessage = 'Нить отпущена.';
const String solvedMessage = 'Механизм просыпается…';
