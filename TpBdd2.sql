



SELECT * FROM TpBdd2Origen.sys.all_columns;
SELECT * FROM TpBdd2Origen.sys.all_objects;
SELECT * FROM TpBdd2Origen.sys.objects;
SELECT * FROM TpBdd2Origen.sys.schemas;
SELECT * FROM TpBdd2Origen.sys.system_columns;


SELECT * FROM TpBdd2Origen.sys.tables;
SELECT * FROM Personas;
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Personas';




--SELECT
--       (SELECT TOP 1
--           name
--      FROM TestDB2.sys.schemas WHERE
--           schema_id
--           =
--           D1O.schema_id) AS Schema_Name,
--       D1O.name AS Object_Name
--  FROM
--       TestDB2.sys.syscomments D1C
--       INNER JOIN TestDB2.sys.objects D1O
--       ON
--       D1O.object_id
--       =
--       D1C.id
--       INNER JOIN TestDB.sys.objects D2O
--       ON
--       D1O.name
--       =
--       D2O.name
--       INNER JOIN TestDB.sys.syscomments D2C
--       ON
--       D2O.object_id
--       =
--       D2C.id
--WHERE
--       D1C.text
--       <>
--       D2C.text;