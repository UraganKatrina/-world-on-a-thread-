import 'dart:ui' show Offset;

/// True when segments a–b and c–d cross. Touching at a shared end point does
/// not count: threads that meet at a node never "cross".
bool segmentsCross(Offset a, Offset b, Offset c, Offset d) {
  if (a == c || a == d || b == c || b == d) return false;
  double orient(Offset p, Offset q, Offset r) =>
      (q.dx - p.dx) * (r.dy - p.dy) - (q.dy - p.dy) * (r.dx - p.dx);
  final o1 = orient(a, b, c);
  final o2 = orient(a, b, d);
  final o3 = orient(c, d, a);
  final o4 = orient(c, d, b);
  return (o1 > 0) != (o2 > 0) &&
      (o3 > 0) != (o4 > 0) &&
      o1 != 0 &&
      o2 != 0 &&
      o3 != 0 &&
      o4 != 0;
}
