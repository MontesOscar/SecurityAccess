import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:security_access/domain/services/envio_codigo_recuperacion.dart';

class EnvioCodigoEmailJs implements EnvioCodigoRecuperacion {
  const EnvioCodigoEmailJs();

  static const _servicio = 'service_rl8fkxd';
  static const _plantilla = 'template_fv0dqo5';
  static const _clavePublica = 'lG7PUn57LxZI9Q9c_';

  @override
  Future<void> enviar({required String correo, required String codigo}) async {
    try {
      await emailjs.send(_servicio, _plantilla, {
        'to_email': correo,
        'codigo': codigo,
      }, const emailjs.Options(publicKey: _clavePublica));
    } catch (_) {
      // La pantalla muestra el mismo aviso aunque el envío falle.
    }
  }
}
