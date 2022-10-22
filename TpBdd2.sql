
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









-------------------------------------------------------------------------------
----------------		CREACION DE BASES DE DATOS		-----------------------
-------------------------------------------------------------------------------

USE MASTER

IF EXISTS(select * from sys.databases where name='DB_BaseOrigen')
	DROP DATABASE DB_BaseOrigen
GO

IF EXISTS(select * from sys.databases where name='DB_BaseDestino')
	DROP DATABASE DB_BaseDestino
GO

CREATE DATABASE DB_BaseOrigen;
GO

CREATE DATABASE DB_BaseDestino;
GO

-------------------------------------------------------------------------------
----------------		CREACION DE TABLAS Y DATOS		-----------------------
-------------------------------------------------------------------------------

USE DB_BaseOrigen;
GO
CREATE SCHEMA Test;
GO

CREATE TABLE Test.Vehiculo (
	AutoID INT IDENTITY(1,1) NOT NULL,
	Modelo VARCHAR(30) NOT NULL,
	Marca VARCHAR(30) NOT NULL,
	CONSTRAINT PK_AutoID PRIMARY KEY (AutoID)
	);
GO
CREATE TABLE Test.Dueño (
	PersonaID INT IDENTITY(1,1) NOT NULL,
	Nombre VARCHAR(30) NOT NULL,
	Apellido VARCHAR(30) NOT NULL,
	AutoID INT NOT NULL,
	CONSTRAINT PK_PersonaID PRIMARY KEY (PersonaID),
	CONSTRAINT FK_AutoID FOREIGN KEY (AutoID) REFERENCES Test.Vehiculo(AutoID)
	);
GO


INSERT INTO Test.Vehiculo (Modelo, Marca) VALUES ('Gol','VW'),('Onix','Chevrolet'),('208','Peugeot'),('Civic','Honda'),('Clio','Renault');
GO
INSERT INTO Test.Dueño (Nombre, Apellido) VALUES ('Ezequiel','Sanson',1),('Nahuel','Saavedra',2),('Joel','Misterio',3),('Keko','Incognita',4),('Alexis','Quiensabe',5);
GO

USE DB_BaseDestino;
GO
CREATE SCHEMA Test;
GO

CREATE TABLE Test.Vehiculo (
	AutoID INT IDENTITY(1,1) NOT NULL,
	Modelo VARCHAR(30) NOT NULL,
	Marca VARCHAR(30) NOT NULL,
	CONSTRAINT PK_AutoID PRIMARY KEY (AutoID)
	);
GO


INSERT INTO Test.Vehiculo (Modelo, Marca) VALUES ('Gol','VW'),('Onix','Chevrolet'),('208','Peugeot'),('Civic','Honda'),('Clio','Renault');
GO


-------------------------------------------------------------------------------
--------------		CREACION DE VISTA PARA COMPARACION		-------------------
-------------------------------------------------------------------------------	

CREATE VIEW Test.v_Vehiculo AS SELECT * FROM Test.Vehiculo
GO

CREATE VIEW Test.v_Dueño AS SELECT * FROM Test.Dueño
GO

-------------------------------------------------------------------------------
------------		CREACION DE VARIABLES Y PROCEDIMIENTOS		---------------
-------------------------------------------------------------------------------

CREATE PROCEDURE sp_Compare(@BaseOrigen VARCHAR(30), @BaseDestino VARCHAR(30))
AS
	IF EXISTS(select * from sys.databases where name=@BaseOrigen)
		RAISERROR('NO SE ENCUENTRA LA BDD ORIGEN',16,1)
	ELSE IF EXISTS(select * from sys.databases where name=@BaseDestino)
		RAISERROR('NO SE ENCUENTRA LA BDD DESTINO',16,1)
	ELSE
	------------------------------------------------------------------------------------------------------------------
		BEGIN
			--DECLARE @BaseOrigen VARCHAR(30)= 'DB_BaseOrigen';
			--DECLARE @BaseDestino VARCHAR(30)= 'DB_BaseDestino';
			DECLARE @Nombre_Tabla VARCHAR(500);
			DECLARE @Nombre_Tabla2 VARCHAR(500);
			DECLARE @Nombre_Columna VARCHAR(500);

			DECLARE @SqlDinamico NVARCHAR(MAX)
			DECLARE @SqlDinamico2 NVARCHAR(MAX)
			DECLARE @SqlDinamico3 NVARCHAR(MAX)

			SET @SqlDinamico = 'DECLARE Table_Cursor CURSOR FOR SELECT name FROM '+@BaseOrigen+'.sys.tables';
			EXECUTE SP_EXECUTESQL @sqlDinamico;
				OPEN Table_Cursor;   
					FETCH NEXT FROM Table_Cursor INTO @Nombre_Tabla; 
					WHILE @@FETCH_STATUS = 0 
					BEGIN
							--SELECT @Nombre_Tabla;
							SET @SqlDinamico2 = 'DECLARE Table_Cursor2 CURSOR FOR SELECT name FROM '+@BaseDestino+'.sys.tables';
							EXECUTE SP_EXECUTESQL @sqlDinamico2;
							OPEN Table_Cursor2;   
								FETCH NEXT FROM Table_Cursor2 INTO @Nombre_Tabla2; 
								WHILE @@FETCH_STATUS = 0 
								BEGIN
									IF(@Nombre_Tabla = @Nombre_Tabla2)
										--SELECT @Nombre_Tabla2 as COINCIDENCIA
										BEGIN
											SET @SqlDinamico3 = 'DECLARE Table_Cursor3 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '+@Nombre_Tabla+'';
											EXECUTE SP_EXECUTESQL @sqlDinamico3;
											OPEN Table_Cursor3;   
												FETCH NEXT FROM Table_Cursor3 INTO @Nombre_Columna; 
												WHILE @@FETCH_STATUS = 0 
												BEGIN
													SELECT @Nombre_Columna;
													FETCH NEXT FROM Table_Cursor3 INTO @Nombre_Columna;
												END
											CLOSE Table_Cursor3;  
											DEALLOCATE Table_Cursor3;
							
											SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @Nombre_Tabla2;
										END
									ELSE
										SELECT @Nombre_Tabla AS SinCoincidencia1, @Nombre_Tabla2 AS SinCoincidencia2
									FETCH NEXT FROM Table_Cursor2 INTO @Nombre_Tabla2; 
								END
							CLOSE Table_Cursor2;  
							DEALLOCATE Table_Cursor2;

						 FETCH NEXT FROM Table_Cursor INTO @Nombre_Tabla;  
					END    
			CLOSE Table_Cursor;  
			DEALLOCATE Table_Cursor;
		END
		----------------------------------------------------------------------------------------
		
		
GO

-------------------------------------------------------------------------------
-----------------------		EJECUCION		-----------------------------------
-------------------------------------------------------------------------------

EXEC PROCEDURE sp_Compare 'DB_BaseOrigen', 'DB_BaseDestino';


select * from sys.databases;

SELECT * FROM TpBdd2Origen.sys.tables;

SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Vehiculo';

SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

