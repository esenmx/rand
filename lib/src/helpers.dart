part of rand;

double _lerp<T extends num>(T a, T b, double t) => a + (b - a) * t;
