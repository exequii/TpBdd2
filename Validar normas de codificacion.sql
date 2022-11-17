
CREATE PROCEDURE sp_VerificarNormasCodificacion @BaseOrigen VARCHAR(50)

AS

-- verifico el nombre de la base de datos

print ('Verificación de normas de codificación: ')
print ('Nombre de la base de datos: ' +@BaseOrigen)

IF @BaseOrigen COLLATE Latin1_General_CS_AS LIKE ('DB[_]%')
print ('El nombre cumple con las normas de codificación')
ELSE
print ('El nomnbre NO cumple con las normas de codificación')


-- verifico el nombre de las tablas con un cursor

DECLARE @CursorTablas NVARCHAR(MAX)
DECLARE @NombreTabla VARCHAR(500)
DECLARE @NombreSchema VARCHAR(500)
DECLARE @CursorCampos NVARCHAR(MAX)
DECLARE @CursorProcedimientos NVARCHAR(MAX)
DECLARE @CursorVistas NVARCHAR(MAX)
DECLARE @CursorConstraint NVARCHAR(MAX)
DECLARE @NombreCampo VARCHAR(500)
DECLARE @CursorUnique VARCHAR(500)
DECLARE @NombreUnique VARCHAR(500)

DECLARE @TablaIndexs TABLE(index_name VARCHAR(500),index_description VARCHAR(500),index_keys VARCHAR(500))


DECLARE @ValidarNotacionPascal VARCHAR(500)
DECLARE @ValidarNombreUnique VARCHAR(500)


				SET @CursorTablas = 'DECLARE Table_Cursor CURSOR FOR SELECT name FROM '+@BaseOrigen+'.sys.tables';
				EXECUTE SP_EXECUTESQL @CursorTablas;
				OPEN Table_Cursor;   
				FETCH NEXT FROM Table_Cursor INTO @NombreTabla; 
				WHILE @@FETCH_STATUS = 0 
				BEGIN

				SET @NombreSchema = (SELECT TABLE_SCHEMA FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = CHAR(39) + @NombreTabla + CHAR(39));

						SET @ValidarNotacionPascal = (dbo.f_Verificar_Notacion_Pascal (@NombreTabla))
						print ('Tabla: ' +@NombreTabla + ' | ' + @ValidarNotacionPascal)
					
						-- verifico el nombre de los campos con otro cursor

						SET @CursorCampos =  'DECLARE Campo_Cursor CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ' + CHAR(39) + @NombreTabla + CHAR(39);
						EXECUTE SP_EXECUTESQL @CursorCampos;
						OPEN Campo_Cursor;   
						FETCH NEXT FROM Campo_Cursor INTO @NombreCampo; 
						WHILE @@FETCH_STATUS = 0 
						BEGIN

						SET @ValidarNotacionPascal = (dbo.f_Verificar_Notacion_Pascal (@NombreCampo))
						print ('Campo: ' +@NombreCampo + ' | ' + @ValidarNotacionPascal)

						FETCH NEXT FROM Campo_Cursor INTO @NombreCampo; 
						END
						CLOSE Campo_Cursor;  
						DEALLOCATE Campo_Cursor;

						/*SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES 
						WHERE ROUTINE_TYPE = 'PROCEDURE'
					    ORDER BY ROUTINE_NAME*/

						-- sys.sp_helpindex me da los campos de los indices unique de una tabla, por eso guardo esa tabla en una variable del tipo tabla para luego recorrerlo con un cursor
						
						--INSERT INTO @TablaIndexs EXEC sys.sp_helpindex 'Test.Dueño' 
						--DECLARE Unique_Cursor CURSOR FOR SELECT index_name from @TablaIndexs
						--OPEN Unique_Cursor;   
						--FETCH NEXT FROM Unique_Cursor INTO @NombreUnique; 
						--WHILE @@FETCH_STATUS = 0 
						--BEGIN

						--IF @NombreUnique LIKE ('UQ[_]'++'')

						--FETCH NEXT FROM Unique_Cursor INTO @NombreUnique; 
						--END
						--CLOSE Unique_Cursor;  
						--DEALLOCATE Unique_Cursor;


				FETCH NEXT FROM Table_Cursor INTO @NombreTabla; 
				END
				CLOSE Table_Cursor;  
				DEALLOCATE Table_Cursor;

						SET @CursorProcedimientos =  'DECLARE Proc_Cursor CURSOR FOR SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE =''PROCEDURE'' ORDER BY ROUTINE_NAME';
						EXECUTE SP_EXECUTESQL @CursorProcedimientos;
						OPEN Proc_Cursor;  
						FETCH NEXT FROM Proc_Cursor INTO @NombreCampo; 
						WHILE @@FETCH_STATUS = 0 
						BEGIN

						SET @ValidarNotacionPascal = (dbo.f_verificar_procedures (@NombreCampo))
						print ('Proc: ' +@NombreCampo + ' | ' + @ValidarNotacionPascal)

						FETCH NEXT FROM Proc_Cursor INTO @NombreCampo; 
						END
						CLOSE Proc_Cursor;  
						DEALLOCATE Proc_Cursor;

						SET @CursorVistas =  'DECLARE View_Cursor CURSOR FOR SELECT name FROM sys.views';
						EXECUTE SP_EXECUTESQL @CursorVistas;
						OPEN View_Cursor;  
						FETCH NEXT FROM View_Cursor INTO @NombreCampo; 
						WHILE @@FETCH_STATUS = 0 
						BEGIN

						SET @ValidarNotacionPascal = (dbo.f_Verificar_Views (@NombreCampo))
						print ('View: ' +@NombreCampo + ' | ' + @ValidarNotacionPascal)

						FETCH NEXT FROM View_Cursor INTO @NombreCampo; 
						END
						CLOSE View_Cursor;  
						DEALLOCATE View_Cursor;

						SET @CursorConstraint = 'DECLARE Constraint_Cursor CURSOR FOR SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS';
						EXECUTE SP_EXECUTESQL @CursorConstraint;
						OPEN Constraint_Cursor;  
						FETCH NEXT FROM Constraint_Cursor INTO @NombreCampo; 
						WHILE @@FETCH_STATUS = 0 
						BEGIN

						SET @ValidarNotacionPascal = (dbo.f_Verificar_Constraint(@NombreCampo))
						print ('Key: ' +@NombreCampo + ' | ' + @ValidarNotacionPascal)

						FETCH NEXT FROM Constraint_Cursor INTO @NombreCampo; 
						END
						CLOSE Constraint_Cursor;  
						DEALLOCATE Constraint_Cursor;


