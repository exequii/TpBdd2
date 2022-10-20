
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




-- ESTO GENERA UN CURSOR QUE RECORRE LA TABLA Y TE TRAE UNO POR UNO LOS RESULTADOS QUE LE PIDAS DE LA TABLA.
DECLARE @elementoCursor VARCHAR(MAX), @cursorTipo VARCHAR(MAX);

DECLARE contact_cursor CURSOR FOR SELECT Nombre FROM Personas;
OPEN contact_cursor;   
FETCH NEXT FROM contact_cursor INTO @elementoCursor; 
-- el INTO le indica en donde quiero poner el resultado que trae el cursor. Tengo que poner la cantidad de variables segun lo que traiga en el SELECT donde declaro el cursor, en este caso una variable sola porque traigo solo el nombre.   
WHILE @@FETCH_STATUS = 0 -- FETCH_STATUS => Devuelve 0 si esta recorriendo una tabla, devuelve -1 si ya termino.
BEGIN
	-- Aca puedo hacer cosas con los datos que dispongo en ese momento
	select @elementoCursor as Elemento;
   FETCH NEXT FROM contact_cursor INTO @elementoCursor;  
END    
CLOSE contact_cursor;  
DEALLOCATE contact_cursor;  
GO  

-- Consulta dinamica
DECLARE @sqlDinamico NVARCHAR(MAX);
SET @sqlDinamico = 'SELECT Nombre FROM Personas';
EXECUTE SP_EXECUTESQL @sqlDinamico;



