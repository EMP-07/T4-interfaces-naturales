import 'package:flutter_test/flutter_test.dart';
import 'package:notas_gestos/detector_agitado.dart';

void main() {
  final inicio = DateTime(2026, 1, 1, 12, 0, 0);

  test('En reposo no detecta sacudida', () {
    final detector = DetectorAgitado();
    expect(detector.procesar(0.1, 0.2, 0.1, inicio), isFalse);
  });

  test('Una sacudida fuerte se detecta', () {
    final detector = DetectorAgitado();
    expect(detector.procesar(20, 0, 0, inicio), isTrue);
  });

  test('Segunda sacudida dentro de la pausa se ignora', () {
    final detector = DetectorAgitado();
    expect(detector.procesar(20, 0, 0, inicio), isTrue);
    final medioSegundo = inicio.add(const Duration(milliseconds: 500));
    expect(detector.procesar(20, 0, 0, medioSegundo), isFalse);
  });

  test('Sacudida pasada la pausa se vuelve a detectar', () {
    final detector = DetectorAgitado();
    expect(detector.procesar(20, 0, 0, inicio), isTrue);
    final despues = inicio.add(const Duration(milliseconds: 1100));
    expect(detector.procesar(20, 0, 0, despues), isTrue);
  });

  test('Usa el módulo de los tres ejes', () {
    final detector = DetectorAgitado();
    // √(10² + 10²) ≈ 14,1 → no supera 15
    expect(detector.procesar(10, 10, 0, inicio), isFalse);
    // √(10² + 10² + 10²) ≈ 17,3 → supera 15
    expect(detector.procesar(10, 10, 10, inicio), isTrue);
  });

  test('Respeta un umbral personalizado', () {
    final detector = DetectorAgitado(umbral: 25);
    expect(detector.procesar(20, 0, 0, inicio), isFalse);
    expect(detector.procesar(26, 0, 0, inicio), isTrue);
  });
}