-- ============================================================
-- BASELINE: dbo.UspLoadDraHistPerfMinuto
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspLoadDraHistPerfMinuto]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspLoadDraHistPerfMinuto]

as

delete from tb_dra_hist_perf_minuto where DataReferencia = dateadd(day,-1,cast(getdate() as date))

insert into tb_dra_hist_perf_minuto

select dateadd(day,-1,cast(getdate() as date)) as DataReferencia,
	   isnull(execucoes.DataHora,erros.DataHora) as Intervalo,
	   isnull(execucoes.Quantidade,0) as Quantidade,
	   isnull(execucoes.Online,0) as Online,
	   isnull(execucoes.Historico,0) as Historico,
       isnull(erros.qtde,0) as TotalErros,  
       isnull(erros.Erro_401,0) as Erro_401,  
       isnull(erros.Erro_403,0) as Erro_403,  
       isnull(erros.Erro_404,0) as Erro_404,  
       isnull(erros.Erro_424,0) as Erro_424,  
       isnull(erros.Erro_Outros,0) as Erro_Outros  
from (  
  select DataHora,  
      sum(qtde) as Quantidade,  
      sum(Historico) as Historico,  
      sum(Online) as Online  
  from (  
    -- ML_SC_ROUTE  
    select format(dateadd(hour,-3,cmr_dh_coleta),'HH:mm') as DataHora,  
        count(*) as qtde,  
        sum(Case when cmr_dh_referencia <> cast(getdate() as date) then 1 else 0 end) as Historico,  
        sum(Case when cmr_dh_referencia = cast(getdate() as date) then 1 else 0 end) as Online  
    from db_Irisys_Json.dbo.tb_ml_coleta_rotas  
    where cast(dateadd(hour,-3,cmr_dh_coleta) as date) = dateadd(day,-1,cast(getdate() as date))
    group by format(dateadd(hour,-3,cmr_dh_coleta),'HH:mm')  
  
    union all  
  
    -- ML_SC_ROUTES  
    select format(dateadd(hour,-3,cmt_dh_coleta),'HH:mm') as DataHora,  
        count(*) as qtde,  
        sum(Case when cmt_dh_referencia <> cast(getdate() as date) then 1 else 0 end) as Historico,  
        sum(Case when cmt_dh_referencia = cast(getdate() as date) then 1 else 0 end) as Online  
    from db_Irisys_Json.dbo.tb_ml_coleta_totalizador  
    where cast(dateadd(hour,-3,cmt_dh_coleta) as date) = dateadd(day,-1,cast(getdate() as date))
    group by format(dateadd(hour,-3,cmt_dh_coleta),'HH:mm')  
    
   ) as base  
  group by DataHora  
 ) as execucoes  
 full join   
 (  
  select top 5000  
    format(dateadd(hour,-3,dec_dh_coleta),'HH:mm') as DataHora,  
    count(*) as qtde,  
    sum(Case when dec_ds_erro = 'Error: Request failed with status code 401' then 1 else 0 end) as Erro_401,  
    sum(Case when dec_ds_erro = 'Error: Request failed with status code 403' then 1 else 0 end) as Erro_403,  
    sum(Case when dec_ds_erro = 'Error: Request failed with status code 404' then 1 else 0 end) as Erro_404,  
    sum(Case when dec_ds_erro = 'Error: Request failed with status code 424' then 1 else 0 end) as Erro_424,  
    sum(Case when left(dec_ds_erro,38) <> 'Error: Request failed with status code' then 1 else 0 end) as Erro_Outros  
  from tb_dra_erros_coleta  
  where cast(dateadd(hour,-3,dec_dh_coleta) as date) = dateadd(day,-1,cast(getdate() as date))
     and left(dec_ds_tipo_coleta,3) = 'ML_'  
  group by format(dateadd(hour,-3,dec_dh_coleta),'HH:mm')  
 ) as erros  
 on execucoes.DataHora = erros.DataHora  
order by 1 desc 
GO
