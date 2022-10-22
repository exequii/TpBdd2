DECLARE @BaseOrigen VARCHAR(30)= 'DB_BaseOrigen';
DECLARE @BaseDestino VARCHAR(30)= 'DB_BaseDestino';
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
					




