import 'package:flutter_test/flutter_test.dart';
import 'package:lista_voz/comandos.dart';

void main() {
  test('No distingue mayúsculas ni tildes', () {
    expect(interpretarComando('Añade'), Comando.anadir);
    expect(interpretarComando('anade'), Comando.anadir);
    expect(interpretarComando('AÑADIR'), Comando.anadir);
  });

  test('Sinónimos de añadir', () {
    expect(interpretarComando('nuevo'), Comando.anadir);
    expect(interpretarComando('crear'), Comando.anadir);
  });

  test('Sinónimos de borrar', () {
    expect(interpretarComando('borrar'), Comando.borrar);
    expect(interpretarComando('borra'), Comando.borrar);
    expect(interpretarComando('ELIMINAR'), Comando.borrar);
    expect(interpretarComando('quitar'), Comando.borrar);
  });

  test('Sinónimos de leer', () {
    expect(interpretarComando('leer'), Comando.leer);
    expect(interpretarComando('lee'), Comando.leer);
    expect(interpretarComando('¿Cuántos hay?'), Comando.leer);
    expect(interpretarComando('lista'), Comando.leer);
  });

  test('Sinónimos de ayuda', () {
    expect(interpretarComando('ayuda'), Comando.ayuda);
    expect(interpretarComando('Comandos'), Comando.ayuda);
  });

  test('Reconoce la orden dentro de una frase', () {
    expect(interpretarComando('por favor añade uno'), Comando.anadir);
    expect(interpretarComando('quiero que borres... no, borra el último'),
        Comando.borrar);
  });

  test('Cualquier otra cosa es desconocido', () {
    expect(interpretarComando('hola'), Comando.desconocido);
    expect(interpretarComando('qué tiempo hace'), Comando.desconocido);
  });

  test('El texto vacío es desconocido', () {
    expect(interpretarComando(''), Comando.desconocido);
    expect(interpretarComando('   '), Comando.desconocido);
  });
}