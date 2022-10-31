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
													SELECT @Nombre_Tabla , @Nombre_Tabla_Comp;
														--BEGIN
														--		--Indico de que tabla estamos hablando
														--		--SELECT @Nombre_Columna as ColumnaOrigen;
														--		--Por cada columna de la tabla, recorro las columnas de la tabla con el mismo nombre en la base destino
														--		SET @SqlDinamico4 = 'DECLARE Column_Cursor2 CURSOR FOR SELECT COLUMN_NAME,TABLE_NAME FROM '+@BaseDestino+'.INFORMATION_SCHEMA.COLUMNS';
														--		EXECUTE SP_EXECUTESQL @sqlDinamico4;
														--		OPEN Column_Cursor2;   
														--			FETCH NEXT FROM Column_Cursor2 INTO @Nombre_Columna2, @Nombre_Tabla_Comp2; 
														--			WHILE @@FETCH_STATUS = 0 
														--			BEGIN
														--				--Agrego el IF para que filtre solo las columnas de la tabla que estamos recorriendo inicialmente
														--				IF(@Nombre_Tabla = @Nombre_Tabla_Comp2)
														--					BEGIN
														--						--Agrego condicion para que haga algo si las columnas coinciden
														--						IF(@Nombre_Columna = @Nombre_Columna2)
														--							BEGIN
														--								SELECT 'COINCIDEN:',@Nombre_Columna2 as Columna_BD_Destino, @Nombre_Columna as Columna_BD_Origen;
														--								--Si tengo Coindicencia de tablas, ya no busco en el resto de registros(esto sirve por ahora, se puede modificar)
														--							END
														--						ELSE
														--							BEGIN
														--								SELECT 'NO COINCIDEN:',@Nombre_Columna2 as Columna_BD_Destino, @Nombre_Columna as Columna_BD_Origen,@Nombre_Tabla2 as tabla;
														--								SET @Borrar_Columna = 'ALTER TABLE ' + @BaseDestino + '.' + @Nombre_Tabla2 + ' DROP COLUMN ' + @Nombre_Columna2;
														--								EXECUTE SP_EXECUTESQL @Borrar_Columna;
														--							END
														--							FETCH NEXT FROM Column_Cursor INTO @Nombre_Columna,@Nombre_Tabla_Comp;
														--					END
														--				FETCH NEXT FROM Column_Cursor2 INTO @Nombre_Columna2,@Nombre_Tabla_Comp2;
														--			END
														--		CLOSE Column_Cursor2;  
														--		DEALLOCATE Column_Cursor2;

														--END
														ELSE 
														--Tengo que crear esta tabla en la bd_destino
																	USE DB_BaseDestino;
														--CREATE TABLE Due�o AS SELECT * FROM DB_BaseOrigen.Due�o NO ENCUENTRO EL SCHEMA
														--SELECT * INTO @Nombre_Tabla_Comp FROM [DB_BaseOrigen].Test.Due�o WHERE 1 = 0;
														SET @Crear_Tabla = 'CREATE TABLE IF NOT EXISTS ' + @BaseOrigen + '.' + @Nombre_Tabla_Comp + ' AS SELECT * FROM ' + @BaseOrigen + '.' + @Nombre_Tabla_Comp;
														SELECT @Crear_Tabla;
														--EXECUTE SP_EXECUTESQL @Crear_Tabla;
														--SELECT @Nombre_Tabla_Comp;
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


			--ALTER TABLE DB_BaseDestino.Vehiculo DROP COLUMN a�o;

			USE DB_BaseDestino;
			--CREATE TABLE Due�o AS SELECT * FROM DB_BaseOrigen.Due�o
			SELECT * INTO Due�o FROM [DB_BaseOrigen].Test.Due�o WHERE 1 = 0;

			DECLARE @nombreTabla varchar(50);
			SET @nombreTabla = (SELECT name FROM DB_BaseOrigen.sys.tables);
			SELECT @nombreTabla as NombreTabla;