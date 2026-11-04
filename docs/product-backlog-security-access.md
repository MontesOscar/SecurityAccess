# Product backlog — Security Access

Backlog del sistema de control de accesos y registro de visitantes. Cada ítem sale de las historias [HU-01 a HU-27](historias-de-usuario-security-access.md) (R1 a R27).

Los puntos son una estimación inicial (Fibonacci). Se ajustan en el refinamiento. Un sprint corto de un equipo pequeño cabe en unos **20 a 25 puntos**.

## Objetivo del producto

Un residente invita a un visitante con un QR vigente. El guardia registra la entrada y la salida. El administrador mantiene viviendas, usuarios y el historial de la residencial.

## Orden de construcción

Las historias no se pueden tomar en cualquier orden:

1. **Sesión y menú por rol** (R1, cierre de sesión de R27). Sin esto no hay pantallas protegidas.
2. **Viviendas** (R4 a R7). Deben existir antes de asignar un residente.
3. **Usuarios** (R8 a R11). El residente necesita una vivienda activa.
4. **Invitaciones** (R12, R14, R25). Producen el QR que usa el guardia.
5. **Acceso en caseta** (R15, R19, R20, R16, R17, R21, R18).
6. **Avisos al residente e historial** (R13, R22).
7. **Reportes, auditoría y exportación** (R23, R24, R26), más recuperación y cambio de contraseña (R2, R3) y expiración de sesión (resto de R27).

La persistencia (API, base local o ambas) se elige en el refinamiento. El backlog no la fija.

## Prioridad

| Prioridad | Significado |
|---|---|
| **Must** | Hace falta para el primer flujo completo: login, vivienda, residente, invitación, entrada y salida. |
| **Should** | Completa la operación diaria (editar, desactivar, cancelar, rechazar, visitas dentro). |
| **Could** | Trazabilidad, exportación, notificaciones y recuperación de acceso. |

## Definición de terminado

Un ítem está terminado cuando:

- Cumple los criterios de aceptación de su historia.
- La pantalla solo muestra estado y envía acciones. La regla de negocio vive en el caso de uso, y los datos pasan por un repositorio (MVVM).
- Los mensajes de error son los definidos en la historia.
- Hay al menos una prueba del caso de uso con el camino feliz y el rechazo principal.

---

## Sprint 1 — Entrar según el rol

**Meta:** un usuario inicia sesión, llega al menú de su rol y puede cerrar sesión. Las rutas internas no se abren sin sesión.

**Capacidad orientativa:** 16 puntos.

| ID | Historia | Puntos | Notas para el sprint |
|---|---|---:|---|
| E1 | Habilitador. Estructura MVVM, navegación y tema base | 5 | Carpetas de presentación, dominio y datos. Tres menús vacíos: residente, guardia, administrador. |
| E2 | Habilitador. Administrador inicial para poder entrar | 2 | Una cuenta semilla. Sin ella no se puede probar R1. |
| PB-01 | R1 Iniciar sesión | 5 | Correo y contraseña obligatorios. "Credenciales inválidas". Cuenta inactiva: "Su cuenta se encuentra desactivada". Menú según rol. Enlace "Recuperar contraseña" visible (la pantalla de R2 puede quedar en blanco hasta el sprint 6). |
| PB-27a | R27 Cerrar sesión y bloquear rutas | 4 | "Cerrar sesión" en el menú de usuario. Al cerrar, no se vuelve a una pantalla protegida con el historial. La expiración por inactividad queda en PB-27b. |

**Fuera de este sprint:** recuperar contraseña, viviendas, usuarios.

**Demostración:** iniciar con la cuenta semilla, ver el menú de administrador, cerrar sesión y comprobar que el menú ya no abre.

---

## Sprint 2 — Catálogo de viviendas

**Meta:** el administrador registra, consulta, edita y desactiva viviendas. El número es único y el estado se ve en el listado.

**Depende de:** Sprint 1.  
**Capacidad orientativa:** 21 puntos.

| ID | Historia | Puntos | Notas para el sprint |
|---|---|---:|---|
| PB-04 | R4 Crear vivienda | 5 | Número, dirección, residente opcional. Sin residente queda "Disponible". Número repetido: "La vivienda ya está registrada". En este sprint el residente opcional puede quedar deshabilitado hasta que existan usuarios (Sprint 3); el alta sin residente es el camino obligatorio. |
| PB-05 | R5 Consultar viviendas | 5 | Lista por número: número, dirección, residente, estado. Filtro Disponible / Asignada / Inactiva. Búsqueda por número o residente. Acciones Editar y Ver historial (el historial muestra vacío hasta que haya visitas). |
| PB-06 | R6 Editar vivienda | 8 | El número no se edita. Confirmación al cambiar residente. El anterior pierde la vivienda; el historial no se borra. Si aún no hay residentes, este ítem cubre la edición de dirección y deja la reasignación lista para cuando exista el desplegable de usuarios. |
| PB-07 | R7 Desactivar vivienda | 3 | Confirmación. Pasa a "Inactiva" y sale de los desplegables. Se puede reactivar. El historial se conserva. |

