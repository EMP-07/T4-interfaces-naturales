import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
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
  // --- Voz ---
  final SpeechToText _voz = SpeechToText(); // reconocimiento (oír)
  final FlutterTts _tts = FlutterTts(); // síntesis (hablar)

  // --- Datos ---
  final List<String> _elementos = [];

  // --- Estado de la interfaz ---
  bool _vozDisponible = false;
  bool _escuchando = false;
  String _motivoSinVoz = 'Comprobando el micrófono…'; 
  String _transcripcion = '';
  String _ultimaOrden = '—'; 

  @override
  void initState() {
    super.initState();
    _iniciarVoz();
  }

  /// Prepara la voz de respuesta y el reconocimiento.
  Future<void> _iniciarVoz() async {
    await _tts.setLanguage('es-ES');

    bool disponible;
    try {
      disponible = await _voz.initialize(
        onStatus: _alCambiarEstado,
        onError: _alFallar,
      );
    } catch (_) {
      disponible = false;
    }

    String motivo = '';
    if (!disponible) {
      bool conPermiso = false;
      try {
        conPermiso = await _voz.hasPermission;
      } catch (_) {}
      motivo = conPermiso
          ? 'Micrófono desactivado: este dispositivo no tiene servicio de '
              'reconocimiento de voz. Puedes usar los botones.'
          : 'Micrófono desactivado: la app no tiene permiso para usar el '
              'micrófono. Puedes usar los botones.';
    }

    if (!mounted) return;
    setState(() {
      _vozDisponible = disponible;
      _motivoSinVoz = motivo;
    });
  }

  void _alCambiarEstado(String estado) {
    if (estado == 'done' || estado == 'notListening') {
      if (mounted) setState(() => _escuchando = false);
    }
  }

  void _alFallar(SpeechRecognitionError error) {
    if (mounted) setState(() => _escuchando = false);
  }

  /// Al pulsar el micrófono escucha como máximo 5 segundos.
  Future<void> _pulsarMicrofono() async {
    if (_escuchando) {
      await _voz.stop();
      setState(() => _escuchando = false);
      return;
    }
    await _tts.stop();
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

  /// Muestra lo que se va oyendo y, al final, ejecuta la orden.
  void _alReconocer(SpeechRecognitionResult resultado) {
    setState(() => _transcripcion = resultado.recognizedWords);
    if (resultado.finalResult) {
      setState(() => _escuchando = false);
      _ejecutar(
        interpretarComando(resultado.recognizedWords),
        oido: resultado.recognizedWords,
      );
    }
  }

  void _ejecutar(Comando comando, {String oido = ''}) {
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
        _noEntendido(oido); 
    }
  }

  // --- Acciones (las usan la voz Y los botones) ---

  void _anadir() {
    final numero = _elementos.length + 1;
    setState(() {
      _elementos.add('Elemento $numero');
      _ultimaOrden = 'añadir';
    });
    _tts.speak('Añadido el elemento $numero');
  }

  void _borrar() {
    setState(() => _ultimaOrden = 'borrar');
    if (_elementos.isEmpty) {
      _tts.speak('La lista está vacía');
      return;
    }
    final numero = _elementos.length;
    setState(() => _elementos.removeLast());
    _tts.speak('Borrado el elemento $numero');
  }

  void _leer() {
    setState(() => _ultimaOrden = 'leer');
    final n = _elementos.length;
    _tts.speak(n == 1 ? 'Hay 1 elemento' : 'Hay $n elementos');
  }

  void _ayuda() {
    setState(() => _ultimaOrden = 'ayuda');
    _tts.speak('Puedes decir: añadir, borrar, leer o ayuda');
  }

  void _noEntendido(String oido) {
    setState(() => _ultimaOrden = 'no entendida');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('No he entendido «$oido». Di «ayuda» para oír las órdenes'),
      ));
  }

  @override
  void dispose() {
    _voz.stop();
    _tts.stop();
    super.dispose();
  }

  // ------------------------------- Interfaz -------------------------------

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
          Expanded(child: _lista()),
          _panelInferior(),
        ],
      ),
    );
  }

  Widget _lista() {
    if (_elementos.isEmpty) {
      return const Center(
        child: Text(
          'La lista está vacía',
          style: TextStyle(color: Paleta.c700, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _elementos.length,
      itemBuilder: (context, i) => Card(
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Paleta.c100,
            foregroundColor: Paleta.c800,
            child: Text('${i + 1}'),
          ),
          title: Text(_elementos[i]),
        ),
      ),
    );
  }

  Widget _panelInferior() {
    final IconData iconoMic;
    final Color colorMic;
    final String ayudaMic;
    if (!_vozDisponible) {
      iconoMic = Icons.mic_off;
      colorMic = Colors.grey;
      ayudaMic = _motivoSinVoz;
    } else if (_escuchando) {
      iconoMic = Icons.mic;
      colorMic = Paleta.c900;
      ayudaMic = 'Escuchando… pulsa para parar';
    } else {
      iconoMic = Icons.mic_none;
      colorMic = Paleta.c500;
      ayudaMic = 'Pulsa y di una orden';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Paleta.c200, blurRadius: 8)],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón de micrófono
            IconButton.filled(
              tooltip: ayudaMic,
              iconSize: 40,
              onPressed: _vozDisponible ? _pulsarMicrofono : null,
              style: IconButton.styleFrom(
                backgroundColor: colorMic,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.all(20),
              ),
              icon: Icon(iconoMic),
            ),
            const SizedBox(height: 8),
            // Texto de estado (o el motivo si no hay voz)
            Text(
              _vozDisponible
                  ? (_escuchando
                      ? 'Escuchando…'
                      : 'Pulsa el micrófono y di una orden')
                  : _motivoSinVoz,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _vozDisponible ? Paleta.c700 : Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            // Transcripción y última orden
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Paleta.c50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Has dicho: ${_transcripcion.isEmpty ? '—' : _transcripcion}',
                    style: const TextStyle(color: Paleta.c900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Última orden: $_ultimaOrden',
                    style: const TextStyle(
                      color: Paleta.c600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _boton('Añadir', Icons.add, 'Añadir un elemento', _anadir),
                const SizedBox(width: 8),
                _boton('Borrar', Icons.delete_outline, 'Borrar el último elemento', _borrar),
                const SizedBox(width: 8),
                _boton('Leer', Icons.volume_up, 'Decir cuántos elementos hay', _leer),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _boton(String texto, IconData icono, String tooltip, VoidCallback accion) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: FilledButton.icon(
          onPressed: accion,
          icon: Icon(icono),
          label: Text(texto),
        ),
      ),
    );
  }
}