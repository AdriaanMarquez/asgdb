-- =============================================================================
-- ASIGNATURA: Administración de Sistemas Gestores de Bases de Datos (ASGBD)
-- ALUMNO: Adrián Márquez Rodríguez
-- CURSO: 1º ASIR (IES Francisco Romero Vargas)
-- PRÁCTICA 3: Creación de usuarios, vistas, roles y permisos en MySQL / MariaDB
-- =============================================================================

-- Nos aseguramos de utilizar nuestra base de datos de la tienda informática
USE tienda_informatica;


-- =============================================================================
-- TAREA 1: Creación de usuarios y políticas de conexión y caducidad
-- =============================================================================

-- 1. Creación de cuentas base:
-- Usuario 'gestor_tienda' limitado a conexión local ('localhost').
-- Requisitos de contraseña segura: Mínimo 8 caracteres, combinación de letras mayúsculas, 
-- minúsculas, números y símbolos especiales para prevenir ataques de fuerza bruta o diccionario.
CREATE USER 'gestor_tienda'@'localhost' IDENTIFIED BY 'Gestor2026_';

-- Usuario 'auditor_externo' con acceso desde cualquier host de la red ('%').
CREATE USER 'auditor_externo'@'%' IDENTIFIED BY 'Auditor2026_';


-- 2. Directiva de caducidad de credenciales:
-- Configuramos para que la contraseña de 'auditor_externo' caduque obligatoriamente cada 30 días,
-- evitando vulnerabilidades por credenciales estáticas o filtradas a largo plazo.
ALTER USER 'auditor_externo'@'%' PASSWORD EXPIRE INTERVAL 30 DAY;


-- 3. Directiva de control de sesión:
-- Limitamos el tiempo de vida activo o inactividad de las conexiones del usuario 'gestor_tienda' a 1 hora (3600 segundos).
ALTER USER 'gestor_tienda'@'localhost' WITH MAX_USER_CONNECTIONS 5;
ALTER USER 'gestor_tienda'@'localhost' ATTRIBUTE '{"idle_timeout": 3600, "session_max_lifetime": 3600}';


-- =============================================================================
-- TAREA 2: Creación y asignación de roles
-- =============================================================================

-- 1. Definición del rol operativo:
CREATE ROLE 'rol_consultor';

-- 2. Concesión de privilegios al rol:
-- Otorgamos permisos de solo lectura (SELECT) sobre toda la base de datos 'tienda_informatica'.
GRANT SELECT ON tienda_informatica.* TO 'rol_consultor';

-- 3. Asignación y rol por defecto:
-- Asignamos el rol al usuario 'auditor_externo'.
GRANT 'rol_consultor' TO 'auditor_externo'@'%';

-- Configuramos 'rol_consultor' como el rol por defecto que se activa automáticamente al iniciar sesión.
SET DEFAULT ROLE 'rol_consultor' FOR 'auditor_externo'@'%';


-- =============================================================================
-- TAREA 3: Seguridad mediante Vistas y Privilegios Granulares
-- =============================================================================

-- 1. Creación de la vista de enmascaramiento:
-- Muestra el identificador, nombre y especialidad de los técnicos, ocultando el salario.
CREATE OR REPLACE VIEW v_tecnicos_activos AS
SELECT id, nombre, especialidad
FROM tecnicos;

-- 2. Privilegio granular:
-- Concedemos al usuario 'gestor_tienda' permisos exclusivos de consulta sobre la vista.
GRANT SELECT ON tienda_informatica.v_tecnicos_activos TO 'gestor_tienda'@'localhost';

-- 3. Prueba de denegación (Documentación y sentencia de prueba):
/*
   Si el usuario 'gestor_tienda' intenta ejecutar:
   SELECT * FROM tecnicos;
   
   El SGBD devolverá un error de denegación de permisos.
   Esto demuestra el cumplimiento del principio de menor privilegio, forzando
   al usuario a consultar exclusivamente la vista enmascarada 'v_tecnicos_activos'.
*/

-- =============================================================================
-- TAREA 4: Consistencia y control con WITH CHECK OPTION
-- =============================================================================

-- 1. Vista con restricción de dominio:
-- Filtramos productos con precio <= 50.00, incorporando WITH CHECK OPTION para validar inserciones/actualizaciones.
CREATE OR REPLACE VIEW v_articulos_gama_baja AS
SELECT id, nombre, precio, fabricante_id
FROM articulos
WHERE precio <= 50.00
WITH CHECK OPTION;

-- 2. Demostración técnica:
/*
   Si intentamos insertar un artículo con precio superior al rango permitido a través de la vista:
   INSERT INTO v_articulos_gama_baja (nombre, precio, fabricante_id) VALUES ('Tarjeta Gráfica RTX', 250.00, 2);
   
   El SGBD rechaza la operación inmediatamente devolviendo el siguiente error
   
   Esto ocurre porque la cláusula WITH CHECK OPTION obliga a que cualquier fila insertada 
   o modificada a través de la vista cumpla estrictamente con la condición de la cláusula WHERE (precio <= 50.00).
*/


-- =============================================================================
-- TAREA 5: Auditoría, Resolución de Incidencias y Reflexión Crítica
-- =============================================================================

-- 1. Auditoría de privilegios efectivos:
SHOW GRANTS FOR 'auditor_externo'@'%';
SHOW ACTIVE ROLES;


-- 2. Reflexión sobre el Principio de Mínimo Privilegio:
/*
   ¿Por qué en entornos de producción nunca se debe otorgar ALL PRIVILEGES a usuarios finales o aplicaciones?
   ---------------------------------------------------------------------------------------------------------
   Otorgar privilegios excesivos (como ALL PRIVILEGES, DROP, GRANT OPTION o permisos de modificación estructural) 
   a una aplicación web o usuario operativo vulnera  el principio de mínimo privilegio. 
   
   Relación directa con Inyecciones SQL y brechas de seguridad:
   Si una aplicación web sufre una vulnerabilidad de Inyección SQL (SQLi), un atacante que logre inyectar 
   código malicioso heredará exactamente los permisos del usuario con el que la aplicación se conecta a la base de datos.
   Si ese usuario cuenta con permisos de administración global o ALL PRIVILEGES, el atacante podrá ejecutar comandos destructivos del tipo DROP TABLE, modificar tablas del sistema, 
   o leer ficheros del servidor operativo (LOAD_FILE).
*/


-- 3. Análisis de comportamiento del CHECK OPTION:
/*
   ¿Qué brecha lógica o inconsistencia se introduce si se elimina WITH CHECK OPTION?
   ---------------------------------------------------------------------------------------------------------
   Si un analista elimina la cláusula WITH CHECK OPTION en la vista 'v_articulos_gama_baja'se introduce una grave brecha de integridad en la base de datos.
   
   Cualquier usuario o proceso automatizado podría insertar un registro con un precio elevado a través de la vista.

   Como la vista ya no valida la condición WHERE (precio <= 50.00) en las operaciones de escritura, la fila se insertará 
   correctamente en la tabla base 'articulos'.Al consultar de nuevo la vista 'v_articulos_gama_baja', 
   dicho artículo desaparecerá por completo de los resultados.
*/
