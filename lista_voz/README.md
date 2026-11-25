### 1. ¿El reconocimiento funciona en el dispositivo o envía el audio a un servidor?

He probado la app en el **emulador de Android** (Medium Phone · Android 17) usando el micrófono del PC, porque no tenía cable para conectar el móvil. Primero la probé con internet y reconocía bien las órdenes. Después activé el **modo avión** y volví a probar.

**Resultado:** sin conexión la app no reconoció nada, así que el audio **se envía a un servidor** para reconocerlo.

- **Privacidad:** mi voz sale del dispositivo y la procesa una empresa externa (Google), así que no tengo control total sobre esos datos.
- **Coste:** gasta datos en cada orden, y el servicio depende de un tercero.
- **Latencia:** tarda un poco más porque tiene que enviar el audio y esperar la respuesta, y si la conexión es mala va lento o falla.
- **Plataforma:** depende del dispositivo. El paquete speech_to_text usa el servicio de voz que trae Android, y en este emulador ese servicio necesita internet. Un móvil real con el idioma español descargado sin conexión podría funcionar en modo avión.