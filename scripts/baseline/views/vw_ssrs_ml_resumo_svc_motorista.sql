-- ============================================================
-- BASELINE: dbo.vw_ssrs_ml_resumo_svc_motorista
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_ml_resumo_svc_motorista]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_ssrs_ml_resumo_svc_motorista]
as

select 
		IdTransportadora,
		cli_cd_codigo_cliente CodCliente,
		NomeMotorista,
	   ServiceCenter,
	   NomeServiceCenter,
	   sum(cast(TotalPacotes as int))		as TotalPacotes,
	   sum(cast(PacotesEntregues as int))	as PacotesEntregues,
	   sum(cast(PacotesNaoEntregue as int))	as PacotesNaoEntregue,
	   sum(cast(PacotesPendentes as int))	as PacotesPendentes,
	   sum(cast(PacotesTransferidos as int)) as PacotesTransferidos,
	   count(*) as Rotas,
	   case when sum(cast(TotalPacotes as int)) = 0 then 0 else 1.0 - (cast(sum(cast(PacotesPendentes as int)) as float) / cast(sum(cast(TotalPacotes as int)) as float)) end as Progresso

from vw_rotas_diaatual as resultado

inner join tb_clientes as b
on resultado.IdTransportadora = b.cli_id_logistics

where cli_in_ativo = 1
and cli_cd_codigo_cliente <> 7
and StatusRota <> 'Planejada'
group by ServiceCenter,
cli_cd_codigo_cliente,
	     IdTransportadora,
		 NomeMotorista,
		 NomeServiceCenter

GO
