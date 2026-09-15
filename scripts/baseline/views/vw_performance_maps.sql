-- ============================================================
-- BASELINE: dbo.vw_performance_maps
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_performance_maps]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_performance_maps]
as
select top 1440
	   isnull(base.DataHora, erros.DataHora) as DataHora,
	   isnull(base.qtde,0) as Sucesso,
	   isnull(erros.qtde,0) as Erros,
	   isnull(base.qtde,0) + isnull(erros.qtde,0) as Total
from (
		select format(dateadd(hour,-3,dam_dh_coleta),'HH:mm') as DataHora,
				count(*) as qtde,
				sum(Case when dam_dh_referencia <> cast(getdate() as date) then 1 else 0 end) as Historico,
				sum(Case when dam_dh_referencia = cast(getdate() as date) then 1 else 0 end) as Online
		from tb_dra_coleta_maps
		where cast(dateadd(hour,-3,dam_dh_coleta) as date) =  cast(getdate() as date)
		group by format(dateadd(hour,-3,dam_dh_coleta),'HH:mm')
	) as base
	full join (
		select  format(dateadd(hour,-3,dec_dh_coleta),'HH:mm') as DataHora,
				count(*) as qtde
		from tb_dra_erros_coleta
		where cast(dateadd(hour,-3,dec_dh_coleta) as date) =  cast(getdate() as date)
			  and dec_ds_tipo_coleta = 'SCRAPPER'
		group by format(dateadd(hour,-3,dec_dh_coleta),'HH:mm')
	) as erros
	on base.DataHora = erros.DataHora
order by 1 desc
GO
