import 'package:flutter_test/flutter_test.dart';
import 'package:security_access/data/repositories/in_memory_auth_repository.dart';
import 'package:security_access/data/repositories/in_memory_vivienda_repository.dart';
import 'package:security_access/data/seed/cuentas_semilla.dart';
import 'package:security_access/domain/entities/estado_cuenta.dart';
import 'package:security_access/domain/entities/estado_vivienda.dart';
import 'package:security_access/domain/entities/rol_usuario.dart';
import 'package:security_access/domain/entities/vivienda.dart';
import 'package:security_access/domain/usecases/asignacion_vivienda.dart';
import 'package:security_access/domain/usecases/cambiar_estado_usuario.dart';
import 'package:security_access/domain/usecases/consultar_usuarios.dart';
import 'package:security_access/domain/usecases/crear_usuario.dart';
import 'package:security_access/domain/usecases/editar_usuario.dart';
import 'package:security_access/domain/usecases/iniciar_sesion.dart';
import 'package:security_access/domain/usecases/listar_viviendas_disponibles.dart';
import 'package:security_access/domain/usecases/consultar_viviendas.dart';
import 'package:security_access/domain/usecases/resultado_cambio_estado_usuario.dart';
import 'package:security_access/domain/usecases/resultado_crear_usuario.dart';
import 'package:security_access/domain/usecases/resultado_editar_usuario.dart';
import 'package:security_access/domain/usecases/resultado_inicio_sesion.dart';

