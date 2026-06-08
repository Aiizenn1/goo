class Constants {
  // IP especial para que el emulador de Android vea el Laravel de tu PC
  static const String localBaseUrl = "http://127.0.0.1:8000/api"; // (O la que tenías arriba)

  // IP de producción de tu DigitalOcean
  static const String productionBaseUrl = "http://143.198.124.161/api";

  // ¡CAMBIAMOS ESTA LÍNEA PARA APUNTAR A DIGITALOCEAN! 🚀
  static const String baseUrl = productionBaseUrl;
}