-- ============================================================
-- BASELINE: dbo.vw_ssrs_ml_monitoramento
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_ml_monitoramento]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE view [dbo].[vw_ssrs_ml_monitoramento] as
select 
		IdTransportadora,
		NomeMotorista,
        servicecenter,
        OrigemSaida,
        idrota,
	
	case when DATEPART(hour,r.DataHoraInicio) < 12 then 'AM'
	  WHEN FORMAT(r.DataHoraInicio, 'HH:mm') BETWEEN '15:40' AND '17:30' THEN 'SD'
	  ELSE 'PM' end Ciclo,
        format(DataUltimaEntrega,'HH:mm') as UltimaEntrega,
	   sum(cast(TotalPacotes as int ))		as TotalPacotes,
	   sum(cast(PacotesEntregues as int ))	as PacotesEntregues,
	   sum(cast(PacotesPendentes as int ))	as PacotesPendentes,
	   sum(cast(PacotesNaoEntregue as int ))	as Insucesso,
	   sum(cast(PacotesTransferidos as int )) as PacotesTransferidos,
	   sum(cast(QuantidadeReclamacoes as int ))	as Reclamacoes,
	   sum(cast(case when r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos or r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue or (r.StatusRota = 'planned' and r.DataReferencia < cast(getdate() as date)) then 1 else 0 end as int ))	as RotaFinalizada,
	   COUNT(IdRota)	as TotalRotas,
	   COUNT(IdRota)-sum(cast(case when r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos or r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue or (r.StatusRota = 'planned' and r.DataReferencia < cast(getdate() as date)) then 1 else 0 end as int ))	as RotaEmCurso,
	case 
    when COALESCE(sum(cast(TotalPacotes as int)),0) = 0 
        then 0 
    else 1.0 - (
        cast(sum(cast(PacotesPendentes as int)) as float) 
        / NULLIF(cast(sum(cast(TotalPacotes as int)) as float),0)
    ) 
end as Progresso
	  ,StatusRota
	  ,cast(sum(isnull(Quantidadeparadas,0)) as int)  as paradas
	  
	,CASE 
    WHEN SUM(R.TempoEmRota) IS NULL OR SUM(R.TempoEmRota) < 0 THEN NULL
    WHEN SUM(R.TempoEmRota) >= 1440 THEN '+24h'
    ELSE FORMAT(DATEADD(MINUTE, SUM(R.TempoEmRota), '00:00:00'), 'HH:mm')
END AS ORH
,CASE 
    WHEN SUM(R.TempoAreaEntrega) IS NULL OR SUM(R.TempoAreaEntrega) < 0 THEN NULL
    WHEN SUM(R.TempoAreaEntrega) >= 1440 THEN '+24h'
    ELSE FORMAT(DATEADD(MINUTE, SUM(R.TempoAreaEntrega), '00:00:00'), 'HH:mm')
END AS OZH
,CASE 
    WHEN SUM(R.TempoEmRota) - SUM(R.TempoAreaEntrega) IS NULL 
         OR SUM(R.TempoEmRota) - SUM(R.TempoAreaEntrega) < 0 THEN NULL
    WHEN SUM(R.TempoEmRota) - SUM(R.TempoAreaEntrega) >= 1440 THEN '+24h'
    ELSE FORMAT(DATEADD(MINUTE, SUM(R.TempoEmRota) - SUM(R.TempoAreaEntrega), '00:00:00'), 'HH:mm')
END AS Stemout

,Placa
,CAST(
    CASE 
        WHEN COALESCE(SUM(CASE WHEN r.Ambulancia = 0 THEN r.TotalPacotes ELSE 0 END),0) = 0 
            THEN 0
        ELSE 
            CAST(SUM(CASE WHEN r.Ambulancia = 0 THEN r.PacotesEntregues ELSE 0 END) AS FLOAT)
            / NULLIF(CAST(SUM(CASE WHEN r.Ambulancia = 0 THEN r.TotalPacotes ELSE 0 END) AS FLOAT),0)
    END 
AS FLOAT) AS PercentualPerformance

,DataHoraInicio
,CAST(
    CASE 
        WHEN COALESCE(SUM(CAST(TotalPacotes AS INT)),0) = 0 
            THEN '0%' 
        ELSE 
            CAST(
                LEFT(
                    ROUND(
                        CAST(SUM(CAST(PacotesEntregues AS INT)) AS DECIMAL(10,2)) 
                        / NULLIF(SUM(CAST(TotalPacotes AS INT)),0) * 100
                    ,2)
                ,5
                ) AS VARCHAR(30)
            ) + '%'
    END
AS VARCHAR(30)) AS [success_delivery]


,CAST(
        ROUND(
            (SUM(CAST(PacotesEntregues AS DECIMAL(18,4))) * 1.0 /
             NULLIF(COALESCE(SUM(CAST(TotalPacotes AS DECIMAL(18,4))),0),0)) * 100
        , 2
        ) AS DECIMAL(18,2)
    ) AS media_success_delivery


	  

from tb_ml_rotas as r

inner join tb_clientes as b
on r.IdTransportadora = b.cli_id_logistics

where cli_in_ativo = 1
and cli_cd_codigo_cliente <> 7
and StatusRota <> 'planned'
and datareferencia = cast(dateadd(hour,-2,getdate()) as date) -- NÃO ALTERAR, USADO PARA ENVIOS NOS FECHAMENTOS DIÁRIOS
and Excluido = 0
 AND (
        (IdTransportadora = 1387994348 AND
         NOT (
             r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos
             OR r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue
             OR (r.StatusRota = 'planned' AND r.DataReferencia < cast(getdate() as date))
         )
        )
        OR (IdTransportadora <> 1387994348)
      )



group by IdRota,
format(DataUltimaEntrega,'HH:mm'),
	     IdTransportadora,
         servicecenter,
         OrigemSaida,
         idrota,
		 NomeMotorista,
		 case when FORMAT(datahorainicio,'HH') < 12  then 'AM' else 'PM' end,
		 statusrota,
		 Placa
		 ,DataHoraInicio
		 -- NomeServiceCenter
GO