-- Función que verifica si el nombre empieza con mayúscula y es singular

CREATE FUNCTION f_Verificar_Notacion_Pascal(@Nombre VARCHAR (500))
RETURNS VARCHAR(500)
AS
BEGIN
DECLARE @Respuesta VARCHAR(500)
--print SUBSTRING(@Nombre, 1,1) COLLATE SQL_Latin1_General_CP1_CS_AS;
IF SUBSTRING(@Nombre, 1,1) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(SUBSTRING(@Nombre, 1,1)) COLLATE SQL_Latin1_General_CP1_CS_AS AND SUBSTRING(@Nombre, LEN(@Nombre), 1) NOT IN ('s', 'S')
						SET @Respuesta = 'El nombre cumple con las normas de codificación'
						ELSE
						SET @Respuesta = 'El nombre NO cumple con las normas de codificación'
						RETURN @Respuesta + ' ' + SUBSTRING(@Nombre, 1,1) COLLATE SQL_Latin1_General_CP1_CS_AS;
END

CREATE FUNCTION f_Verificar_Procedures(@Proc VARCHAR (500))
RETURNS VARCHAR(500)
AS
BEGIN
DECLARE @Respuesta VARCHAR(500)
--print SUBSTRING(@Nombre, 1,1) COLLATE SQL_Latin1_General_CP1_CS_AS;
IF SUBSTRING(@Proc, 1,3) COLLATE SQL_Latin1_General_CP1_CS_AS in ('sp_', 'SP_','sP_','Sp_')
						SET @Respuesta = 'El procedimiento cumple con las normas de codificación'
						ELSE
						SET @Respuesta = 'El procedimiento NO cumple con las normas de codificación'
						RETURN @Respuesta;
END

CREATE FUNCTION f_Verificar_Views(@View VARCHAR (500))
RETURNS VARCHAR(500)
AS
BEGIN
DECLARE @Respuesta VARCHAR(500)
--print SUBSTRING(@Nombre, 1,1) COLLATE SQL_Latin1_General_CP1_CS_AS;
IF SUBSTRING(@View, 1,2) COLLATE SQL_Latin1_General_CP1_CS_AS in ('v_', 'V_')
						SET @Respuesta = 'La vista cumple con las normas de codificación'
						ELSE
						SET @Respuesta = 'La vista NO cumple con las normas de codificación'
						RETURN @Respuesta;
END

CREATE FUNCTION f_Verificar_Constraint(@Constraint VARCHAR (500))
RETURNS VARCHAR(500)
AS
BEGIN
DECLARE @Respuesta VARCHAR(500)
IF SUBSTRING(@Constraint, 1,3) COLLATE SQL_Latin1_General_CP1_CS_AS in ('pk_', 'PK_','fk_','FK_')
						SET @Respuesta = 'La key cumple con las normas de codificación'
						ELSE
						SET @Respuesta = 'La key NO cumple con las normas de codificación'
						RETURN @Respuesta;
END


--validar que no siga ejecutando si no existe la bbd
EXEC sp_VerificarNormasCodificacion 'DB_BaseOrigen'
EXEC sp_stored_procedures; 

SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Vehiculo'

select * from sys.key_constraints

SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS

SELECT CONSTRAINT_TYPE, CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_NAME = @NombreTabla AND CONSTRAINT_NAME =
SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME = 'Dueño' AND CONSTRAINT_NAME
