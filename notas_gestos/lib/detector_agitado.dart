import 'dart:math';

/// Detecta cuándo se agita el móvil a partir de lecturas del acelerómetro.
class DetectorAgitado {
  DetectorAgitado({
    this.umbral = 15,
    this.pausa = const Duration(seconds: 1),
  });

  /// Fuerza mínima (m/s²) para contar como sacudida.
  final double umbral;

  /// Tiempo que se ignoran lecturas tras una sacudida.
  final Duration pausa;

  DateTime? _ultimaSacudida;

  /// Devuelve true si esta lectura es una sacudida.
  /// Recibe [instante] para poder probar la pausa sin esperar.
  bool procesar(double x, double y, double z, DateTime instante) {
    // Dentro de la pausa: no contamos nada.
    final ultima = _ultimaSacudida;
    if (ultima != null && instante.difference(ultima) < pausa) {
      return false;
    }

    final modulo = sqrt(x * x + y * y + z * z);
    if (modulo > umbral) {
      _ultimaSacudida = instante;
      return true;
    }
    return false;
  }
}