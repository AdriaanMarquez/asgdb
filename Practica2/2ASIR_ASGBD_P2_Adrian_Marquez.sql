Parte 1: Script SQLSQL-- Creación de la base de datos
DROP DATABASE IF EXISTS tienda_informatica;
CREATE DATABASE tienda_informatica CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tienda_informatica;

-- -----------------------------------------------------------------------------
-- 1. Tabla: fabricantes
-- -----------------------------------------------------------------------------
CREATE TABLE fabricantes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    pais VARCHAR(100) NOT NULL
);

-- Inserción de datos iniciales en fabricantes
INSERT INTO fabricantes (id, nombre, pais) VALUES
(1, 'Kingston', 'Estados Unidos'),
(2, 'Asus', 'Taiwán'),
(3, 'Samsung', 'Corea del Sur'),
(4, 'Logitech', 'Suiza'),
(5, 'Intel', 'Estados Unidos');

-- -----------------------------------------------------------------------------
-- 2. Tabla: articulos
-- -----------------------------------------------------------------------------
CREATE TABLE articulos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    fabricante_id INT,
    FOREIGN KEY (fabricante_id) REFERENCES fabricantes(id)
);

-- Inserción de datos iniciales en articulos
INSERT INTO articulos (id, nombre, precio, fabricante_id) VALUES
(1, 'Memoria RAM 16GB DDR4', 45.50, 1),
(2, 'SSD NVMe 1TB', 79.99, 1),
(3, 'Placa Base ROG Strix', 185.00, 2),
(4, 'Monitor 27\" IPS 144Hz', 249.00, 2),
(5, 'Monitor 32\" Curved', 320.00, 3),
(6, 'Ratón Óptico Inalámbrico', 29.99, 4),
(7, 'Teclado Mecánico RGB', 89.90, 4),
(8, 'Procesador Core i7', 310.00, 5);

-- -----------------------------------------------------------------------------
-- 3. Tabla: tecnicos
-- -----------------------------------------------------------------------------
CREATE TABLE tecnicos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    especialidad VARCHAR(150) NOT NULL,
    salario DECIMAL(10,2) NOT NULL
);

-- Inserción de datos iniciales en tecnicos
INSERT INTO tecnicos (id, nombre, especialidad, salario) VALUES
(1, 'Carlos Pérez', 'Hardware', 1800.00),
(2, 'Ana Gómez', 'Redes y Servidores', 2100.00),
(3, 'Luis Martínez', 'Portátiles', 1650.00),
(4, 'Marta Ruiz', 'Movilidad y Tablets', 1750.00);

-- -----------------------------------------------------------------------------
-- 4. Tabla: reparaciones
-- -----------------------------------------------------------------------------
CREATE TABLE reparaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion_averia TEXT NOT NULL,
    coste_reparacion DECIMAL(10,2) NOT NULL,
    tecnico_id INT,
    FOREIGN KEY (tecnico_id) REFERENCES tecnicos(id)
);

-- Inserción de datos iniciales en reparaciones
INSERT INTO reparaciones (id, descripcion_averia, coste_reparacion, tecnico_id) VALUES
(1, 'Sustitución de pantalla rota', 120.50, 3),
(2, 'Cambio de fuente de alimentación', 65.00, 1),
(3, 'Recuperación de datos en disco dañado', 150.00, 2),
(4, 'Limpieza interna y cambio de pasta térmica', 45.00, 1),
(5, 'Sustitución de conector de carga', 50.00, 3),
(6, 'Ampliación de RAM y formateo', 80.00, 4);
Parte 2: Batería de ConsultasMuestra el nombre y el precio de todos los artículos ordenados de forma descendente por su precio.   

SELECT nombre, precio 
FROM articulos 
ORDER BY precio DESC;
Muestra los nombres de los fabricantes cuyo país sea "Estados Unidos".   

SELECT nombre 
FROM fabricantes 
WHERE pais = 'Estados Unidos';
Muestra todos los datos de aquellos artículos cuyo precio sea mayor o igual a 100 y menor o igual a 300.   

SELECT * 
FROM articulos 
WHERE precio BETWEEN 100 AND 300;
Calcula el precio medio de todos los artículos almacenados en la tabla articulos.   

SELECT AVG(precio) AS precio_medio 
FROM articulos;
Muestra el identificador del fabricante y el número de artículos que tiene cada uno.   

SELECT fabricante_id, COUNT(*) AS numero_articulos 
FROM articulos 
GROUP BY fabricante_id;
Muestra los tecnico_id que han realizado más de una reparación.   

SELECT tecnico_id 
FROM reparaciones 
GROUP BY tecnico_id 
HAVING COUNT(*) > 1;
Muestra el nombre y el precio de los artículos fabricados por empresas de 'Taiwán'.   

SELECT nombre, precio 
FROM articulos 
WHERE fabricante_id IN (
    SELECT id 
    FROM fabricantes 
    WHERE pais = 'Taiwán'
);
Muestra la descripción y el coste de la reparación más cara registrada.   

SELECT descripcion_averia, coste_reparacion 
FROM reparaciones 
WHERE coste_reparacion = (
    SELECT MAX(coste_reparacion) 
    FROM reparaciones
);
Muestra el nombre de los técnicos y el importe resultante de sumar a su salario actual un 10% de subida.   

SELECT nombre, (salario * 1.10) AS salario_con_subida 
FROM tecnicos;
Muestra el nombre de los técnicos que no han realizado ninguna reparación.   

SELECT nombre 
FROM tecnicos 
WHERE id NOT IN (
    SELECT DISTINCT tecnico_id 
    FROM reparaciones 
    WHERE tecnico_id IS NOT NULL
);