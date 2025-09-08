import 'dart:math' as math;

/// 2D Simplex noise implementation.
///
/// Adapted from Stefan Gustavson's public domain algorithm.
class OpenSimplexNoise {
  OpenSimplexNoise([int seed = 0]) {
    final p = List<int>.generate(256, (i) => i);
    final random = math.Random(seed);
    for (int i = 255; i >= 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = p[i];
      p[i] = p[j];
      p[j] = temp;
    }
    for (int i = 0; i < 512; i++) {
      _perm[i] = p[i & 255];
    }
  }

  final List<int> _perm = List<int>.filled(512, 0);

  static const List<int> _grad3 = [
    1,
    1,
    0,
    -1,
    1,
    0,
    1,
    -1,
    0,
    -1,
    -1,
    0,
    1,
    0,
    1,
    -1,
    0,
    1,
    1,
    0,
    -1,
    -1,
    0,
    -1,
    0,
    1,
    1,
    0,
    -1,
    1,
    0,
    1,
    -1,
    0,
    -1,
    -1,
  ];

  double noise2D(double xin, double yin) {
    const double F2 = 0.366025403; // (sqrt(3)-1)/2
    const double G2 = 0.211324865; // (3-sqrt(3))/6

    double n0 = 0, n1 = 0, n2 = 0;

    final s = (xin + yin) * F2;
    final i = (xin + s).floor();
    final j = (yin + s).floor();
    final t = (i + j) * G2;
    final X0 = i - t;
    final Y0 = j - t;
    final x0 = xin - X0;
    final y0 = yin - Y0;

    int i1, j1;
    if (x0 > y0) {
      i1 = 1;
      j1 = 0;
    } else {
      i1 = 0;
      j1 = 1;
    }

    final x1 = x0 - i1 + G2;
    final y1 = y0 - j1 + G2;
    final x2 = x0 - 1 + 2 * G2;
    final y2 = y0 - 1 + 2 * G2;

    final ii = i & 255;
    final jj = j & 255;
    final gi0 = _perm[ii + _perm[jj]] % 12;
    final gi1 = _perm[ii + i1 + _perm[jj + j1]] % 12;
    final gi2 = _perm[ii + 1 + _perm[jj + 1]] % 12;

    double t0 = 0.5 - x0 * x0 - y0 * y0;
    if (t0 >= 0) {
      t0 *= t0;
      n0 = t0 * t0 * (_grad3[gi0 * 3] * x0 + _grad3[gi0 * 3 + 1] * y0);
    }

    double t1 = 0.5 - x1 * x1 - y1 * y1;
    if (t1 >= 0) {
      t1 *= t1;
      n1 = t1 * t1 * (_grad3[gi1 * 3] * x1 + _grad3[gi1 * 3 + 1] * y1);
    }

    double t2 = 0.5 - x2 * x2 - y2 * y2;
    if (t2 >= 0) {
      t2 *= t2;
      n2 = t2 * t2 * (_grad3[gi2 * 3] * x2 + _grad3[gi2 * 3 + 1] * y2);
    }

    return 70.0 * (n0 + n1 + n2);
  }
}
