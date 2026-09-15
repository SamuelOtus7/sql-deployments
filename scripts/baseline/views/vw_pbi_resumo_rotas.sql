-- ============================================================
-- BASELINE: dbo.vw_pbi_resumo_rotas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pbi_resumo_rotas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_pbi_resumo_rotas]
as
SELECT 
	Data, 
	Transportadora, 
	Indicador, 
	case Indicador
		when 'Rotas' then 1
		when 'Reprocessar' then 2
		when 'ApontamentoAPP' then 3
		when 'KmEntregaCalculado' then 4
	end OrdemIndicador,
	Valor
FROM   
   (
	SELECT 
		*
	from
		vw_resumo_rotas
   ) p  
UNPIVOT  
   (Valor FOR Indicador IN   
      ([Rotas], [Reprocessar], [ApontamentoAPP], [KmEntregaCalculado])
)AS unpvt
GO
