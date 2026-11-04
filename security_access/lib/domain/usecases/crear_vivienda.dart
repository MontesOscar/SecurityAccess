import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/repositories/vivienda_repository.dart';
import 'package:security_access/domain/usecases/resultado_crear_vivienda.dart';

class CrearVivienda {
  const CrearVivienda(this._repositorio);

  final ViviendaRepository _repositorio;

  Future<ResultadoCrearVivienda> call({
    required String numero,
    required String direccion,
  }) async {
    final numeroLimpio = numero.trim();
    final direccionLimpia = direccion.trim();
    if (numeroLimpio.isEmpty || direccionLimpia.isEmpty) {
      return const DatosViviendaInvalidos();
    }

    final existente = await _repositorio.buscarPorNumero(numeroLimpio);
    if (existente != null) {
      return const ViviendaYaRegistrada();
    }

    final vivienda = Vivienda(
      id: await _repositorio.reservarId(),
      numero: numeroLimpio,
      direccion: direccionLimpia,
      estado: EstadoVivienda.disponible,
    );
    await _repositorio.guardar(vivienda);
    return ViviendaCreada(vivienda);
  }
}
