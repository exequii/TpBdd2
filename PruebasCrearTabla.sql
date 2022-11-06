DECLARE @BaseOrigen VARCHAR(30)= 'DB_BaseOrigen';
DECLARE @BaseDestino VARCHAR(30)= 'DB_BaseDestino';
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
			DECLARE @Borrar_Columna NVARCHAR(MAX)
			DECLARE @Crear_Tabla NVARCHAR(MAX)

			DECLARE @CompareTables NVARCHAR(MAX),@CrearTabla NVARCHAR(MAX), @Nombre_Tabla_Destino VARCHAR(500)

--recorre las tablas de la bd 1 
SET @SqlDinamico = 'DECLARE Table_Cursor CURSOR FOR SELECT name FROM '+@BaseOrigen+'.sys.tables';
			EXECUTE SP_EXECUTESQL @sqlDinamico;
				OPEN Table_Cursor;   
					FETCH NEXT FROM Table_Cursor INTO @Nombre_Tabla; 
					WHILE @@FETCH_STATUS = 0 
					BEGIN
						--Le paso las tablas para que compare las bases
						EXEC sp_CompareTables @Nombre_Tabla, @BaseOrigen, @BaseDestino

					FETCH NEXT FROM Table_Cursor INTO @Nombre_Tabla; 
					END
			CLOSE Table_Cursor;  
			DEALLOCATE Table_Cursor;

GO

DROP PROCEDURE sp_CompareTables

CREATE PROCEDURE sp_CompareTables @Nombre_Tabla VARCHAR(50),@BaseOrigen  VARCHAR(50), @BaseDestino VARCHAR(50)
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
SET @Query_Base_Destino = 'SELECT ' + @Nombre_Tabla + ' FROM ' + @BaseDestino + '.sys.tables';
	BEGIN TRY 
		--Trato de ejecutar la query, si no existe devuelve error (pasa al bloque CATCH)
		SELECT @Query_Base_Destino
		EXEC SP_EXECUTESQL @Query_Base_Destino
		--Si existe hay que ejecutar procedimiento para comprobar que las columnas sean iguales
	END TRY
	BEGIN CATCH
		--Armo un cursor para recorrer los campos que tiene la tabla de la base origen 
		SET @CursorColumnas = N'DECLARE CursorColumnas CURSOR FOR SELECT COLUMN_NAME, DATA_TYPE,CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ' + CHAR(39) + @Nombre_Tabla + CHAR(39);
		SELECT @CursorColumnas
		EXECUTE SP_EXECUTESQL @CursorColumnas;
		OPEN CursorColumnas;
			--Intento armar la query para crear la tabla (por el momento no crea
			FETCH NEXT FROM CursorColumnas INTO @Nombre_Columna, @Tipo_Columna, @Longitud;
			EXECUTE SP_EXECUTESQL @CrearTabla;
			WHILE @@FETCH_STATUS = 0 
			BEGIN
				SELECT @Nombre_Columna, @Tipo_Columna, @Longitud;
				SET @CrearTabla = N'CREATE TABLE  [' + @BaseDestino + '].[' + @Nombre_Tabla + '] ( [' + @Nombre_Columna + ' ' + @Tipo_Columna + ' ' + @Longitud + '] )';
				SELECT @CrearTabla;
			FETCH NEXT FROM CursorColumnas INTO @Nombre_Columna, @Tipo_Columna, @Longitud;
			END
		CLOSE CursorColumnas;  
		DEALLOCATE CursorColumnas;
	END CATCH



EXEC sp_CompareTables 'Dueño', 'DB_BaseOrigen' ,'DB_BaseDestino'

SELECT Dueño FROM DB_BaseDestino.sys.tables

CREATE TABLE [Test].[Dueño](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,)
SELECT INTO DB_BaseDestino.Dueño FROM SELECT * FROM DB_BaseOrigen.Dueño)


INSERT INTO DB_BaseDestino.Dueño (SELECT * FROM DB_BaseOrigen.Dueño)

SELECT * FROM DB_BaseDestino.Test.Vehiculo

ALTER TABLE DB_BaseDestino.Test.Vehiculo ADD status varchar(1);

SELECT CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Vehiculo';

DECLARE CursorColumnas CURSOR FOR SELECT COLUMN_NAME, DATA_TYPE,CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = Dueño

CREATE TABLE  [DB_BaseDestino].[Dueño] ( [Nombre] [varchar] (30) )
