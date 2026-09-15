-- ============================================================
-- BASELINE: dbo.sp_consulta
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_consulta]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_consulta]  
(  
 @str varchar(100)    
)  
AS  
  

SET NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  
BEGIN  
     
 /* 'TABELAS' */  
 print '---------------------------- '  
 select distinct  
  sc.name  AS 'SCHEMA',  
  o.name  AS TABELAS  
  from sysobjects o  
  join sys.schemas sc  
    on (sc.schema_id = o.uid)  
 where type = 'U'  
   and o.name like ('%' + @str + '%')  
 order by o.name  
 print ' '  
      
  
 /* 'NOME PROCEDURES' */  
 print '---------------------------- '  
 select distinct  
  sc.name  AS 'SCHEMA',  
  o.name  AS NOME_PROCEDURE  
  from sysobjects o  
  join sys.schemas sc  
    on (sc.schema_id = o.uid)  
 where type = 'P'  
   and o.name like ('%' + @str + '%')  
 order by o.name  
 print ' '  
  
    
 /* 'NOME DE VIEWS' */  
 print '---------------------------- '  
 select distinct  
  sc.name  AS 'SCHEMA',  
  o.name  AS NOME_VIEWS  
  from sysobjects o  
  join sys.schemas sc  
    on (sc.schema_id = o.uid)  
 where type = 'V'  
   and o.name like ('%' + @str + '%')  
 order by o.name  
 print ' '  
    
  
 /* 'CONTEUDO DE VIEWS' */  
 print '---------------------------- '  
 select distinct  
  sc.name  AS 'SCHEMA',  
  o.name  AS CONTEUDO_VIEWS  
  from sysobjects o  
  join syscomments c  
    on (c.id = o.id)  
  join sys.schemas sc  
    on (sc.schema_id = o.uid)  
 where o.type = 'V'  
   and c.text like ('%' + @str + '%')  
 order by o.name  
 print ' '  
    
      
 /* 'CONTEUDO PROCEDURES' */  
 print '---------------------------- '  
 select distinct  
  sc.name  AS 'SCHEMA',  
  o.name  AS CONTEUDO_PROCEDURES  
  from sysobjects o  
  join syscomments c  
    on (c.id = o.id)  
  join sys.schemas sc  
    on (sc.schema_id = o.uid)  
 where o.type = 'P'  
   and c.text like ('%' + @str + '%')  
 order by o.name  
 print ' '  
  
  
 /* 'CONTEUDO FUNCTIONS' */  
 print '---------------------------- '  
 select distinct  
  sc.name  AS 'SCHEMA',  
  o.name  AS CONTEUDO_FUNCTIONS  
  from sysobjects o  
  join syscomments c  
    on (c.id = o.id)  
  join sys.schemas sc  
    on (sc.schema_id = o.uid)  
 where o.type = 'FN'  
   and c.text like ('%' + @str + '%')  
 order by o.name  
 print ' '  
    
  
 /* 'TRIGGERS' */  
 print '---------------------------- '  
 select distinct  
  sc.name  AS 'SCHEMA',  
  o.name  AS TRIGGERS  
  from sysobjects o  
  join sys.schemas sc  
    on (sc.schema_id = o.uid)  
 where type = 'TR'  
   and o.name like ('%' + @str + '%')  
 order by o.name  
 print ' '  
      
  
 /* 'CAMPOS' */  
 print '---------------------------- '  
 select  
  convert(varchar(30), c.name) AS CAMPO,  
  sc.name       AS 'SCHEMA',  
  t.name       AS TABELA  
  from sysobjects t  
  join syscolumns c  
    on (t.id = c.id)  
  join sys.schemas sc  
    on (sc.schema_id = t.uid)  
 where t.type = 'U'  
   and c.name like ('%' + @str + '%')  
 order by t.name  
 print ' '  
  
  
  /*'JOBS' */  
  
 end
GO
