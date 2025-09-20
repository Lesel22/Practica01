-- DDL
CREATE DATABASE practicas;

\c practicas

CREATE TABLE students (
  student_id    SERIAL PRIMARY KEY,
  nombre        VARCHAR(80) NOT NULL,
  email         VARCHAR(120) NOT NULL UNIQUE,
  ciudad        VARCHAR(60) NOT NULL,
  fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE courses (
  course_id  SERIAL PRIMARY KEY,
  nombre     VARCHAR(100) NOT NULL,
  categoria  VARCHAR(50)  NOT NULL,
  creditos   INT NOT NULL CHECK (creditos > 0)
);

-- estado: 'activa' | 'retirada' | 'aprobada'
CREATE TABLE enrollments (
  enrollment_id  SERIAL PRIMARY KEY,
  student_id     INT NOT NULL REFERENCES students(student_id),
  course_id      INT NOT NULL REFERENCES courses(course_id),
  fecha_matricula DATE NOT NULL DEFAULT CURRENT_DATE,
  estado         VARCHAR(10) NOT NULL CHECK (estado IN ('activa','retirada','aprobada')),
  CONSTRAINT uq_enrollment UNIQUE (student_id, course_id) -- un estudiante no se matricula dos veces al mismo curso
);

CREATE TABLE payments (
  payment_id     SERIAL PRIMARY KEY,
  enrollment_id  INT NOT NULL REFERENCES enrollments(enrollment_id),
  monto          NUMERIC(10,2) NOT NULL CHECK (monto > 0),
  fecha_pago     DATE NOT NULL DEFAULT CURRENT_DATE,
  medio_pago     VARCHAR(20) NOT NULL CHECK (medio_pago IN ('efectivo','tarjeta','transferencia'))
);


-- DATA

-- Students (10)
INSERT INTO students (nombre, email, ciudad, fecha_registro) VALUES
('Ana Torres','ana.torres@example.com','Lima','2025-08-20'),
('Bruno Díaz','bruno.diaz@example.com','Arequipa','2025-08-21'),
('Carla Ramos','carla.ramos@example.com','Cusco','2025-08-22'),
('Diego Paredes','diego.paredes@example.com','Lima','2025-08-25'),
('Elena Silva','elena.silva@example.com','Arequipa','2025-08-26'),
('Fabio Núñez','fabio.nunez@example.com','Trujillo','2025-08-27'),
('Gabriela Mita','gabriela.mita@example.com','Lima','2025-08-28'),
('Hugo Quispe','hugo.quispe@example.com','Chiclayo','2025-08-28'),
('Inés Valdez','ines.valdez@example.com','Cusco','2025-08-29'),
('Jorge León','jorge.leon@example.com','Lima','2025-08-30');

-- Courses (6)
INSERT INTO courses (nombre, categoria, creditos) VALUES
('SQL desde Cero','Data',3),
('Python Básico','Programación',4),
('Modelado de Datos','Data',3),
('Excel para Análisis','Ofimática',2),
('Estadística Intro','Data',3),
('Git y GitHub','DevOps',2);

-- Enrollments (15)
-- estados variados: activa/retirada/aprobada
INSERT INTO enrollments (student_id, course_id, fecha_matricula, estado) VALUES
(1,1,'2025-09-01','activa'),
(1,2,'2025-09-01','aprobada'),
(2,1,'2025-09-02','activa'),
(2,3,'2025-09-02','retirada'),
(3,1,'2025-09-02','aprobada'),
(3,5,'2025-09-03','activa'),
(4,2,'2025-09-03','activa'),
(4,3,'2025-09-03','aprobada'),
(5,1,'2025-09-03','retirada'),
(5,4,'2025-09-03','activa'),
(6,6,'2025-09-04','aprobada'),
(7,2,'2025-09-04','activa'),
(8,3,'2025-09-04','activa'),
(9,5,'2025-09-04','retirada'),
(10,1,'2025-09-05','activa');

-- Payments (algunas matrículas tienen más de un pago; otras ninguna)
-- Busca que sumas sean variadas para validaciones
INSERT INTO payments (enrollment_id, monto, fecha_pago, medio_pago) VALUES
(1, 120.00, '2025-09-05', 'tarjeta'),
(1, 60.00 , '2025-09-10', 'tarjeta'),
(2, 150.00, '2025-09-06', 'efectivo'),
(3, 90.00 , '2025-09-07', 'transferencia'),
(5, 200.00, '2025-09-08', 'tarjeta'),
(6, 80.00 , '2025-09-09', 'efectivo'),
(8, 160.00, '2025-09-09', 'tarjeta'),
(10,70.00 , '2025-09-10', 'transferencia'),
(11,100.00, '2025-09-10', 'efectivo'),
(12,140.00, '2025-09-11', 'tarjeta'),
(14,50.00 , '2025-09-11', 'efectivo'),
(15,60.00 , '2025-09-12', 'transferencia');

--Ejercicios
--A1. Lista student_id, nombre, ciudad, course_id, courses.nombre AS curso, estado de todas las matrículas (activa/retirada/aprobada). Ordena por student_id y course_id.
SELECT S.student_id, S.nombre, S.ciudad, C.course_id, C.nombre AS curso, E.estado 
FROM Students AS S
JOIN enrollments AS E ON S.student_id = E.student_id
JOIN courses AS C ON E.course_id = C.course_id
ORDER BY student_id, course_id;

 --A2. Muestra cursos sin ninguna matrícula (solo course_id, nombre).
 SELECT courses.course_id, nombre FROM courses LEFT JOIN enrollments
 ON courses.course_id = enrollments.course_id WHERE courses.course_id IS NULL;

 -- B1. Cantidad de matrículas por curso: course_id, nombre_curso, total_matriculas (incluye cursos con 0 con LEFT JOIN).
SELECT C.course_id, C.nombre AS nombre_curso, COUNT(e.student_id) AS matriculas
FROM courses AS C
LEFT JOIN enrollments AS E ON C.course_id = E.course_id
GROUP BY C.course_id, C.nombre;

-- B2. Total pagado por estudiante: student_id, nombre, total_pagado (incluye estudiantes con 0 usando LEFT JOIN y COALESCE).
-- COLESCE devuelve el primer valor no nulo, en este caso 0
-- SUM suma los elementos segun GROUP BY
SELECT S.student_id, S.nombre, COALESCE(SUM(P.monto), 0) AS total
FROM students AS S
LEFT JOIN enrollments AS E ON S.student_id = E.student_id
LEFT JOIN payments P ON E.enrollment_id = P.enrollment_id
GROUP BY S.student_id, S.nombre
ORDER BY S.student_id;

--B3. Promedio de monto por medio_pago, mostrando solo medios con promedio ≥ 100
-- AVG Saca el promedio por GROUP BY
SELECT P.medio_pago, AVG(P.monto) AS promedio
FROM payments AS P
GROUP BY P.medio_pago
HAVING AVG(P.monto) >= 100
ORDER BY promedio DESC;

--B4. Por curso, # de matrículas aprobadas: course_id, nombre, aprobadas (si no hay aprobadas, muestra 0).
--Sintaxis CASE, establece una condicion y devuelve un valor si se cumple y otro si no y se acumulan en el SUM
SELECT C.course_id, C.nombre,
    COALESCE(SUM(CASE WHEN E.estado = 'aprobada' THEN 1 ELSE 0 END), 0) AS aprobadas
FROM courses AS C
LEFT JOIN enrollments AS E ON C.course_id = E.course_id
GROUP BY C.course_id, c.nombre
ORDER BY C.course_id;

-- C1. Estudiantes de Arequipa con matrículas activas, mostrando: student_id, nombre, curso, estado.
SELECT  S.student_id, S.nombre, C.nombre, E.estado
FROM Students AS S
JOIN enrollments AS E ON S.student_id = E.student_id
JOIN courses AS C ON E.course_id = C.course_id
WHERE E.estado = 'activa' and S.ciudad = 'Arequipa';

--C2. Top 3 estudiantes por total pagado (desc). Desempata por student_id.
--Similar a 'B2', pero se ordena por total y se recupera solo los 3 mayores LIMIT=3 
SELECT S.student_id, S.nombre, COALESCE(SUM(P.monto), 0) AS total
FROM students AS S
LEFT JOIN enrollments AS E 
ON S.student_id = E.student_id
LEFT JOIN payments P 
ON E.enrollment_id = P.enrollment_id
GROUP BY S.student_id, S.nombre
ORDER BY total DESC, s.student_id
LIMIT 3;


-- D1.Regla de aprobación: marca como aprobada toda matrícula activa cuya suma de pagos ≥ 150.
-- La unica matricula que cumple las condiciones de ser actualizada es la de id 1
-- estado = activa y monto = 180
UPDATE enrollments AS E
SET estado = 'aprobada'
WHERE E.estado = 'activa'
  AND (
    SELECT COALESCE(SUM(P.monto), 0)
    FROM payments AS P
    WHERE P.enrollment_id = E.enrollment_id
  ) >= 150
RETURNING 
    E.enrollment_id,
    E.estado,
    (
      SELECT COALESCE(SUM(P.monto), 0)
      FROM payments AS P
      WHERE P.enrollment_id = E.enrollment_id
    ) AS total;

-- D2. Limpieza: elimina matrículas retiradas que no tienen pagos asociados.
-- Elimina ENROLLMENTS de id 4 y 9
-- Pero deja el 14 que tiene pago asociado
DELETE FROM enrollments AS E
WHERE E.estado = 'retirada'
  AND NOT EXISTS (
      SELECT 1
      FROM payments AS P
      WHERE P.enrollment_id = E.enrollment_id
  )
RETURNING *;

-- E1.Crea un índice que optimice las búsquedas por medio_pago y fecha_pago en payments (consultas de caja por fecha y medio). Explica en 1–2 líneas por qué ayuda.
CREATE INDEX idx_payments_medio_fecha
ON payments (medio_pago, fecha_pago);
--Un indice compuesto ordena internamente la tabla, primero por medio_pago y luego por fecha, evitando la lectura de toda la tabla al hacer busquedas y acelerando las consultas que usen medio_pago y fecha como condicion