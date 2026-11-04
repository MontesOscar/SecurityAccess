import 'package:security_access/domain/entities/estado_vivienda.dart';

class Vivienda {
  const Vivienda({
    required this.id,
    required this.numero,
    required this.direccion,
    required this.estado,
    this.residenteId,
    this.residenteNombre,
  });

  final String id;
  final String numero;
  final String direccion;
  final EstadoVivienda estado;
  final String? residenteId;
  final String? residenteNombre;

  bool get tieneResidente => residenteId != null;

  Vivienda copyWith({
    String? direccion,
    EstadoVivienda? estado,
    String? residenteId,
    String? residenteNombre,
    bool limpiarResidente = false,
  }) {
    return Vivienda(
      id: id,
      numero: numero,
      direccion: direccion ?? this.direccion,
      estado: estado ?? this.estado,
      residenteId: limpiarResidente
          ? residenteId
          : residenteId ?? this.residenteId,
      residenteNombre: limpiarResidente
          ? residenteNombre
          : residenteNombre ?? this.residenteNombre,
    );
  }
}
