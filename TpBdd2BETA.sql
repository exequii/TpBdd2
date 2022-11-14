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
	Color VARCHAR(30) NOT NULL,
	Puertas VARCHAR(30),
	rueda VARCHAR(30),
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
CREATE TABLE Test.Error (
	ErrorID INT IDENTITY(1,1),
	Mensaje VARCHAR(MAX),
	CONSTRAINT PK_ErrorID PRIMARY KEY (ErrorID),
	);


INSERT INTO Test.Vehiculo (Modelo, Marca,Color) VALUES ('Gol','VW','Rojo'),('Onix','Chevrolet','Rojo'),('208','Peugeot','Rojo'),('Civic','Honda','Rojo'),('Clio','Renault','Rojo');
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
------------	CREACION DE PROCEDIMIENTO PARA COMPARAR CAMPOS	---------------
-------------------------------------------------------------------------------

USE DB_BaseOrigen;

GO

CREATE PROCEDURE sp_CompararCampos @Nombre_Tabla VARCHAR(50), @BaseDestino VARCHAR(50), @SchemaDestino VARCHAR(50) = NULL
AS
DECLARE @CursorCampos NVARCHAR(MAX),
		@QueryTableData NVARCHAR(MAX),
		@QueryBaseDestino NVARCHAR(MAX),
		@QueryCampoEnDEstino NVARCHAR(MAX),
		@Nombre_Campo VARCHAR(50),
		@Tipo_Campo VARCHAR(50),
		@Longitud VARCHAR(50),
		@Schema VARCHAR(50);

SET @CursorCampos = 'DECLARE CursorCampos CURSOR FOR SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, TABLE_SCHEMA FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ' + CHAR(39) + @Nombre_Tabla + CHAR(39);
EXECUTE SP_EXECUTESQL @CursorCampos;
	OPEN CursorCampos;
		FETCH NEXT FROM CursorCampos INTO @Nombre_Campo, @Tipo_Campo, @Longitud,@Schema;
		IF (@Schema IS NULL)
			BEGIN
			SET @QueryBaseDestino = @BaseDestino + '.' + @Nombre_Tabla;
			END
		ELSE 
			BEGIN
				SET @QueryBaseDestino = @BaseDestino + '.' + @Schema + '.' + @Nombre_Tabla;
			END
		WHILE @@FETCH_STATUS = 0 
		--Si encuentra la modifica,sino pasa al catch
		BEGIN TRY
			SET @QueryCampoEnDEstino = 'SELECT ' + @Nombre_Campo + ' FROM ' + @QueryBaseDestino
			EXECUTE SP_EXECUTESQL @QueryCampoEnDEstino;
			--PRINT 'EL campo ' + @Nombre_Campo + ' ya existe en ' + @BaseDestino
		FETCH NEXT FROM CursorCampos INTO @Nombre_Campo, @Tipo_Campo, @Longitud,@Schema;
		END	TRY
		BEGIN CATCH
		INSERT INTO DB_BaseOrigen.Test.Error (mensaje) values ( 'El campo ' + @Nombre_Campo + ' no existe en ' + @Nombre_Tabla)
		PRINT ('USE ' + @BaseDestino)
		IF (@Longitud IS NULL)
			BEGIN
				PRINT 'ALTER TABLE ' + @QueryBaseDestino + 'ADD ' + @Nombre_Campo + ' ' + @Tipo_Campo;
			END
		ELSE 
			BEGIN
				PRINT 'ALTER TABLE ' + @QueryBaseDestino + ' ADD ' + @Nombre_Campo + ' ' + @Tipo_Campo + ' ( ' + @Longitud + ' )';
			END
			FETCH NEXT FROM CursorCampos INTO @Nombre_Campo, @Tipo_Campo, @Longitud,@Schema;
		END CATCH
	CLOSE CursorCampos;  
	DEALLOCATE CursorCampos;

GO



-------------------------------------------------------------------------------
------------	CREACION DE PROCEDIMIENTO PARA COMPARAR TABLAS	---------------
-------------------------------------------------------------------------------

USE DB_BaseOrigen;	

GO

