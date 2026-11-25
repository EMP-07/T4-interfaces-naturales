/// Órdenes que entiende la app.
enum Comando { anadir, borrar, leer, ayuda, desconocido }

/// Palabras que activan cada orden (ya sin tildes ni mayúsculas).
const Map<Comando, List<String>> _sinonimos = {
  Comando.anadir: ['anadir', 'anade', 'nuevo', 'crear'],
  Comando.borrar: ['borrar', 'borra', 'eliminar', 'quitar'],
  Comando.leer: ['leer', 'lee', 'cuantos', 'lista'],
  Comando.ayuda: ['ayuda', 'comandos'],
};

/// Pasa el texto a minúsculas y quita tildes (y la ñ → n).
String normalizar(String texto) {
  const conTilde = 'áéíóúüñàèìòù';
  const sinTilde = 'aeiouunaeiou';
  var resultado = texto.toLowerCase();
  for (var i = 0; i < conTilde.length; i++) {
    resultado = resultado.replaceAll(conTilde[i], sinTilde[i]);
  }
  return resultado;
}

/// Busca una orden dentro de la frase. Si no hay ninguna → desconocido.
Comando interpretarComando(String texto) {
  final palabras = normalizar(texto)
      .split(RegExp(r'[^a-z0-9]+'))
      .where((palabra) => palabra.isNotEmpty);

  for (final palabra in palabras) {
    for (final entrada in _sinonimos.entries) {
      if (entrada.value.contains(palabra)) return entrada.key;
    }
  }
  return Comando.desconocido;
}