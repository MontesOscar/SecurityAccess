# Sistema de control de accesos y registro de visitantes

**Documento de historias de usuario, versión final** (HU-01 a HU-16, equivalentes a R1 a R16)

## Índice

1. [Definición de roles](#definición-de-roles)
2. [Módulo 1: Autenticación](#módulo-1-autenticación) (R1 a R3)
3. [Módulo 2: Gestión de viviendas](#módulo-2-gestión-de-viviendas) (R4 a R7)
4. [Módulo 3: Gestión de usuarios](#módulo-3-gestión-de-usuarios) (R8 a R11)
5. [Módulo 4: Residente](#módulo-4-residente) (R12 a R13)
6. [Módulo 5: Guardia / Seguridad](#módulo-5-guardia--seguridad) (R14 a R15)
7. [Módulo 6: Administración, reportes](#módulo-6-administración-reportes) (R16)
8. [Resumen](#resumen)

---

## Definición de roles

| Rol | Descripción |
|---|---|
| Residente | Crea invitaciones, genera códigos QR, consulta historial de su vivienda |
| Guardia | Escanea QR, valida identificación, registra entradas y salidas |
| Administrador | Alta/baja/edición de viviendas y usuarios, asignaciones, reportes |

---

## Módulo 1: Autenticación

### R1 | Iniciar sesión

**Nombre:** Iniciar sesión en la aplicación

**Descripción:** Como usuario registrado, quiero ingresar con mis credenciales para acceder a las funcionalidades según mi rol.

**Datos de entrada:**
- Correo electrónico
- Contraseña

**Datos de salida:**
- Acceso al menú principal según rol
- Mensaje de bienvenida / Mensaje de error

**Reglas de negocio:**
- El correo debe existir en el sistema
- La contraseña debe coincidir con la registrada
- La cuenta debe estar activa
- Se distinguen permisos según el rol asignado

**Criterios de aceptación:**
- Campos marcados como obligatorios
- Credenciales incorrectas → mensaje: "Credenciales inválidas"
- Cuenta inactiva → "Su cuenta se encuentra desactivada"
- Al ingresar → menú correspondiente al rol
- Opción "Recuperar contraseña" visible en inicio

---

### R2 | Recuperar contraseña

**Nombre:** Recuperar contraseña olvidada

**Descripción:** Como usuario registrado, quiero restablecer mi contraseña cuando la olvide para recuperar el acceso.

**Datos de entrada:**
- Correo electrónico registrado
- Enlace/código por correo

**Datos de salida:**
- Mensaje de confirmación de envío
- Formulario de nueva contraseña

**Reglas de negocio:**
- El enlace tiene vigencia limitada
- Nueva contraseña: mínimo 8 caracteres, mayúscula y número
- No se permite reutilizar la contraseña anterior

**Criterios de aceptación:**
- Correo no registrado → mensaje sin confirmar existencia
- Correo válido → "Si está registrado, recibirás instrucciones"
- Enlace válido → formulario de nueva contraseña
- Actualizado → redirige a inicio con mensaje de éxito

---

### R3 | Cambiar contraseña

**Nombre:** Cambiar contraseña desde la sesión

**Descripción:** Como usuario con sesión activa, quiero cambiar mi contraseña actual por una nueva para mantener la seguridad.

**Datos de entrada:**
- Contraseña actual
- Nueva contraseña
- Confirmar nueva contraseña

**Datos de salida:**
- Mensaje de cambio exitoso
- Acceso con nueva contraseña
- Error si no coinciden

**Reglas de negocio:**
- Contraseña actual debe ser correcta
- Nueva contraseña debe cumplir requisitos mínimos
- No se permite reutilizar la contraseña actual

**Criterios de aceptación:**
- Opción disponible en menú de perfil
- Contraseña actual incorrecta → mensaje de error
- No coinciden → "Las contraseñas no coinciden"
- Éxito → "Contraseña actualizada correctamente"

---

## Módulo 2: Gestión de viviendas

*(Solo Administrador. Se crean primero.)*

### R4 | Crear vivienda

**Nombre:** Registrar nueva vivienda

**Descripción:** Como Administrador, quiero dar de alta todas las viviendas de la residencial para que estén disponibles en el sistema y puedan ser asignadas a residentes.

**Datos de entrada:**
- Número o identificador único de vivienda
- Dirección o referencia
- Residente asignado (opcional, se puede dejar vacío)

**Datos de salida:**
- Vivienda registrada y disponible
- Mensaje de confirmación
- Estado: "Disponible" o "Asignada"

**Reglas de negocio:**
- El identificador de vivienda NO se repite → es único
- Todas las viviendas deben estar registradas antes de asignarlas
- Al crear sin residente → queda como "Disponible"
- Al asignar residente → pasa a "Asignada"
- Solo un residente principal por vivienda

**Criterios de aceptación:**
- Número repetido → "La vivienda ya está registrada"
- Se puede guardar sin asignar residente
- Aparece en el listado con estado visible
- Queda lista para aparecer en desplegables

---

### R5 | Consultar viviendas

**Nombre:** Listar viviendas registradas

**Descripción:** Como Administrador, quiero ver todas las viviendas con su estado y asignación para saber cuáles están ocupadas y cuáles disponibles.

**Datos de entrada:**
- Filtro por estado (Disponible / Asignada / Inactiva)
- Buscador por número o residente

**Datos de salida:**
- Lista: número, dirección, residente asignado, estado
- Botones: Editar / Ver historial

**Reglas de negocio:**
- Se muestran TODAS las viviendas registradas
- Estado "Disponible" = sin residente asignado
- Estado "Asignada" = con residente activo
- Estado "Inactiva" = fuera de servicio

**Criterios de aceptación:**
- Lista ordenada por número de vivienda
- Se distinguen visualmente los 3 estados
- Filtros funcionan correctamente
- Cada vivienda muestra claramente si tiene responsable

---

### R6 | Editar vivienda / Reasignar residente

**Nombre:** Modificar datos o cambiar residente de vivienda

**Descripción:** Como Administrador, quiero actualizar datos de una vivienda o reasignarla cuando cambie el residente. El historial de la vivienda se conserva.

**Datos de entrada:**
- Seleccionar vivienda del listado
- Datos a modificar
- Nuevo residente (desplegable de usuarios activos)

**Datos de salida:**
- Formulario con datos actuales cargados
- Mensaje: "Vivienda actualizada correctamente"
- Cambio reflejado inmediatamente

**Reglas de negocio:**
- El número de vivienda NO se puede modificar
- Al asignar nuevo residente → se desvincula automáticamente al anterior
- El residente anterior pierde acceso a esa vivienda
- El historial de la vivienda NO se borra → permanece completo
- El nuevo residente solo ve registros desde su asignación
- La administración ve TODO el historial completo

**Criterios de aceptación:**
- Campo número bloqueado para edición
- Al cambiar residente → solicita confirmación
- Residente anterior ya no puede crear invitaciones aquí
- Nuevo residente obtiene acceso inmediato
- Historial anterior intacto y visible para administración

---

### R7 | Desactivar vivienda

**Nombre:** Desactivar vivienda del sistema

**Descripción:** Como Administrador, quiero desactivar viviendas que ya no forman parte del control para mantener el listado depurado.

**Datos de entrada:**
- Seleccionar vivienda
- Confirmación de acción

**Datos de salida:**
- Estado: "Inactiva"
- Mensaje de confirmación

**Reglas de negocio:**
- Vivienda inactiva → no aparece en desplegables de asignación
- Su residente pierde acceso para crear invitaciones
- Registros históricos se conservan
- Se puede reactivar

**Criterios de aceptación:**
- Solicita confirmación antes de proceder
- Ya no aparece en desplegables al crear usuarios
- Residente intenta crear invitación → "Su vivienda no está activa"
- Historial sigue disponible para administración

---

## Módulo 3: Gestión de usuarios

*(Solo Administrador.)*

### R8 | Crear usuario

**Nombre:** Registrar nuevo usuario en el sistema

**Descripción:** Como Administrador, quiero dar de alta usuarios asignando su rol. Si es Residente, elijo su vivienda de la lista de viviendas ya registradas.

**Datos de entrada:**
- Nombre completo
- Correo electrónico único
- Teléfono
- Rol: Residente / Guardia / Administrador
- Vivienda asignada (solo si rol = Residente) → lista desplegable

**Datos de salida:**
- Confirmación de usuario creado
- Credenciales / instrucciones de acceso
- Mensaje: "Usuario registrado correctamente"

**Reglas de negocio:**
- La vivienda debe estar previamente registrada → aparece en desplegable
- El desplegable solo muestra viviendas en estado Disponible o Asignada (no inactivas)
- Si rol = Residente → debe seleccionar una vivienda obligatoriamente
- Si rol = Guardia o Administrador → campo vivienda no aparece
- Al asignar → la vivienda cambia automáticamente a estado "Asignada"
- Correo único en el sistema

**Criterios de aceptación:**
- Campos obligatorios marcados
- Rol Residente sin elegir vivienda → mensaje: "Debes asignar una vivienda"
- Desplegable muestra solo viviendas existentes y activas
- Vivienda elegida → ya no aparece disponible para otros
- Correo duplicado → "El correo ya está registrado"
- Usuario queda con estado "Activo"

---

### R9 | Consultar usuarios

**Nombre:** Ver listado de usuarios del sistema

**Descripción:** Como Administrador, quiero ver todos los usuarios con sus datos, rol y vivienda asignada para llevar el control de accesos.

**Datos de entrada:**
- Filtro por rol
- Filtro por estado (Activo/Inactivo)

**Datos de salida:**
- Lista: nombre, correo, rol, vivienda asignada, estado
- Botones: Editar / Cambiar estado

**Reglas de negocio:**
- Se muestran todos los usuarios
- No se muestran contraseñas
- Vivienda asignada aparece con su número

**Criterios de aceptación:**
- Lista ordenada por nombre o fecha de creación
- Filtros reducen la lista correctamente
- Se distinguen visualmente usuarios activos e inactivos

---

### R10 | Editar usuario

**Nombre:** Modificar datos de usuario existente

**Descripción:** Como Administrador, quiero actualizar datos de un usuario o cambiar su vivienda asignada. La reasignación maneja el historial sin perderlo.

**Datos de entrada:**
- Seleccionar usuario
- Datos a modificar
- Nueva vivienda (desplegable, si aplica)

**Datos de salida:**
- Formulario con datos cargados
- Mensaje de actualización exitosa

**Reglas de negocio:**
- Correo no se puede modificar
- Cambiar vivienda → desvincula de la anterior, asigna a la nueva
- Si deja de ser Residente → pierde acceso a su vivienda anterior
- La vivienda anterior queda "Disponible"
- Historial de cada vivienda permanece en ella

**Criterios de aceptación:**
- Campo correo bloqueado
- Cambio de vivienda → confirma acción
- Vivienda anterior vuelve a "Disponible"
- Nueva asignación se refleja de inmediato

---

### R11 | Desactivar usuario

**Nombre:** Desactivar acceso de usuario

**Descripción:** Como Administrador, quiero desactivar cuentas que ya no deben tener acceso. La vivienda asignada queda disponible para reasignar.

**Datos de entrada:**
- Seleccionar usuario
- Confirmación

**Datos de salida:**
- Estado: "Inactivo"
- Mensaje de confirmación

**Reglas de negocio:**
- No se elimina → solo cambia estado
- Si era Residente → su vivienda pasa a "Disponible" automáticamente
- Usuario inactivo no puede iniciar sesión
- Historial del sistema se conserva
- Se puede reactivar

**Criterios de aceptación:**
- Solicita confirmación antes de proceder
- Vivienda liberada aparece como "Disponible"
- Intento de ingreso → acceso denegado
- Todo el historial permanece intacto

---

## Módulo 4: Residente

### R12 | Crear invitación de visita

**Nombre:** Generar invitación con código QR

**Descripción:** Como Residente, quiero crear una invitación con datos del visitante y horario para generar un código QR que permita su acceso.

**Datos de entrada:**
- Nombre del visitante
- Fecha y hora de entrada
- Fecha y hora de salida

**Datos de salida:**
- Código QR único generado
- Resumen de la invitación
- Opción de compartir QR

**Reglas de negocio:**
- Vivienda debe estar activa
- Fecha de entrada no anterior a hoy
- Hora de salida posterior a entrada
- QR único e irrepetible, válido solo en el horario establecido

**Criterios de aceptación:**
- Vivienda inactiva → no permite crear invitaciones
- Validación de fechas al ingresar
- QR visible y compartible
- Invitación en historial como "Activa"

---

### R13 | Consultar historial de visitas

**Nombre:** Ver historial de entradas y salidas

**Descripción:** Como Residente, quiero ver el historial de visitas a mi vivienda desde que fui asignado.

**Datos de entrada:**
- Filtro por fechas (opcional)

**Datos de salida:**
- Lista: visitante, fecha, hora entrada/salida, estado

**Reglas de negocio:**
- Solo ve registros de su vivienda y desde su asignación
- No ve historial de residentes anteriores
- No se pueden eliminar ni modificar registros
- Estados: Activa / Usada / Vencida

**Criterios de aceptación:**
- Ordenada por fecha, más reciente primero
- Solo muestra sus propios registros
- No aparecen datos de otras viviendas ni anteriores

---

## Módulo 5: Guardia / Seguridad

### R14 | Registrar entrada por escaneo QR

**Nombre:** Registrar entrada de visitante

**Descripción:** Como Guardia, quiero escanear el código QR con la cámara, verificar validez, capturar identificación y autorizar el acceso. Sin escanear no avanzo.

**Datos de entrada:**
- Lectura QR por cámara
- Tipo de identificación (desplegable)
- Número / folio de identificación

**Datos de salida:**
- Datos de la invitación: vivienda, visitante, horario
- Mensaje: Válida / Inválida / Vencida
- Confirmación de entrada registrada

**Reglas de negocio:**
- Sin escanear QR → no se muestran campos ni se avanza
- QR debe existir, estar vigente y sin usar
- Vivienda debe estar activa
- Tipo y número de identificación → ambos obligatorios
- Guardia verifica que la persona coincida con los datos

**Criterios de aceptación:**
- "Registrar Entrada" → abre cámara automáticamente
- QR inválido → mensaje, no avanza
- QR válido → datos cargados + campos habilitados
- Tipo de identificación en lista desplegable
- Campo vacío → botón Confirmar bloqueado
- Confirmar → registro completo guardado

---

### R15 | Registrar salida por escaneo QR

**Nombre:** Registrar salida de visitante

**Descripción:** Como Guardia, quiero escanear el QR para registrar la salida y cerrar el registro de la visita.

**Datos de entrada:**
- Lectura QR por cámara

**Datos de salida:**
- Datos de la entrada activa
- Confirmación de salida con hora exacta

**Reglas de negocio:**
- Solo se cierra si existe entrada sin salida
- No se piden datos de identificación nuevamente
- Estado cambia a "Completado"

**Criterios de aceptación:**
- Se abre cámara automáticamente
- Sin entrada activa → "No hay registro de entrada"
- Con entrada → muestra datos + confirmar
- Al confirmar → hora de salida registrada

---

## Módulo 6: Administración, reportes

### R16 | Consultar reporte general de accesos

**Nombre:** Ver reporte completo de accesos

**Descripción:** Como Administrador, quiero consultar todos los accesos de la residencial con filtros, incluyendo historial completo de cada vivienda.

**Datos de entrada:**
- Rango de fechas
- Vivienda específica
- Estado

**Datos de salida:**
- Listado: visitante, vivienda, hora entrada/salida, guardia, identificación
- Historial completo sin importar cambios de residente
- Opción de exportar

**Reglas de negocio:**
- Se muestra TODO el historial de cada vivienda sin importar quién fue residente
- No se pueden modificar ni eliminar registros
- Se puede filtrar por vivienda, fechas y estado

**Criterios de aceptación:**
- Lista ordenada por fecha y hora
- Se ven todos los accesos de la vivienda a lo largo del tiempo
- Registros sin salida destacados claramente
- Datos de identificación capturados visibles

---

## Resumen

| Módulo | Historias | Clave principal |
|---|:---:|---|
| Autenticación | 3 | Acceso seguro por rol |
| Gestión de viviendas | 4 | Se crean PRIMERO → disponibles para asignar |
| Gestión de usuarios | 4 | Se asigna vivienda desde desplegable |
| Residente | 2 | Invitaciones y su historial |
| Guardia | 2 | Cámara = paso obligatorio + identificación |
| Administración, reportes | 1 | Historial completo por vivienda |
| **Total** | **16** | |
