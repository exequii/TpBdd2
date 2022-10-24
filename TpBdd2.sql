
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
			DECLARE @Nombre_Tabla_Comp VARCHAR(500);
			DECLARE @Nombre_Columna VARCHAR(500);
			DECLARE @Nombre_Tabla_Comp2 VARCHAR(500);
			DECLARE @Nombre_Columna2 VARCHAR(500);
			

			DECLARE @SqlDinamico NVARCHAR(MAX)
			DECLARE @SqlDinamico2 NVARCHAR(MAX)
			DECLARE @SqlDinamico3 NVARCHAR(MAX)
			DECLARE @SqlDinamico4 NVARCHAR(MAX)

			--El Table_Cursor recorre las tablas de la base origen.
			SET @SqlDinamico = 'DECLARE Table_Cursor CURSOR FOR SELECT name FROM '+@BaseOrigen+'.sys.tables';
			EXECUTE SP_EXECUTESQL @sqlDinamico;
				OPEN Table_Cursor;   
					FETCH NEXT FROM Table_Cursor INTO @Nombre_Tabla; 
					WHILE @@FETCH_STATUS = 0 
					BEGIN
							--Menciono Cada Tabla
							SELECT @Nombre_Tabla AS Tabla_Bd_Origen;
							--Por Cada tabla de la BD_ORIGEN, genero un Cursor que recorra las tablas de la base destino buscando una que se llame igual
							SET @SqlDinamico2 = 'DECLARE Table_Cursor2 CURSOR FOR SELECT name FROM '+@BaseDestino+'.sys.tables';
							EXECUTE SP_EXECUTESQL @sqlDinamico2;
							OPEN Table_Cursor2;   
								FETCH NEXT FROM Table_Cursor2 INTO @Nombre_Tabla2; 
								WHILE @@FETCH_STATUS = 0 
								BEGIN
									IF(@Nombre_Tabla = @Nombre_Tabla2)
									--Si encuentra en la BD origen y en la destino dos tablas que se llamen igual
										BEGIN
											--Por cada Tabla que Genera este Cursor para recorrer las COLUMNAS de la tabla ORIGEN
											SET @SqlDinamico3 = 'DECLARE Column_Cursor CURSOR FOR SELECT COLUMN_NAME,TABLE_NAME FROM '+@BaseOrigen+'.INFORMATION_SCHEMA.COLUMNS';
											EXECUTE SP_EXECUTESQL @sqlDinamico3;
											OPEN Column_Cursor;   
												FETCH NEXT FROM Column_Cursor INTO @Nombre_Columna, @Nombre_Tabla_Comp; 
												WHILE @@FETCH_STATUS = 0 
												BEGIN
													--Le agrego un if para que solo entre si estamos hablando de las columnas que de la tabla que estamos recorriendo
													IF(@Nombre_Tabla = @Nombre_Tabla_Comp)
														BEGIN
																--Indico de que tabla estamos hablando
																--SELECT @Nombre_Columna as ColumnaOrigen;
																--Por cada columna de la tabla, recorro las columnas de la tabla con el mismo nombre en la base destino
																SET @SqlDinamico4 = 'DECLARE Column_Cursor2 CURSOR FOR SELECT COLUMN_NAME,TABLE_NAME FROM '+@BaseDestino+'.INFORMATION_SCHEMA.COLUMNS';
																EXECUTE SP_EXECUTESQL @sqlDinamico4;
																OPEN Column_Cursor2;   
																	FETCH NEXT FROM Column_Cursor2 INTO @Nombre_Columna2, @Nombre_Tabla_Comp2; 
																	WHILE @@FETCH_STATUS = 0 
																	BEGIN
																		--Agrego el IF para que filtre solo las columnas de la tabla que estamos recorriendo inicialmente
																		IF(@Nombre_Tabla = @Nombre_Tabla_Comp2)
																			BEGIN
																				--Agrego condicion para que haga algo si las columnas coinciden
																				IF(@Nombre_Columna = @Nombre_Columna2)
																					BEGIN
																						SELECT 'COINCIDEN:',@Nombre_Columna2 as Columna_BD_Destino, @Nombre_Columna as Columna_BD_Origen;
																						FETCH NEXT FROM Column_Cursor INTO @Nombre_Columna,@Nombre_Tabla_Comp;
																						--Si tengo Coindicencia de tablas, ya no busco en el resto de registros(esto sirve por ahora, se puede modificar)
																					END
																				ELSE
																					BEGIN
																						SELECT 'NO COINCIDEN:',@Nombre_Columna2 as Columna_BD_Destino, @Nombre_Columna as Columna_BD_Origen;
																					END
																			END
																		FETCH NEXT FROM Column_Cursor2 INTO @Nombre_Columna2,@Nombre_Tabla_Comp2;
																	END
																CLOSE Column_Cursor2;  
																DEALLOCATE Column_Cursor2;

														END
													FETCH NEXT FROM Column_Cursor INTO @Nombre_Columna,@Nombre_Tabla_Comp;
												END
											CLOSE Column_Cursor;  
											DEALLOCATE Column_Cursor;
							
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
GO
----------------------------------------------------------------------------------------------------
		
		


-------------------------------------------------------------------------------
-----------------------		EJECUCION		-----------------------------------
-------------------------------------------------------------------------------

EXEC PROC sp_Compare 'DB_BaseOrigen', 'DB_BaseDestino';


select * from sys.databases;

SELECT * FROM TpBdd2Origen.sys.tables;

SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Vehiculo';

SELECT * FROM DB_BaseDestino.INFORMATION_SCHEMA.COLUMNS;

