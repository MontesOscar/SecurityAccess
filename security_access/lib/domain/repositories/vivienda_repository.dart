import 'package:security_access/domain/entities/vivienda.dart';

abstract class ViviendaRepository {
  Future<List<Vivienda>> listar();

  Future<Vivienda?> buscarPorId(String id);

  Future<Vivienda?> buscarPorNumero(String numero);

  Future<String> reservarId();

  Future<void> guardar(Vivienda vivienda);
}
