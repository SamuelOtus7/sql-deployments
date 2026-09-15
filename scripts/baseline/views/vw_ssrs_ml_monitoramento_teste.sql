-- ============================================================
-- BASELINE: dbo.vw_ssrs_ml_monitoramento_teste
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_ml_monitoramento_teste]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create view [dbo].[vw_ssrs_ml_monitoramento_teste]
as

select 
		IdTransportadora,
		NomeMotorista,
        servicecenter,
        OrigemSaida,
        idrota,
        format(DataUltimaEntrega,'HH:mm') as UltimaEntrega,
	   sum(TotalPacotes)		as TotalPacotes,
	   sum(PacotesEntregues)	as PacotesEntregues,
	   sum(PacotesPendentes)	as PacotesPendentes,
	   sum(PacotesNaoEntregue)	as Insucesso,
	   sum(PacotesTransferidos) as PacotesTransferidos,
	   sum(QuantidadeReclamacoes)	as Reclamacoes,
	   sum(RotaFinalizada)	as RotaFinalizada,
	   COUNT(IdRota)	as TotalRotas,
	   COUNT(IdRota)-sum(RotaFinalizada)	as RotaEmCurso,
	   case when sum(TotalPacotes) = 0 then 0 else 1.0 - (cast(sum(PacotesPendentes) as float) / cast(sum(TotalPacotes) as float)) end as Progresso

from vw_rotas as resultado

inner join tb_clientes as b
on resultado.IdTransportadora = b.cli_id_logistics

where cli_in_ativo = 1
and datareferencia = '2024-07-03'
and cli_cd_codigo_cliente <> 7
and StatusRota <> 'Planejada'
group by IdRota,
format(DataUltimaEntrega,'HH:mm'),
	     IdTransportadora,
         servicecenter,
         OrigemSaida,
         idrota,
		 NomeMotorista
		--  NomeServiceCenter

GO