**Demostración:** crear dos viviendas, rechazar un número duplicado, filtrar por estado, editar la dirección, desactivar una y reactivarla.

---

## Sprint 3 — Usuarios y asignación

**Meta:** el administrador da de alta residentes, guardias y administradores. El residente queda ligado a una vivienda y esa vivienda pasa a "Asignada".

**Depende de:** Sprint 2.  
**Capacidad orientativa:** 24 puntos. Si el sprint se pasa, PB-10 se mueve al siguiente sin romper la meta.

| ID | Historia | Puntos | Notas para el sprint |
|---|---|---:|---|
| PB-08 | R8 Crear usuario | 8 | Nombre, correo único, teléfono, rol. Residente exige vivienda activa (Disponible o Asignada; no Inactiva). Guardia y administrador no muestran vivienda. Correo duplicado: "El correo ya está registrado". Residente sin vivienda: "Debes asignar una vivienda". Estado inicial "Activo". |
| PB-09 | R9 Consultar usuarios | 3 | Nombre, correo, rol, vivienda, estado. Sin contraseñas. Filtro por rol y por Activo / Inactivo. |
| PB-10 | R10 Editar usuario | 8 | El correo no se edita. Cambiar vivienda pide confirmación, libera la anterior ("Disponible") y asigna la nueva. Si deja de ser residente, pierde la vivienda. |
| PB-11 | R11 Desactivar usuario | 5 | No se borra. Pasa a "Inactivo", no puede entrar (mensaje de R1) y, si era residente, la vivienda vuelve a "Disponible". Se puede reactivar. Confirmación previa. |

**Demostración:** crear un residente sobre una vivienda disponible, verla como "Asignada", entrar con ese residente a su menú, desactivarlo y comprobar que el login lo rechaza y la vivienda queda libre.

---

## Resto del backlog, en orden

Estos ítems se refinan al cerrar el sprint anterior. El corte en sprints 4 a 8 es una propuesta, no un compromiso.

### Sprint 4 — Invitación del residente (propuesto, 21 pts)

| ID | Ref | Historia | Prioridad | Pts | Depende de |
|---|---|---|---|---|---|
| PB-12 | R12 | Crear invitación con QR | Must | 8 | PB-08, vivienda activa |
| PB-25 | R25 | Consultar invitaciones y su detalle | Must | 5 | PB-12 |
| PB-14 | R14 | Cancelar invitación activa | Should | 5 | PB-12 |
| PB-13 | R13 | Historial de visitas de mi vivienda | Should | 3 | PB-08. La lista puede llegar vacía hasta el sprint 5; la regla de "solo desde mi asignación" sí entra aquí. |

Reglas que no se negocian en PB-12: entrada no anterior a hoy, salida posterior a la entrada, QR único, estado inicial "Activa", vivienda inactiva bloquea la creación.

### Sprint 5 — Entrada en caseta (propuesto, 24 pts)

| ID | Ref | Historia | Prioridad | Pts | Depende de |
|---|---|---|---|---|---|
| PB-20 | R20 | Permiso de cámara y QR ilegible | Must | 5 | Menú guardia |
| PB-15 | R15 | Registrar entrada por QR | Must | 13 | PB-12, PB-20 |
| PB-19 | R19 | Validar identidad del visitante | Must | 3 | PB-15. Se construye dentro del mismo flujo de entrada. |
| PB-17 | R17 | Registrar acceso rechazado | Should | 3 | PB-15 |

PB-15, PB-19 y PB-20 son un solo flujo de pantalla. Conviene planearlos en el mismo sprint. Sin QR leído no se habilitan identificación ni confirmación. Identidad no coincidente no deja autorizar la entrada y permite el rechazo con motivo.

### Sprint 6 — Salida, ocupación y cuenta (propuesto, 23 pts)

| ID | Ref | Historia | Prioridad | Pts | Depende de |
|---|---|---|---|---|---|
| PB-16 | R16 | Registrar salida por QR | Must | 5 | PB-15 |
| PB-21 | R21 | Visitas que siguen dentro | Should | 5 | PB-15 |
| PB-18 | R18 | Salida manual con motivo | Should | 5 | PB-16, PB-21 |
| PB-03 | R3 | Cambiar contraseña en sesión | Could | 3 | PB-01 |
| PB-02 | R2 | Recuperar contraseña | Could | 5 | PB-01. El enlace del login ya existe desde el sprint 1. |

### Sprint 7 — Aviso al residente y reportes (propuesto, 21 pts)

| ID | Ref | Historia | Prioridad | Pts | Depende de |
|---|---|---|---|---|---|
| PB-22 | R22 | Notificar entrada, salida y rechazo | Could | 8 | PB-15, PB-16, PB-17 |
| PB-23 | R23 | Reporte general de accesos | Should | 8 | PB-15 |
| PB-27b | R27 | Expirar sesión por inactividad | Should | 5 | PB-27a |

