-- ============================================================
-- BASELINE: dbo.Usp_AlarmeRotasProcessadasComErroGB
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeRotasProcessadasComErroGB]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_AlarmeRotasProcessadasComErroGB]  
  
as  
  
 set nocount on  
  
 drop table if exists #aux  
 
select *
into  #aux
from (
    SELECT 

     cmt_cd_coleta
    ,cmt_cd_transportadora	
    ,cmt_cd_servicecenter
    ,cmt_dh_referencia
    ,cmt_dh_escrita
    ,cmt_in_erro
    ,ROW_NUMBER()  over( partition by cmt_cd_transportadora,cmt_cd_servicecenter  order by  cmt_cd_coleta desc) num
    FROM 
    db_Irisys_Json.dbo.tb_ml_coleta_totalizador c1 WITH (NOLOCK)
    where 1=1
      AND c1.cmt_dh_escrita <= DATEADD(HOUR, -1, GETDATE())
      and cast(c1.cmt_dh_escrita as date) >=  cast(getdate()-1 as date)
    and cmt_in_processado = 1
    --and cmt_cd_servicecenter = 'SPR2'
) as a
where num = 1
and cmt_in_erro = 1

 --select  
 -- cmt_cd_coleta,  
 -- cmt_cd_transportadora,  
 -- cmt_cd_servicecenter  
 -- --into #aux  
 --from  
 -- db_Irisys_Json.dbo.tb_ml_coleta_totalizador with(nolocK)  
 --where   
 -- cmt_in_erro = 1  
 -- and cmt_dh_escrita  <= DATEADD(HOUR, -2, GETDATE())
  
  
 if exists (select * from #aux)  
 begin  
  declare @mensagem varchar(2000)  
    
   
   
  set @mensagem = '*[Rotas com erro]*' + CHAR(10)  
  + 'Existem rotas que foram processadas com erro. Verifique a tabela db_Irisys_Json.dbo.tb_ml_coleta_totalizador'  
  
   RAISERROR(@mensagem, 16, 1);  
  
 end  
  
GO