void main() {
  late InMemoryAuthRepository usuarios;
  late InMemoryViviendaRepository viviendas;
  late CrearUsuario crear;
  late EditarUsuario editar;
  late CambiarEstadoUsuario cambiarEstado;
  late IniciarSesion iniciarSesion;

  setUp(() {
    usuarios = InMemoryAuthRepository(CuentasSemilla.registros);
    viviendas = InMemoryViviendaRepository([
      const Vivienda(
        id: 'viv-101',
        numero: '101',
        direccion: 'Calle Uno',
        estado: EstadoVivienda.disponible,
      ),
      const Vivienda(
        id: 'viv-202',
        numero: '202',
        direccion: 'Calle Dos',
        estado: EstadoVivienda.disponible,
      ),
      const Vivienda(
        id: 'viv-9',
        numero: '9',
        direccion: 'Calle Inactiva',
        estado: EstadoVivienda.inactiva,
      ),
    ]);
    final asignacion = AsignacionVivienda(viviendas);
    crear = CrearUsuario(usuarios, asignacion);
    editar = EditarUsuario(usuarios, asignacion);
    cambiarEstado = CambiarEstadoUsuario(usuarios, asignacion);
    iniciarSesion = IniciarSesion(usuarios);
  });

  test(
    'registra un residente, asigna la vivienda y rechaza el correo repetido',
    () async {
      final creado = await crear(
        nombre: ' Carlos Residente ',
        correo: ' Carlos@SecurityAccess.com ',
        telefono: ' 555 ',
        rol: RolUsuario.residente,
        viviendaId: 'viv-101',
      );

      expect(creado, isA<UsuarioCreado>());
      final usuario = (creado as UsuarioCreado).usuario;
      expect(usuario.estado, EstadoCuenta.activo);
      expect(usuario.correo, 'carlos@securityaccess.com');
      expect(usuario.viviendaNumero, '101');
      expect(creado.contrasenaInicial, CrearUsuario.contrasenaInicial);

      final vivienda = await viviendas.buscarPorId('viv-101');
      expect(vivienda!.estado, EstadoVivienda.asignada);
      expect(vivienda.residenteId, usuario.id);

      final repetido = await crear(
        nombre: 'Otro',
        correo: 'carlos@securityaccess.com',
        telefono: '555',
        rol: RolUsuario.guardia,
      );
      expect(repetido, isA<CorreoYaRegistrado>());

      final disponibles = await ListarViviendasDisponibles(
        ConsultarViviendas(viviendas),
      )();
      expect(disponibles.map((item) => item.numero), ['202']);
    },
  );

  test(
    'un residente sin vivienda y una vivienda ocupada o inactiva no se asignan',
    () async {
      expect(
        await crear(
          nombre: 'Ana',
          correo: 'ana@securityaccess.com',
          telefono: '555',
          rol: RolUsuario.residente,
        ),
        isA<ViviendaObligatoria>(),
      );
      expect(
        await crear(
          nombre: 'Ana',
          correo: 'ana@securityaccess.com',
          telefono: '555',
          rol: RolUsuario.residente,
          viviendaId: 'viv-9',
        ),
        isA<ViviendaNoDisponible>(),
      );

      await crear(
        nombre: 'Carlos',
        correo: 'carlos@securityaccess.com',
        telefono: '555',
        rol: RolUsuario.residente,
        viviendaId: 'viv-101',
      );
      expect(
        await crear(
          nombre: 'Elena',
          correo: 'elena@securityaccess.com',
          telefono: '555',
          rol: RolUsuario.residente,
          viviendaId: 'viv-101',
        ),
        isA<ViviendaNoDisponible>(),
      );
    },
  );

  test('guardia y administrador no requieren vivienda', () async {
    final guardia = await crear(
      nombre: 'Nora Guardia',
      correo: 'nora@securityaccess.com',
      telefono: '555',
      rol: RolUsuario.guardia,
    );
    expect((guardia as UsuarioCreado).usuario.viviendaId, isNull);
  });

  test(
    'editar pide confirmación, conserva el correo y mueve la vivienda',
    () async {
      final creado = await crear(
        nombre: 'Carlos',
        correo: 'carlos@securityaccess.com',
        telefono: '555',
        rol: RolUsuario.residente,
        viviendaId: 'viv-101',
      );
      final usuario = (creado as UsuarioCreado).usuario;

      final sinConfirmar = await editar(
        id: usuario.id,
        nombre: 'Carlos Editado',
        telefono: '999',
        rol: RolUsuario.residente,
        viviendaId: 'viv-202',
        confirmarCambioVivienda: false,
      );
      expect(sinConfirmar, isA<EdicionUsuarioRequiereConfirmacion>());
      expect(
        (await viviendas.buscarPorId('viv-101'))!.estado,
        EstadoVivienda.asignada,
      );

      final confirmado = await editar(
        id: usuario.id,
        nombre: 'Carlos Editado',
        telefono: '999',
        rol: RolUsuario.residente,
        viviendaId: 'viv-202',
        confirmarCambioVivienda: true,
      );
      final actualizado = (confirmado as UsuarioActualizado).usuario;
      expect(actualizado.correo, 'carlos@securityaccess.com');
      expect(actualizado.viviendaNumero, '202');
      expect(
        (await viviendas.buscarPorId('viv-101'))!.estado,
        EstadoVivienda.disponible,
      );
      expect((await viviendas.buscarPorId('viv-101'))!.residenteId, isNull);
      expect(
        (await viviendas.buscarPorId('viv-202'))!.residenteNombre,
        'Carlos Editado',
      );
    },
  );

  test('dejar de ser residente libera la vivienda', () async {
    final creado = await crear(
      nombre: 'Carlos',
      correo: 'carlos@securityaccess.com',
      telefono: '555',
      rol: RolUsuario.residente,
      viviendaId: 'viv-101',
    );
    final usuario = (creado as UsuarioCreado).usuario;

    await editar(
      id: usuario.id,
      nombre: 'Carlos',
      telefono: '555',
      rol: RolUsuario.guardia,
      confirmarCambioVivienda: true,
    );

    final guardia = await usuarios.buscarPorId(usuario.id);
    expect(guardia!.rol, RolUsuario.guardia);
    expect(guardia.viviendaId, isNull);
    expect(
      (await viviendas.buscarPorId('viv-101'))!.estado,
      EstadoVivienda.disponible,
    );
  });

  test(
    'desactivar libera la vivienda e impide el acceso; reactivar lo recupera',
    () async {
      final creado = await crear(
        nombre: 'Carlos',
        correo: 'carlos@securityaccess.com',
        telefono: '555',
        rol: RolUsuario.residente,
        viviendaId: 'viv-101',
      );
      final usuario = (creado as UsuarioCreado).usuario;

      final desactivado = await cambiarEstado(id: usuario.id, activar: false);
      expect(desactivado, isA<EstadoUsuarioActualizado>());
      expect(
        (await usuarios.buscarPorId(usuario.id))!.estado,
        EstadoCuenta.inactivo,
      );
      expect(
        (await viviendas.buscarPorId('viv-101'))!.estado,
        EstadoVivienda.disponible,
      );
      expect(await usuarios.buscarPorId(usuario.id), isNotNull);

      final acceso = await iniciarSesion(
        correo: 'carlos@securityaccess.com',
        contrasena: CrearUsuario.contrasenaInicial,
      );
      expect(acceso, isA<InicioSesionCuentaInactiva>());

      await cambiarEstado(id: usuario.id, activar: true);
      final reactivado = await iniciarSesion(
        correo: 'carlos@securityaccess.com',
        contrasena: CrearUsuario.contrasenaInicial,
      );
      expect(reactivado, isA<InicioSesionExitoso>());
    },
  );

  test(
    'la consulta ordena por nombre, filtra y no expone contraseñas',
    () async {
      await crear(
        nombre: 'Zoe Residente',
        correo: 'zoe@securityaccess.com',
        telefono: '555',
        rol: RolUsuario.residente,
        viviendaId: 'viv-101',
      );
      final lista = await ConsultarUsuarios(usuarios)();
      expect(lista.first.nombre, 'Ana Administradora');
      expect(lista.last.nombre, 'Zoe Residente');
      final guardias = await ConsultarUsuarios(usuarios)(
        rol: RolUsuario.guardia,
      );
      expect(guardias.single.nombre, 'Marta Guardia');
      expect(lista.where((usuario) => usuario.correo.contains(' ')), isEmpty);
    },
  );
}
