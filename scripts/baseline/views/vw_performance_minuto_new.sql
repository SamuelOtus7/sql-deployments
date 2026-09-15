-- ============================================================
-- BASELINE: dbo.vw_performance_minuto_new
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_performance_minuto_new]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[vw_performance_minuto_new]

as

select top 1440
	   '' as MarketPlace,
	   '' as Transportadora,
	   execucoes.*,
       isnull(erros.qtde,0) as TotalErros,
	   isnull(erros.Erro_401,0) as Erro_401,
	   isnull(erros.Erro_403,0) as Erro_403,
	   isnull(erros.Erro_404,0) as Erro_404,
	   isnull(erros.Erro_424,0) as Erro_424,
	   isnull(erros.Erro_429,0) as Erro_429,
	   isnull(erros.Erro_Outros,0) as Erro_Outros
from (
		select DataHora,
			   sum(qtde) as Rotas,
			   sum(Historico) as Pacotes,
			   sum(Online) as Mapas,
			   sum(Online) as Outros
		from (
				-- ML_SC_ROUTE
				select format(dateadd(hour,-3,cmr_dh_coleta),'HH:mm') as DataHora,
					   count(*) as qtde,
					   sum(Case when cmr_dh_referencia <> cast(getdate() as date) then 1 else 0 end) as Historico,
					   sum(Case when cmr_dh_referencia = cast(getdate() as date) then 1 else 0 end) as Online
				from db_Irisys_Json.dbo.tb_ml_coleta_rotas
				where cast(dateadd(hour,-3,cmr_dh_coleta) as date) = cast(getdate() as date)
				group by format(dateadd(hour,-3,cmr_dh_coleta),'HH:mm')

				union all

				-- ML_SC_ROUTES
				select format(dateadd(hour,-3,cmt_dh_coleta),'HH:mm') as DataHora,
					   count(*) as qtde,
					   sum(Case when cmt_dh_referencia <> cast(getdate() as date) then 1 else 0 end) as Historico,
					   sum(Case when cmt_dh_referencia = cast(getdate() as date) then 1 else 0 end) as Online
				from db_Irisys_Json.dbo.tb_ml_coleta_totalizador
				where cast(dateadd(hour,-3,cmt_dh_coleta) as date) = cast(getdate() as date)
				group by format(dateadd(hour,-3,cmt_dh_coleta),'HH:mm')

				union all

				-- SCRAPPER (MAPS)
				select format(dateadd(hour,-3,dam_dh_coleta),'HH:mm') as DataHora,
					   count(*) as qtde,
					   sum(Case when dam_dh_referencia <> cast(getdate() as date) then 1 else 0 end) as Historico,
					   sum(Case when dam_dh_referencia = cast(getdate() as date) then 1 else 0 end) as Online
				from tb_dra_coleta_maps
				where cast(dateadd(hour,-3,dam_dh_coleta) as date) =  cast(getdate() as date)
				group by format(dateadd(hour,-3,dam_dh_coleta),'HH:mm')

				union all
		
				-- OUTROS (SP_STATION, DRIVER, SP_EXPORT, etc.)
				select format(dateadd(hour,-3,dac_dh_coleta),'HH:mm') as DataHora,
					   count(*) as qtde,
					   sum(Case when dac_dh_referencia <> cast(getdate() as date) then 1 else 0 end) as Historico,
					   sum(Case when dac_dh_referencia = cast(getdate() as date) then 1 else 0 end) as Online
				from db_Irisys_Json.dbo.tb_dra_coleta
				where cast(dateadd(hour,-3,dac_dh_coleta) as date) =  cast(getdate() as date)
				group by format(dateadd(hour,-3,dac_dh_coleta),'HH:mm')
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
				sum(Case when dec_ds_erro = 'Error: Request failed with status code 429' then 1 else 0 end) as Erro_429,
				sum(Case when left(dec_ds_erro,38) <> 'Error: Request failed with status code' then 1 else 0 end) as Erro_Outros
		from tb_dra_erros_coleta
		where cast(dateadd(hour,-3,dec_dh_coleta) as date) = cast(getdate() as date)
		group by format(dateadd(hour,-3,dec_dh_coleta),'HH:mm')
	) as erros
	on execucoes.DataHora = erros.DataHora
order by 3 desc
GO
