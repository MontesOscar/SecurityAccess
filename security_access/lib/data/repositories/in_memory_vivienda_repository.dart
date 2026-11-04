import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/repositories/vivienda_repository.dart';

class InMemoryViviendaRepository implements ViviendaRepository {
  InMemoryViviendaRepository([List<Vivienda> iniciales = const []])
    : _viviendas = List<Vivienda>.of(iniciales);

  final List<Vivienda> _viviendas;
  var _secuencia = 0;

  @override
  Future<List<Vivienda>> listar() async {
    return List<Vivienda>.of(_viviendas);
  }

  @override
  Future<Vivienda?> buscarPorId(String id) async {
    for (final vivienda in _viviendas) {
      if (vivienda.id == id) {
        return vivienda;
      }
    }
    return null;
  }

  @override
  Future<Vivienda?> buscarPorNumero(String numero) async {
    final normalizado = numero.trim().toLowerCase();
    for (final vivienda in _viviendas) {
      if (vivienda.numero.toLowerCase() == normalizado) {
        return vivienda;
      }
    }
    return null;
  }

  @override
  Future<String> reservarId() async {
    _secuencia += 1;
    return 'viv-$_secuencia';
  }

  @override
  Future<void> guardar(Vivienda vivienda) async {
    final indice = _viviendas.indexWhere((actual) => actual.id == vivienda.id);
    if (indice >= 0) {
      _viviendas[indice] = vivienda;
      return;
    }
    _viviendas.add(vivienda);
  }
}
