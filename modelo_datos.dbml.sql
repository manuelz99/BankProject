// ==========================================
// 1. ENUMS (Tipos definidos)
// ==========================================
Enum rol_usuario {
  ADMIN
  USER
  GUEST
  EDITOR
}

Enum estado_prestamo {
  PENDIENTE
  APROBADO
  PAGADO
  MOROSO
  RECHAZADO
}

// ==========================================
// 2. TABLAS MAESTRAS (Configuración Global)
// ==========================================
Table monedas {
  id integer [primary key, increment]
  nombre varchar
  codigo varchar [unique, note: 'Ej: USD, EUR, ARS']
  simbolo varchar
  factor_conversion_usd double
}

Table sucursales {
  id integer [primary key, increment]
  nombre varchar
  pais varchar
  ciudad varchar
  moneda_principal_id integer [ref: > monedas.id]
}

Table departamentos {
  id integer [primary key, increment]
  nombre varchar [not null]
  codigo_interno varchar [unique]
  presupuesto_anual double
  sucursal_id integer [ref: > sucursales.id]
  jefe_id integer [unique, note: 'Referencia a Empleado']
}

// ==========================================
// 3. NÚCLEO DE IDENTIDAD (Herencia)
// ==========================================
Table personas {
  id integer [primary key, increment]
  nombre varchar
  apellido varchar
  email varchar [unique]
  dni int [unique]
  fecha_nacimiento date
}

Table empleados {
  persona_id integer [primary key, ref: - personas.id]
  legajo varchar [unique]
  sueldo double
  departamento_id integer [ref: > departamentos.id]
  sucursal_id integer [ref: > sucursales.id]
}

Table usuarios {
  persona_id integer [primary key, ref: - personas.id]
  username varchar [unique]
  password varchar
  rol rol_usuario [default: 'USER']
}

// ==========================================
// 4. MÓDULO FINANCIERO
// ==========================================
Table cuentasBancarias {
  id integer [primary key, increment]
  numero_cuenta varchar [unique]
  cantidadDisponible double [default: 0]
  usuario_id integer [ref: > usuarios.persona_id]
  sucursal_id integer [ref: > sucursales.id]
  moneda_id integer [ref: > monedas.id]
}

Table transacciones {
  id integer [primary key, increment]
  monto double
  tipo varchar [note: 'DEPOSITO, RETIRO, TRANSFERENCIA, PAGO_CUOTA']
  fecha timestamp [default: `now()`]
  cuenta_id integer [ref: > cuentasBancarias.id]
  moneda_id integer [ref: > monedas.id]
  entidad_origen_id integer [note: 'ID del Prestamo o Inversion que genero esto']
}

Table prestamos {
  id integer [primary key, increment]
  monto_total double
  cuota_mensual double
  interes_anual double
  estado estado_prestamo [default: 'PENDIENTE']
  fecha_inicio date
  cuenta_id integer [ref: > cuentasBancarias.id]
}

Table inversiones {
  id integer [primary key, increment]
  monto_invertido double
  tasa_retorno double
  fecha_inicio date
  fecha_fin date
  cuenta_id integer [ref: > cuentasBancarias.id]
}

// ==========================================
// 5. INTERACCIÓN (Asistente Virtual)
// ==========================================
Table consultas_asistente {
  id integer [primary key, increment]
  usuario_id integer [ref: > usuarios.persona_id]
  mensaje_usuario text
  respuesta_bot text
  intent varchar [note: 'Ej: CONSULTA_SALDO']
  fue_util boolean
  fecha timestamp [default: `now()`]
}

// ==========================================
// RELACIONES ADICIONALES
// ==========================================
// Relación circular de jefe (Un empleado es jefe de un depto)
Ref: empleados.persona_id - departamentos.jefe_id

Ref: "inversiones"."tasa_retorno" < "inversiones"."fecha_inicio"