PB-13 se completa aquí si en el sprint 4 solo quedó el contenedor: el residente ve entradas, salidas y estados desde su fecha de asignación, nunca el historial del residente anterior.

### Sprint 8 — Auditoría y exportación (propuesto, 13 pts)

| ID | Ref | Historia | Prioridad | Pts | Depende de |
|---|---|---|---|---|---|
| PB-24 | R24 | Consultar auditoría | Could | 8 | Operaciones de los sprints anteriores. Solo administrador. Los registros no se editan ni se borran. |
| PB-26 | R26 | Exportar el reporte filtrado a CSV | Could | 5 | PB-23. La exportación también se audita. |

Desde el sprint 1 conviene ir dejando el registro de auditoría en las operaciones, aunque la pantalla de consulta llegue hasta el sprint 8. Si se deja para el final, hay que reconstruir eventos que ya ocurrieron.

---

## Backlog completo

| Orden | ID | Ref | Ítem | Módulo | Rol | Prioridad | Pts | Sprint sugerido |
|---:|---|---|---|---|---|---|---:|---|
| 1 | E1 | — | Estructura MVVM y navegación por rol | Base | Todos | Must | 5 | 1 |
| 2 | E2 | — | Cuenta administradora inicial | Base | Administrador | Must | 2 | 1 |
| 3 | PB-01 | R1 | Iniciar sesión | Autenticación | Todos | Must | 5 | 1 |
| 4 | PB-27a | R27 | Cerrar sesión y proteger rutas | Autenticación | Todos | Must | 4 | 1 |
| 5 | PB-04 | R4 | Crear vivienda | Viviendas | Administrador | Must | 5 | 2 |
| 6 | PB-05 | R5 | Consultar viviendas | Viviendas | Administrador | Must | 5 | 2 |
| 7 | PB-06 | R6 | Editar vivienda y reasignar | Viviendas | Administrador | Should | 8 | 2 |
| 8 | PB-07 | R7 | Desactivar y reactivar vivienda | Viviendas | Administrador | Should | 3 | 2 |
| 9 | PB-08 | R8 | Crear usuario | Usuarios | Administrador | Must | 8 | 3 |
| 10 | PB-09 | R9 | Consultar usuarios | Usuarios | Administrador | Must | 3 | 3 |
| 11 | PB-10 | R10 | Editar usuario | Usuarios | Administrador | Should | 8 | 3 |
| 12 | PB-11 | R11 | Desactivar y reactivar usuario | Usuarios | Administrador | Should | 5 | 3 |
| 13 | PB-12 | R12 | Crear invitación con QR | Residente | Residente | Must | 8 | 4 |
| 14 | PB-25 | R25 | Consultar invitaciones | Residente | Residente | Must | 5 | 4 |
| 15 | PB-14 | R14 | Cancelar invitación | Residente | Residente | Should | 5 | 4 |
| 16 | PB-13 | R13 | Historial de visitas de la vivienda | Residente | Residente | Should | 3 | 4 |
| 17 | PB-20 | R20 | Cámara y QR ilegible | Guardia | Guardia | Must | 5 | 5 |
| 18 | PB-15 | R15 | Registrar entrada por QR | Guardia | Guardia | Must | 13 | 5 |
| 19 | PB-19 | R19 | Validar identidad | Guardia | Guardia | Must | 3 | 5 |
| 20 | PB-17 | R17 | Registrar rechazo | Guardia | Guardia | Should | 3 | 5 |
| 21 | PB-16 | R16 | Registrar salida por QR | Guardia | Guardia | Must | 5 | 6 |
| 22 | PB-21 | R21 | Visitas dentro de la residencial | Guardia | Guardia | Should | 5 | 6 |
| 23 | PB-18 | R18 | Salida manual | Guardia | Guardia | Should | 5 | 6 |
| 24 | PB-03 | R3 | Cambiar contraseña | Autenticación | Todos | Could | 3 | 6 |
| 25 | PB-02 | R2 | Recuperar contraseña | Autenticación | Todos | Could | 5 | 6 |
| 26 | PB-22 | R22 | Notificar entrada, salida y rechazo | Guardia | Residente | Could | 8 | 7 |
| 27 | PB-23 | R23 | Reporte general de accesos | Reportes | Administrador | Should | 8 | 7 |
| 28 | PB-27b | R27 | Expirar sesión inactiva | Autenticación | Todos | Should | 5 | 7 |
| 29 | PB-24 | R24 | Consultar auditoría | Reportes | Administrador | Could | 8 | 8 |
| 30 | PB-26 | R26 | Exportar reporte a CSV | Reportes | Administrador | Could | 5 | 8 |

**Total:** 30 ítems, **173 puntos**. Los 27 requisitos están cubiertos. R27 está partido en cierre de sesión (sprint 1) y expiración (sprint 7). E1 y E2 no son historias de usuario; desbloquean el primer sprint.

## Qué tomar el lunes

El primer sprint es E1, E2, PB-01 y PB-27a. El primer incremento demostrable es entrar como administrador y salir de la sesión. Las viviendas empiezan en el sprint 2, que es el orden que ya fijan las historias.
