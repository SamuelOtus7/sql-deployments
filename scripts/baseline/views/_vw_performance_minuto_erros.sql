-- ============================================================
-- BASELINE: dbo._vw_performance_minuto_erros
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[_vw_performance_minuto_erros]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[_vw_performance_minuto_erros]

as

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
order by 1 desc
GO
