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
CREATE TABLE Errores (
	Mensaje VARCHAR(MAX)
	);


INSERT INTO Test.Vehiculo (Modelo, Marca) VALUES ('Gol','VW'),('Onix','Chevrolet'),('208','Peugeot'),('Civic','Honda'),('Clio','Renault');
GO
INSERT INTO Test.Dueño (Nombre, Apellido,AutoID) VALUES ('Ezequiel','Sanson',1),('Nahuel','Saavedra',2),('Joel','Misterio',3),('Keko','Incognita',4),('Alexis','Quiensabe',5);
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
			DECLARE @Schema VARCHAR(500);
			declare @SchemaResult varchar(500) = '';
			DECLARE @Nombre_Columna VARCHAR(500);

			DECLARE @SqlDinamico NVARCHAR(MAX)
			DECLARE @SchemaQuery NVARCHAR(MAX);

			--recorre las tablas de la bd 1 
			SET @SqlDinamico = 'DECLARE Table_Cursor CURSOR FOR SELECT name FROM '+@BaseOrigen+'.sys.tables';
			EXECUTE SP_EXECUTESQL @sqlDinamico;
				OPEN Table_Cursor;   
					FETCH NEXT FROM Table_Cursor INTO @Nombre_Tabla; 
					WHILE @@FETCH_STATUS = 0 
					BEGIN
						--Guardo el Schema en una variable
						SET @SchemaQuery = N'SELECT @Schema = TABLE_SCHEMA FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ' + CHAR(39) + @Nombre_Tabla + CHAR(39);
						EXECUTE SP_EXECUTESQL @SchemaQuery, N'@Schema varchar(500) out', @SchemaResult out
						--Le paso las tablas para que compare las bases

						EXEC sp_CompareTables @Nombre_Tabla, @BaseOrigen, @BaseDestino, @SchemaResult

					FETCH NEXT FROM Table_Cursor INTO @Nombre_Tabla; 
					END
				CLOSE Table_Cursor;  
				DEALLOCATE Table_Cursor;
		END
GO
----------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
------------	CREACION DE PROCEDIMIENTO PARA COMPRAR TABLAS	---------------
-------------------------------------------------------------------------------
	
CREATE PROCEDURE sp_CompareTables @Nombre_Tabla VARCHAR(50),@BaseOrigen  VARCHAR(50), @BaseDestino VARCHAR(50), @Schema VARCHAR(50) = NULL
AS
DECLARE @Query_Base_Destino VARCHAR(50),
		@Tabla_Base_Destino NVARCHAR(MAX),
		@CursorColumnas NVARCHAR(MAX),
		@CrearTabla  NVARCHAR(MAX),
		@Tablas_Destino VARCHAR(50),
		@Nombre_Columna VARCHAR(50),
		@Tipo_Columna VARCHAR(50),
		@Longitud VARCHAR(50);
				
--Armo la query para ver si existe la tabla en la base destino (Hay que contemplar si tiene schema)
IF @Schema IS NULL
	BEGIN
		SET @Query_Base_Destino = 'SELECT * FROM ' + @BaseDestino + '.' + @Nombre_Tabla;
	END
ELSE 
	BEGIN
		SET @Query_Base_Destino = 'SELECT * FROM ' + @BaseDestino + '.' + @Schema + '.' + @Nombre_Tabla;
END

	BEGIN TRY 
		--Trato de ejecutar la query, si no existe devuelve error (pasa al bloque CATCH)
		EXEC SP_EXECUTESQL @Query_Base_Destino
		--Si existe hay que ejecutar procedimiento para comprobar que las columnas sean iguales
	END TRY
	BEGIN CATCH
		INSERT INTO Errores (mensaje) values ( 'La tabla ' + @Nombre_Tabla + ' no existe en ' + @BaseDestino)
		--Armo un cursor para recorrer los campos que tiene la tabla de la base origen 
		SET @CursorColumnas = 'DECLARE CursorColumnas CURSOR FOR SELECT COLUMN_NAME, DATA_TYPE,CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ' + CHAR(39) + @Nombre_Tabla + CHAR(39);
		PRINT 'USE ' + @BaseDestino;
		EXECUTE SP_EXECUTESQL @CursorColumnas;
		OPEN CursorColumnas;
			--Arma la query para crear tabla si no existe
			FETCH NEXT FROM CursorColumnas INTO @Nombre_Columna, @Tipo_Columna, @Longitud;
			--Chequeo si tiene Schema
			IF @Schema IS NULL
				BEGIN
					SET @CrearTabla = 'CREATE TABLE [' + @Nombre_Tabla + '] ( [' + @Nombre_Columna + '] [' + @Tipo_Columna + '],';
				END
			ELSE 
				BEGIN
					PRINT 'CREATE SCHEMA ' + @Schema;
					SET @CrearTabla = 'CREATE TABLE [' + @Schema +'].[' + @Nombre_Tabla + '] ( [' + @Nombre_Columna + '] [' + @Tipo_Columna + '],';
				END

			--Si el campo es int la longitud es null
			IF @Longitud IS NULL
				BEGIN
					PRINT @CrearTabla
				END
			ELSE 
				BEGIN
					PRINT @CrearTabla + ' (' + @Longitud + ')';
				END
			FETCH NEXT FROM CursorColumnas INTO @Nombre_Columna, @Tipo_Columna, @Longitud;
			WHILE @@FETCH_STATUS = 0 
			BEGIN
					SET @CrearTabla = '[' + @Nombre_Columna + '] [' + @Tipo_Columna + ']';
						IF @Longitud IS NULL
							BEGIN
								PRINT @CrearTabla + ','
							END
						ELSE 
								BEGIN
									PRINT @CrearTabla + ' (' + @Longitud + '),';
								END
			FETCH NEXT FROM CursorColumnas INTO @Nombre_Columna, @Tipo_Columna, @Longitud;
			END
		PRINT ');';
		CLOSE CursorColumnas;  
		DEALLOCATE CursorColumnas;
	END CATCH	
-------------------------------------------------------------------------------
-----------------------		EJECUCION		-----------------------------------
-------------------------------------------------------------------------------

--EXEC PROCEDURE sp_Compare 'DB_BaseOrigen', 'DB_BaseDestino';


select * from sys.databases;

SELECT * FROM DB_BaseDestino.sys.tables;
SELECT * FROM DB_BaseOrigen.sys.tables;

SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Vehiculo';

SELECT * FROM DB_BaseDestino.INFORMATION_SCHEMA.COLUMNS;

