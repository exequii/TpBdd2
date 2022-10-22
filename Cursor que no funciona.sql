								DECLARE @Nombre_Tabla NVARCHAR(500)=N'Vehiculo';
								DECLARE @SqlDinamico3 NVARCHAR(MAX)
								DECLARE @Nombre_Columna VARCHAR(500);
								SET @SqlDinamico3 = 'DECLARE Table_Cursor3 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = "'+@Nombre_Tabla+'"';
								EXECUTE SP_EXECUTESQL @sqlDinamico3,@Nombre_Tabla;
								OPEN Table_Cursor3;   
									FETCH NEXT FROM Table_Cursor3 INTO @Nombre_Columna; 
									WHILE @@FETCH_STATUS = 0 
									BEGIN
										--SELECT @Nombre_Columna;
										FETCH NEXT FROM Table_Cursor3 INTO @Nombre_Columna;
									END
								CLOSE Table_Cursor3;  
								DEALLOCATE Table_Cursor3;

								

								'''+@Nombre_Tabla+'''
							DECLARE @Nombre_Tabla2 VARCHAR(500)='Vehiculo';
							SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = Vehiculo;
							SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Vehiculo';
							SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'Vehiculo';

							SET @SqlDinamico3 = 'DECLARE Table_Cursor3 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '+@Nombre_Tabla+'';
							SELECT 'DECLARE Table_Cursor3 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '+@Nombre_Tabla+'';