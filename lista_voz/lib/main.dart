import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'comandos.dart';
import 'tema.dart';

void main() => runApp(const ListaVozApp());

class ListaVozApp extends StatelessWidget {
  const ListaVozApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista por voz',
      debugShowCheckedModeBanner: false,
      theme: temaMorado(),
      home: const PantallaLista(),
    );
  }
}

class PantallaLista extends StatefulWidget {
  const PantallaLista({super.key});

  @override
  State<PantallaLista> createState() => _PantallaListaState();
}

class _PantallaListaState extends State<PantallaLista> {
  // --- 3.1: las dos herramientas de voz ---
  final SpeechToText _voz = SpeechToText(); // para OÍR
  final FlutterTts _tts = FlutterTts(); // para HABLAR

  final List<String> _elementos = [];

  bool _vozDisponible = false;
  bool _escuchando = false;
  String _transcripcion = '';

  @override
  void initState() {
    super.initState();
    _iniciarVoz();
  }

  /// 3.1: prepara la voz de respuesta y el reconocimiento.
  Future<void> _iniciarVoz() async {
    await _tts.setLanguage('es-ES');

    final disponible = await _voz.initialize(
      onStatus: (estado) {
        if (estado == 'done' || estado == 'notListening') {
          if (mounted) setState(() => _escuchando = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _escuchando = false);
      },
    );

    if (!mounted) return;
    setState(() => _vozDisponible = disponible);
  }

  /// 3.2: al pulsar el micrófono, escucha como máximo 5 segundos.
  Future<void> _pulsarMicrofono() async {
    if (_escuchando) {
      await _voz.stop();
      setState(() => _escuchando = false);
      return;
    }
    await _tts.stop(); // que la app no se oiga a sí misma
    setState(() {
      _escuchando = true;
      _transcripcion = '';
    });
    await _voz.listen(
      onResult: _alReconocer,
      localeId: 'es_ES',
      listenFor: const Duration(seconds: 5),
    );
  }

  /// 3.3: muestra lo que se va oyendo y, al terminar, ejecuta la orden.
  void _alReconocer(SpeechRecognitionResult resultado) {
    setState(() => _transcripcion = resultado.recognizedWords);
    if (resultado.finalResult) {
      setState(() => _escuchando = false);
      _ejecutar(interpretarComando(resultado.recognizedWords));
    }
  }

  void _ejecutar(Comando comando) {
    switch (comando) {
      case Comando.anadir:
        _anadir();
      case Comando.borrar:
        _borrar();
      case Comando.leer:
        _leer();
      case Comando.ayuda:
        _ayuda();
      case Comando.desconocido:
        break; // lo resolvemos en el paso 4
    }
  }

  // --- 3.4: acciones con respuesta hablada ---

  void _anadir() {
    final numero = _elementos.length + 1;
    setState(() => _elementos.add('Elemento $numero'));
    _tts.speak('Añadido el elemento $numero');
  }

  void _borrar() {
    if (_elementos.isEmpty) {
      _tts.speak('La lista está vacía');
      return;
    }
    final numero = _elementos.length;
    setState(() => _elementos.removeLast());
    _tts.speak('Borrado el elemento $numero');
  }

  void _leer() {
    final n = _elementos.length;
    _tts.speak(n == 1 ? 'Hay 1 elemento' : 'Hay $n elementos');
  }

  void _ayuda() {
    _tts.speak('Puedes decir: añadir, borrar, leer o ayuda');
  }

  // --- Pantalla (sencilla; la mejoramos en el paso 4) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista por voz'),
        backgroundColor: Paleta.c700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _elementos.length,
              itemBuilder: (context, i) => Card(
                color: Colors.white,
                child: ListTile(title: Text(_elementos[i])),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Has dicho: ${_transcripcion.isEmpty ? '—' : _transcripcion}',
              style: const TextStyle(color: Paleta.c900, fontSize: 16),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _vozDisponible ? _pulsarMicrofono : null,
        backgroundColor: Paleta.c600,
        foregroundColor: Colors.white,
        child: const Icon(Icons.mic),
      ),
    );
  }
}