CREATE PROCEDURE sp_CompareTables @Nombre_Tabla VARCHAR(50),@BaseOrigen  VARCHAR(50), @BaseDestino VARCHAR(50), @Schema VARCHAR(50) = NULL
AS
DECLARE @Query_Base_Destino NVARCHAR(MAX),
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
		EXEC sp_CompararCampos @Nombre_Tabla, @BaseDestino, @Schema
	END TRY
	BEGIN CATCH
		--INSERT INTO Errores (mensaje) values ( 'La tabla ' + @Nombre_Tabla + ' no existe en ' + @BaseDestino)
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
			--VERIFICAR SI PRIMERO EXISTE EL ESQUEMA EN LA BD DESTINO. SI NO HAY QUE CREARLO
				IF(@Schema  IS NOT NULL)
					BEGIN
						DECLARE @Exists Nvarchar(max)
						DECLARE @CANTIDAD INT
								--BUSCAMOS EN LA BD DESTINO SI EXISTE EL ESQUEMA(PARA CREARLO O USARLO)	
								SET @Exists= 	'SELECT @CANT=COUNT(*) FROM ' + @BaseDestino + '.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA ='''+ @Schema +''' ';					
								EXECUTE SP_EXECUTESQL @Exists,N'@CANT INT OUTPUT',@CANT=@CANTIDAD OUTPUT	
					END
				--SI EL RESULT ES= 0 SE DEBE CREAR EL ESQUEMA
				IF( @CANTIDAD = 0 )
					BEGIN
						PRINT 'CREATE SCHEMA ' + @Schema;
						SET @CrearTabla = 'CREATE TABLE [' + @Schema +'].[' + @Nombre_Tabla + '] ( [' + @Nombre_Columna + '] [' + @Tipo_Columna + '],';
					END
				ELSE
					BEGIN
					--SI EL RESULT ES>0 SE DEBE CREAR LA TABLA CON EL ESQUEMA EXISTENTE
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
GO


-------------------------------------------------------------------------------
------------		CREACION DE VARIABLES Y PROCEDIMIENTOS		---------------
-------------------------------------------------------------------------------
USE DB_BaseOrigen;

GO

CREATE PROCEDURE sp_Compare(@BaseOrigen VARCHAR(30), @BaseDestino VARCHAR(30))
AS

SET NOCOUNT ON


	IF NOT EXISTS(select * from sys.databases where name=@BaseOrigen)
		RAISERROR('NO SE ENCUENTRA LA BDD ORIGEN',16,1)
	ELSE IF NOT EXISTS(select * from sys.databases where name=@BaseDestino)
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


-------------------------------------------------------------------------------
-----------------------		EJECUCION		-----------------------------------
-------------------------------------------------------------------------------

EXEC  sp_Compare 'DB_BaseOrigen', 'DB_BaseDestino';









--EXEC sp_CompararCampos 'Vehiculo', 'DB_BaseDestino', 'Test'

--TABLA QUE VERIFICA QUE ES UN ESQUEMA DIFERENTE Q NO EXISTE EN LA BD DE DESTINO
USE DB_BaseOrigen;
CREATE SCHEMA TEST2;
CREATE TABLE [TEST2].[AUTO] ( [AutoID] [int],
[Modelo] [varchar] (30),
[Marca] [varchar] (30),
[Color] [varchar] (30),
);

select * from sys.databases;

SELECT * FROM DB_BaseDestino.sys.tables;
SELECT * FROM DB_BaseOrigen.sys.tables;

SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Vehiculo';
SELECT * FROM DB_BaseOrigen.INFORMATION_SCHEMA.COLUMNS;
SELECT * FROM DB_BaseDestino.INFORMATION_SCHEMA.COLUMNS;
 SELECT TABLE_SCHEMA FROM DB_BaseDestino.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo';

 SELECT COUNT(*) FROM DB_BaseDestino.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'Test';

 DECLARE @query NVARCHAR(500) = ('SELECT * FROM DB_BaseDestino.Test.Vehiculo')
 EXEC SP_EXECUTESQL @query





 --esto iria adentro del catch de compararCampos

 DECLARE @constraint_type VARCHAR(50)
 DECLARE @constraint_name VARCHAR(50)
 DECLARE @name VARCHAR(50) = 'PK_PersonaID'

 DECLARE cursorConstraint CURSOR FOR SELECT CONSTRAINT_TYPE, CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME = 'Dueño'
 OPEN cursorConstraint
 FETCH NEXT FROM cursorConstraint INTO @constraint_type, @constraint_name;
 WHILE @@FETCH_STATUS = 0 
 BEGIN

 PRINT ('ADD ' + @Nombre_Campo + ' ' + @Tipo_Campo)

 IF @constraint_type = 'PRIMARY KEY'
 PRINT ('ADD CONSTRAINT'+ @name +'PRIMARY KEY (' + @name +')');

 IF @constraint_type = 'FOREING KEY'
   PRINT ('ADD CONSTRAINT'+ @name +'PRIMARY KEY (' + @name +')');

  FETCH NEXT FROM cursorConstraint INTO @constraint_type, @constraint_name;
 END
 CLOSE cursorConstraint
 DEALLOCATE cursorConstraint





 