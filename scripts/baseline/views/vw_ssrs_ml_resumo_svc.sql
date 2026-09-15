-- ============================================================
-- BASELINE: dbo.vw_ssrs_ml_resumo_svc
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_ml_resumo_svc]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_ssrs_ml_resumo_svc]
as

select 
		IdTransportadora,

	   ServiceCenter,
	   NomeServiceCenter,
	   sum(cast(TotalPacotes as int) )		as TotalPacotes,
	   sum(cast(PacotesEntregues as int) )	as PacotesEntregues,
	   sum(cast(PacotesNaoEntregue as int) )	as PacotesNaoEntregue,
	   sum(cast(PacotesPendentes as int) )	as PacotesPendentes,
	   sum(cast(PacotesTransferidos as int) ) as PacotesTransferidos,
	   count(*) as Rotas,
	   case when sum(cast(TotalPacotes as int) ) = 0 then 0 else 1.0 - (cast(sum(cast(PacotesPendentes as int) ) as float) / cast(sum(cast(TotalPacotes as int) ) as float)) end as Progresso
from vw_rotas_diaatual as resultado
where StatusRota <> 'Planejada'
group by ServiceCenter,
	     IdTransportadora,
		 NomeServiceCenter

GO
