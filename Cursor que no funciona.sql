								DECLARE @Nombre_Tabla NVARCHAR(500)=N'Vehiculo';
								DECLARE @SqlDinamico3 NVARCHAR(MAX)
								DECLARE @Nombre_Columna VARCHAR(500);
								DECLARE @Nombre_TablaComp VARCHAR(500);
								DECLARE @BaseDestino VARCHAR(500)='DB_BaseDestino';

								SET @SqlDinamico3 = 'DECLARE Table_Cursor3 CURSOR FOR SELECT COLUMN_NAME,TABLE_NAME FROM '+@BaseDestino+'.INFORMATION_SCHEMA.COLUMNS';
								EXECUTE SP_EXECUTESQL @sqlDinamico3;
								OPEN Table_Cursor3;   
									FETCH NEXT FROM Table_Cursor3 INTO @Nombre_Columna, @Nombre_TablaComp; 
									WHILE @@FETCH_STATUS = 0 
									BEGIN
										--SELECT @Nombre_Columna,@Nombre_TablaComp;
										IF(@Nombre_Tabla = @Nombre_TablaComp)
											SELECT @Nombre_Columna;
										FETCH NEXT FROM Table_Cursor3 INTO @Nombre_Columna, @Nombre_TablaComp;
									END
								CLOSE Table_Cursor3;  
								DEALLOCATE Table_Cursor3;

								
								 WHERE TABLE_NAME LIKE '+@Nombre_Tabla+'
								'''+@Nombre_Tabla+'''
							DECLARE @Nombre_Tabla2 VARCHAR(500)='Vehiculo';
							SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''+'@Nombre_Tabla2'+'';
							SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Vehiculo';
							SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'Vehiculo';

							SET @SqlDinamico3 = 'DECLARE Table_Cursor3 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '+@Nombre_Tabla+'';
							SELECT 'DECLARE Table_Cursor3 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '+@Nombre_Tabla+'';