-- ============================================================
-- BASELINE: dbo.vw_ssrs_ml_svc
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_ml_svc]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[vw_ssrs_ml_svc]
as

select 
		IdTransportadora,
	--	NomeMotorista,
        servicecenter,
        --OrigemSaida,
        --idrota,
       max(format(DataUltimaEntrega,'HH:mm')) as UltimaEntrega,
	  sum(cast(PacotesEntregues as int)) +    sum(cast(PacotesPendentes as int)) +    sum(cast(PacotesNaoEntregue as int))
	  + sum(cast(PacotesTransferidos as int)) 	  as TotalPacotes,
	   sum(cast(PacotesEntregues as int))	as PacotesEntregues,
	   sum(cast(PacotesPendentes as int))	as PacotesPendentes,
	   sum(cast(PacotesNaoEntregue as int))	as Insucesso,
	   sum(cast(PacotesTransferidos as int)) as PacotesTransferidos,
	   sum(cast(QuantidadeReclamacoes as int))	as Reclamacoes,
	   sum(cast(RotaFinalizada as int))	as RotaFinalizada,
	   COUNT(resultado.IdRota)	as TotalRotas,
	   COUNT(resultado.IdRota)-sum(cast(RotaFinalizada as int))	as RotaEmCurso,
	   case when sum(cast(TotalPacotes as int)) = 0 then 0 else 1.0 - (cast(sum(cast(PacotesPendentes as int)) as float) / cast(sum(cast(TotalPacotes as int)) as float)) end as Progresso,
	   Svc_Cidade as bss_ds_label,
	   sum(isnull(QtdSinistros,0)) as Sinistros
	   			,         CAST(Ciclo AS VARCHAR(30)) AS ciclo
				,CAST(
    CAST(SUM(CASE WHEN Ambulancia = 0 THEN PacotesEntregues ELSE 0 END) AS FLOAT)
    / NULLIF(CAST(SUM(CASE WHEN Ambulancia = 0 THEN TotalPacotes ELSE 0 END) AS FLOAT), 0)
AS FLOAT
) AS PercentualPerformance

from vw_rotas_diaatual as resultado

inner join tb_clientes as b
on resultado.IdTransportadora = b.cli_id_logistics

left join (
	select
		IdRota
		,count(*) as QtdSinistros
	from vw_pacotes_diaatual
	where IdEntrega in (
							select 
							pac_ds_codigo_pacote
							from [dbo].[tb_pac_sinistros]
							)
	group by IdRota
) sinistros
on resultado.IdRota = sinistros.IdRota
where cli_in_ativo = 1
and cli_cd_codigo_cliente <> 7
and StatusRota <> 'Planejada'
group by --IdRota,
--format(DataUltimaEntrega,'HH:mm'),
	     IdTransportadora,
		 Svc_Cidade,
         servicecenter,
		 Ciclo
         --OrigemSaida
         --idrota,
		 --NomeMotorista
		--  NomeServiceCenter

GO
