drop database dbtest01;
drop database dbtest02;

CREATE DATABASE dbtest01
GO
USE dbtest01
GO

CREATE TABLE [dbo].[article] ([id] [nchar](10) NOT NULL, [type] [nchar](10) NULL, [cost] [nchar](10) NULL,
  CONSTRAINT [PK_article] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT INTO [dbo].[article]
  VALUES ('001', '1', '40'),
  ('002', '2', '80'),
  ('003', '3', '120')
GO

CREATE DATABASE dbtest02
GO
USE dbtest02
GO

CREATE TABLE [dbo].[article] ([id] [nchar](10) NOT NULL, [type] [nchar](10) NULL, [cost] [nchar](10) NULL,
  CONSTRAINT [PK_article] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT INTO [dbo].[article]
  VALUES ('001', '1', '40'),
  ('002', '2', '80'),
  ('003', '3', '120'),
  ('004', '4', '160')
GO

SELECT * FROM dbtest02.dbo.article
EXCEPT
SELECT * FROM dbtest01.dbo.article

USE dbtest02
GO

CREATE TABLE [dbo].[article5](
 [id] [int] NOT NULL,
 [type] nchar(10) NULL,
 [cost] nchar(10) NULL,
 extra1 int,
 extra2 int
)

USE dbtest01
GO

select * FROM [INFORMATION_SCHEMA].[COLUMNS];


--devuelve las diferencias de tabla entre una y otra
SELECT 'dbtest01' AS dbname, t1.table_name
FROM dbtest01.[INFORMATION_SCHEMA].[tables] t1
WHERE table_name NOT IN 
     ( SELECT t2.table_name
       FROM dbtest02.[INFORMATION_SCHEMA].[tables] t2
     )
UNION
SELECT 'dbtest02' AS dbname, t1.table_name
FROM dbtest02.[INFORMATION_SCHEMA].[tables] t1
WHERE table_name NOT IN 
     ( SELECT t2.table_name
       FROM dbtest01.[INFORMATION_SCHEMA].[tables] t2
     )


	 --devuelve la diferencia de columnas de la db01 sobre la db02
WITH dbtest01 AS (
    SELECT objects.name AS TBL, columns.name AS COL
    FROM       dbtest01.sys.objects 
    INNER JOIN dbtest01.sys.columns ON objects.object_id = columns.object_id
    WHERE objects.type = 'U' -- user table
), dbtest02 AS (
    SELECT objects.name AS TBL, columns.name AS COL
    FROM       dbtest02.sys.objects 
    INNER JOIN dbtest02.sys.columns ON objects.object_id = columns.object_id
    WHERE objects.type = 'U' -- user table
)
SELECT dbtest01.TBL, dbtest01.COL
FROM dbtest01
LEFT JOIN dbtest02 ON dbtest01.TBL = dbtest02.TBL and dbtest01.COL = dbtest02.COL
WHERE dbtest02.TBL IS NULL


--devuelve las tablas que hay en la bd01 y que no están en la bd02, junto con sus columnas
select isnull(db1.table_name, db2.table_name) as [table],
       isnull(db1.column_name, db2.column_name) as [column],
       db1.column_name as database1, 
       db2.column_name as database2
from
(select schema_name(tab.schema_id) + '.' + tab.name as table_name, 
       col.name as column_name
   from [dbtest01].sys.tables as tab
        inner join [dbtest01].sys.columns as col
            on tab.object_id = col.object_id) db1
full outer join
(select schema_name(tab.schema_id) + '.' + tab.name as table_name, 
       col.name as column_name
   from [dbtest02].sys.tables as tab
        inner join [dbtest02].sys.columns as col
            on tab.object_id = col.object_id) db2
on db1.table_name = db2.table_name
and db1.column_name = db2.column_name
where (db1.column_name is null or db2.column_name is null)
order by 1, 2, 3