import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'detector_agitado.dart';
import 'tema.dart';

void main() => runApp(const NotasGestosApp());

class NotasGestosApp extends StatelessWidget {
  const NotasGestosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas',
      debugShowCheckedModeBanner: false,
      theme: temaMorado(),
      home: const PantallaNotas(),
    );
  }
}

/// Una nota con un id único (lo necesita Dismissible como clave).
class Nota {
  Nota(this.id, this.texto);
  final int id;
  final String texto;
}

class PantallaNotas extends StatefulWidget {
  const PantallaNotas({super.key});

  @override
  State<PantallaNotas> createState() => _PantallaNotasState();
}

class _PantallaNotasState extends State<PantallaNotas> {
  final List<Nota> _notas = [];
  final TextEditingController _campo = TextEditingController();
  final DetectorAgitado _detector = DetectorAgitado();
  StreamSubscription<UserAccelerometerEvent>? _suscripcion;

  int _siguienteId = 0;

  // Última nota borrada y su posición (para deshacer).
  Nota? _notaBorrada;
  int? _posicionBorrada;

  @override
  void initState() {
    super.initState();
    // Empezamos a escuchar el sensor cuando la pantalla ya está dibujada.
    WidgetsBinding.instance.addPostFrameCallback((_) => _escucharSensor());
  }

  // ------------------------------ Notas ------------------------------

  void _anadirNota() {
    final texto = _campo.text.trim();
    if (texto.isEmpty) return;
    setState(() {
      _notas.add(Nota(_siguienteId++, texto));
      _campo.clear();
    });
  }

  /// 3.2: borra, guarda la nota y su posición, y ofrece «Deshacer».
  void _borrarNota(int posicion) {
    final nota = _notas[posicion];
    setState(() {
      _notas.removeAt(posicion);
      _notaBorrada = nota;
      _posicionBorrada = posicion;
    });
    _mostrarAviso(SnackBar(
      content: const Text('Nota borrada'),
      action: SnackBarAction(label: 'Deshacer', onPressed: _deshacer),
    ));
  }

  /// Vuelve a poner la última nota borrada en su sitio.
  void _deshacer() {
    final nota = _notaBorrada;
    if (nota == null) return;
    setState(() {
      // Si la lista ha cambiado y la posición ya no existe, va al final.
      var posicion = _posicionBorrada ?? _notas.length;
      if (posicion > _notas.length) posicion = _notas.length;
      _notas.insert(posicion, nota);
      _notaBorrada = null;
      _posicionBorrada = null;
    });
  }

  /// 3.3 y 3.4: al agitar se recupera la nota; si no hay, no hace nada.
  void _alAgitar() {
    if (_notaBorrada == null) return;
    _deshacer();
    _mostrarAviso(const SnackBar(content: Text('Nota recuperada al agitar')));
  }

  void _mostrarAviso(SnackBar aviso) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(aviso);
  }

  // ------------------------------ Sensor ------------------------------

  /// 3.3: escucha el acelerómetro sin gravedad.
  void _escucharSensor() {
    _suscripcion = userAccelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((e) {
      if (_detector.procesar(e.x, e.y, e.z, DateTime.now())) _alAgitar();
    });
  }

  // ------------------------------ Interfaz ------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        backgroundColor: Paleta.c700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Campo para añadir notas
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _campo,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _anadirNota(),
                    decoration: InputDecoration(
                      hintText: 'Escribe una nota',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Paleta.c300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Paleta.c600, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Añadir nota',
                  onPressed: _anadirNota,
                  style: IconButton.styleFrom(
                    backgroundColor: Paleta.c600,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(child: _lista()),
        ],
      ),
    );
  }

  Widget _lista() {
    if (_notas.isEmpty) {
      return const Center(
        child: Text(
          'No hay notas',
          style: TextStyle(color: Paleta.c700, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _notas.length,
      itemBuilder: (context, i) {
        final nota = _notas[i];
        // 3.1: borrar deslizando (Dismissible) o con el botón.
        return Dismissible(
          key: ValueKey(nota.id),
          background: _fondoBorrar(Alignment.centerLeft),
          secondaryBackground: _fondoBorrar(Alignment.centerRight),
          onDismissed: (_) => _borrarNota(i),
          child: Card(
            color: Colors.white,
            child: ListTile(
              title: Text(nota.texto),
              trailing: IconButton(
                tooltip: 'Borrar nota',
                color: Paleta.c600,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _borrarNota(i),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _fondoBorrar(Alignment alineacion) {
    return Container(
      alignment: alineacion,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Paleta.c200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Paleta.c800),
    );
  }
}