
SELECT * FROM TpBdd2Origen.sys.all_columns;
SELECT * FROM TpBdd2Origen.sys.all_objects;
SELECT * FROM TpBdd2Origen.sys.objects;
SELECT * FROM TpBdd2Origen.sys.schemas;
SELECT * FROM TpBdd2Origen.sys.system_columns;

SELECT * FROM TpBdd2Origen.sys.tables;
SELECT * FROM Personas;
INSERT INTO Personas (Nombre,Apellido) VALUES ('Ezequiel','Sanson'),('Nahuel','Saavedra'),('Joel','Misterio'),('Keko','Incognita'),('Alexis','Quiensabe');


-- COMO OBTENER LA CANTIDAD DE TABLAS QUE TIENE LA BDD
DECLARE @cantidadTablas int;
SET @cantidadTablas = (SELECT COUNT(*) FROM TpBdd2Origen.sys.tables);
SELECT @cantidadTablas as CantidadTablas;

-- COMO OBTENER EL NOMBRE DE LAS TABLAS DE UNA BDD
DECLARE @nombreTabla varchar(50);
SET @nombreTabla = (SELECT name FROM TpBdd2Origen.sys.tables WHERE ??);
SELECT @nombreTabla as NombreTabla;


-- COMO OBTENGO LA CANTIDAD DE COLUMNAS DE UNA TABLA
DECLARE @cantidadColumnas int;
SET @cantidadColumnas = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Personas');
SELECT @cantidadColumnas as CantidadColumnas;

-- COMO OBTENGO EL NOMBRE DE LOS CAMPOS DE UNA TABLA
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Personas';



