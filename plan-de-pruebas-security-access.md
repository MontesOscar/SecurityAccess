# Plan de pruebas de frontend: Security Access

Las historias `HU-01` a `HU-16` equivalen a `R1` a `R16` del documento de historias de usuario.

## Índice

| Módulo | Historias |
|---|---|
| [Autenticación](#módulo-1-autenticación) | HU-01, HU-02, HU-03 |
| [Gestión de viviendas](#módulo-2-gestión-de-viviendas) | HU-04, HU-05, HU-06, HU-07 |
| [Gestión de usuarios](#módulo-3-gestión-de-usuarios) | HU-08, HU-09, HU-10, HU-11 |
| [Residente](#módulo-4-residente) | HU-12, HU-13 |
| [Guardia](#módulo-5-guardia) | HU-14, HU-15 |
| [Administración: reportes](#módulo-6-administración-reportes) | HU-16 |

---

## Módulo 1: Autenticación

### HU-01 · Iniciar sesión

| ID |    Tipo     | Qué comprueba | Criterio de aceptación |
|---|:-----------:|---|---|
| UT-HU01 |  Unitaria   | Correo y contraseña rechazan vacío. El correo rechaza formato inválido (`ana@`). | Campos marcados como obligatorios. |
| IT-HU01 | Integracion | Enviar el formulario con credenciales válidas, incorrectas y de cuenta inactiva. | Incorrectas: "Credenciales inválidas". Inactiva: "Su cuenta se encuentra desactivada". |
| UI-HU01 |  Interfaz   | Iniciar sesión como residente, guardia y administrador. Ver el enlace "Recuperar contraseña". | Al ingresar se muestra el menú del rol. "Recuperar contraseña" visible en inicio. |

### HU-02 · Recuperar contraseña

| ID |   Tipo   | Qué comprueba | Criterio de aceptación |
|---|:--------:|---|---|
| UT-HU02 | Unitaria | Nueva contraseña con mínimo 8 caracteres, una mayúscula y un número (`abc` falla, `Abcdefg1` pasa). | Regla de negocio: requisitos mínimos de contraseña. |
| IT-HU02 |     Integracion     | Solicitar recuperación con un correo registrado y con uno no registrado. | No registrado: mensaje sin confirmar existencia. Registrado: "Si está registrado, recibirás instrucciones". |
| UI-HU02 |     Interfaz     | Abrir el enlace válido y guardar la nueva contraseña. | Enlace válido: formulario de nueva contraseña. Al actualizar: regresa a inicio con mensaje de éxito. |

### HU-03 · Cambiar contraseña

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU03 |Unitaria  | La nueva contraseña y su confirmación coinciden, cumple requisitos y es distinta de la actual. | Si no coinciden: "Las contraseñas no coinciden". |
| IT-HU03 | Integracion | Enviar con la contraseña actual incorrecta y luego con la correcta. | Incorrecta: mensaje de error. Éxito: "Contraseña actualizada correctamente". |
| UI-HU03 | Interfaz | Desde el perfil, tocar "Cambiar contraseña" y ver el formulario de 3 campos. | Opción disponible en menú de perfil. |

---

## Módulo 2: Gestión de viviendas

*Solo Administrador.*

### HU-04 · Crear vivienda

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU04 | Unitaria | Identificador obligatorio. Un número repetido en la lista local se rechaza. Residente opcional. | Número repetido: "La vivienda ya está registrada". |
| IT-HU04 | Integracion | Guardar una vivienda sin residente (queda "Disponible"). Repetir con número duplicado. | Se puede guardar sin asignar residente. Duplicado: "La vivienda ya está registrada". |
| UI-HU04 | Interfaz | Tocar "Nueva vivienda", guardar y volver al listado. Ver la vivienda en el desplegable del registro de usuario. | Aparece en el listado con estado visible. Queda lista para los desplegables. |

### HU-05 · Consultar viviendas

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU05 | Unitaria | Filtro por estado (Disponible, Asignada, Inactiva), búsqueda por número o residente y orden por número. | Filtros funcionan correctamente. Lista ordenada por número de vivienda. |
| IT-HU05 | Integracion | Aplicar filtro y búsqueda. La lista muestra número, dirección, residente y estado. | Cada vivienda muestra claramente si tiene responsable. |
| UI-HU05 | Interfaz | Distinguir los 3 estados visualmente. Los botones "Editar" y "Ver historial" abren su pantalla. | Se distinguen visualmente los 3 estados. |

### HU-06 · Editar vivienda / Reasignar residente

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU06 |Unitaria  | El campo número está en solo lectura. Los demás campos validan al editar. | Campo número bloqueado para edición. |
| IT-HU06 | Integracion | Cambiar el residente, confirmar el diálogo y enviar. La lista refleja el cambio. | Al cambiar residente solicita confirmación. Mensaje "Vivienda actualizada correctamente". |
| UI-HU06 | Interfaz | "Editar" abre el formulario con datos cargados y número deshabilitado. El desplegable solo lista usuarios activos. Cancelar no cambia nada. | Formulario con datos actuales cargados. Campo número bloqueado. |

### HU-07 · Desactivar vivienda

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU07 | Unitaria | La función que arma el desplegable de viviendas excluye las "Inactiva". | Ya no aparece en desplegables al crear usuarios. |
| IT-HU07 | Integracion | Seleccionar una vivienda, confirmar y recibir respuesta. El estado cambia a "Inactiva". | Solicita confirmación antes de proceder. Estado "Inactiva". |
| UI-HU07 | Interfaz | "Desactivar" siempre abre el diálogo. Cancelar no cambia nada. Confirmar actualiza el listado. | Solicita confirmación antes de proceder. |

---

## Módulo 3: Gestión de usuarios

*Solo Administrador.*

### HU-08 · Crear usuario

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU08 | Unitaria | Validar nombre, correo, teléfono y rol. Con rol Residente, la vivienda es obligatoria. | Residente sin vivienda: "Debes asignar una vivienda". |
| IT-HU08 | Integracion | Crear un residente con vivienda. Repetir con correo duplicado. | Duplicado: "El correo ya está registrado". Usuario queda "Activo". Mensaje "Usuario registrado correctamente". |
| UI-HU08 | Interfaz | Cambiar el rol: Residente muestra el desplegable de vivienda, Guardia y Administrador lo ocultan. El desplegable no lista viviendas inactivas. | Desplegable muestra solo viviendas existentes y activas. Con Guardia o Administrador no aparece el campo vivienda. |

### HU-09 · Consultar usuarios

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU09 | Unitaria | Filtro por rol y estado, orden por nombre o fecha. El modelo de usuario no incluye contraseña. | Filtros reducen la lista correctamente. No se muestran contraseñas. |
| IT-HU09 | Integracion | Cargar la lista (activos e inactivos). Se muestran nombre, correo, rol, vivienda y estado. | Lista ordenada por nombre o fecha de creación. |
| UI-HU09 | Interfaz | Activos e inactivos se ven distintos. "Editar" y "Cambiar estado" abren la pantalla o el diálogo correcto. | Se distinguen visualmente usuarios activos e inactivos. |

### HU-10 · Editar usuario

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU10 | Unitaria | El campo correo está en solo lectura. Nombre y teléfono validan al editar. | Campo correo bloqueado. |
| IT-HU10 | Integracion | Cambiar la vivienda de un residente, confirmar y enviar. La nueva queda asignada y la anterior "Disponible". | Cambio de vivienda confirma la acción. Vivienda anterior vuelve a "Disponible". Nueva asignación se refleja de inmediato. |
| UI-HU10 | Interfaz | "Editar" abre el formulario con datos cargados y correo deshabilitado. El diálogo permite cancelar o confirmar. | Formulario con datos cargados. Cambio de vivienda confirma la acción. |

### HU-11 · Desactivar usuario

| ID |     Tipo     | Qué comprueba | Criterio de aceptación |
|---|:------------:|---|---|
| UT-HU11 |   Unitaria   | Solo se puede desactivar un usuario activo. Si es residente, su vivienda pasa a "Disponible" en el estado local. | Vivienda liberada aparece como "Disponible". |
| IT-HU11 | Integracion  | Confirmar la desactivación de un residente. Su estado cambia a "Inactivo" y su vivienda se libera. | Estado "Inactivo". Vivienda liberada. Historial intacto. |
| UI-HU11 |   Interfaz   | "Cambiar estado" abre el diálogo. Cancelar no cambia nada. Confirmar actualiza la lista. | Solicita confirmación antes de proceder. |

---

## Módulo 4: Residente

### HU-12 · Crear invitación de visita

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU12 | Unitaria | Nombre del visitante obligatorio. Fecha de entrada no anterior a hoy. Hora de salida posterior a la entrada. | Validación de fechas al ingresar. |
| IT-HU12 | Integracion | Crear una invitación válida y recibir el QR. Repetir con la vivienda inactiva. | Vivienda inactiva: no permite crear ("Su vivienda no está activa"). QR visible. |
| UI-HU12 | Interfaz | Ver el QR, tocar "Compartir" y abrir el menú de compartir. Ver la invitación en el historial como "Activa". | QR visible y compartible. Invitación en historial como "Activa". |

### HU-13 · Consultar historial de visitas

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU13 | Unitaria | Orden por fecha (más reciente primero). Fecha inicial no mayor que la final. Estados Activa, Usada y Vencida. | Ordenada por fecha, más reciente primero. |
| IT-HU13 | Integracion | Filtrar por fechas. Se muestran visitante, fecha, hora de entrada y salida y estado, solo de su vivienda. | Solo muestra sus propios registros. No aparecen datos de otras viviendas ni anteriores. |
| UI-HU13 | Interfaz | Navegar al historial desde el menú. La pantalla es de solo lectura, sin botones de editar o eliminar. | No se pueden eliminar ni modificar registros. |

---

## Módulo 5: Guardia

### HU-14 · Registrar entrada por escaneo QR

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU14 | Unitaria | Tipo y número de identificación obligatorios. Confirmar solo se habilita con ambos. El QR se clasifica como Válida, Inválida o Vencida. | Campo vacío: botón Confirmar bloqueado. |
| IT-HU14 | Integracion | Escanear un QR válido, cargar los datos, llenar la identificación y confirmar. Repetir con un QR inválido. | QR válido: datos cargados y campos habilitados. QR inválido: mensaje, no avanza. Confirmar guarda el registro. |
| UI-HU14 | Interfaz | "Registrar Entrada" abre la cámara sola. Antes de escanear no hay campos. El tipo de identificación es un desplegable. | "Registrar Entrada" abre cámara automáticamente. Tipo de identificación en lista desplegable. |

### HU-15 · Registrar salida por escaneo QR

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU15 | Unitaria | Solo se cierra un registro con entrada y sin salida. Al cerrar, el estado pasa a "Completado". | Sin entrada activa: "No hay registro de entrada". |
| IT-HU15 |Integracion | Escanear un QR con entrada activa, ver los datos y confirmar. Se devuelve la hora de salida. | Con entrada: muestra datos y confirmar. Al confirmar, hora de salida registrada. |
| UI-HU15 |Interfaz | "Registrar Salida" abre la cámara sola. La pantalla no pide datos de identificación. | Se abre cámara automáticamente. No se piden datos de identificación de nuevo. |

---

## Módulo 6: Administración, reportes

### HU-16 · Consultar reporte general de accesos

| ID | Tipo | Qué comprueba | Criterio de aceptación |
|---|:---:|---|---|
| UT-HU16 | Unitaria | Combinar filtros de fechas, vivienda y estado. Ordenar por fecha y hora. Detectar registros sin hora de salida. | Lista ordenada por fecha y hora. Registros sin salida destacados. |
| IT-HU16 | Integracion | Aplicar filtros combinados. Se ven visitante, vivienda, entrada, salida, guardia e identificación de toda la historia de la vivienda. | Se ven todos los accesos de la vivienda a lo largo del tiempo. Datos de identificación visibles. |
| UI-HU16 | Interfaz | Los registros sin salida se resaltan. El botón "Exportar" está disponible. El detalle es de solo lectura. | Registros sin salida destacados claramente. |
