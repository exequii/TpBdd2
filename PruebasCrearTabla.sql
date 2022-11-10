DECLARE @BaseOrigen VARCHAR(30)= 'DB_BaseOrigen';
DECLARE @BaseDestino VARCHAR(30)= 'DB_BaseDestino';
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

GO

DROP PROCEDURE sp_CompareTables

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
		SELECT @Query_Base_Destino
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

--fin SP

EXEC sp_CompareTables 'Due�o', 'DB_BaseOrigen' ,'DB_BaseDestino', 'Test'