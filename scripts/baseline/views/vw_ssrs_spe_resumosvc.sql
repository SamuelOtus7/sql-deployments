-- ============================================================
-- BASELINE: dbo.vw_ssrs_spe_resumosvc
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_spe_resumosvc]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO


create view [dbo].[vw_ssrs_spe_resumosvc]
as

select 
		IdTransportadora,
		--Motorista NomeMotorista,
        NomeHub servicecenter,
       --null  OrigemSaida,
      --  CodigoRota idrota,
        max(format(DataUltimaEntrega,'HH:mm')) as UltimaEntrega,
	   sum(TotalPacotes)		as TotalPacotes,
	   sum(PacotesEntregues)	as PacotesEntregues,
	   sum(PacotesPendentes)	as PacotesPendentes,
	   sum(PacotesNaoEntregue)	as Insucesso,
	   0 as PacotesTransferidos,
	   0 as Reclamacoes,
	   sum(RotaFinalizada)	as RotaFinalizada,
	   COUNT(CodigoRota)	as TotalRotas,
	   COUNT(CodigoRota)-sum(RotaFinalizada)	as RotaEmCurso,
	   case when sum(TotalPacotes) = 0 then 0 else 1.0 - (cast(sum(PacotesPendentes) as float) / cast(sum(TotalPacotes) as float)) end as Progresso

from [dbo].[vw_rotas_spe_v4_diaatual] as resultado

inner join tb_clientes as b
on resultado.IdTransportadora = b.cli_id_shopee

where cli_in_ativo = 1
and cli_cd_codigo_cliente <> 7
-- and StatusRota <> 'Planejada'

group by --CodigoRota,
--format(DataUltimaEntrega,'HH:mm'),
	     IdTransportadora,
         NomeHub
        --  OrigemSaida,
		 --Motorista
		--  NomeServiceCenter

GO
