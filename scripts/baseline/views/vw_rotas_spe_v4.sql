-- ============================================================
-- BASELINE: dbo.vw_rotas_spe_v4
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_spe_v4]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE  view [dbo].[vw_rotas_spe_v4]
as

select  distinct
	rotas.Id IdInterno,
	rotas.CodigoRota,
	rotas.IdStation,
	isnull(ROTAS.nomehubrotas,station.NomeStation) NomeHub,
	station.CodigoStation Hub,
	rotas.IdTransportadora,
	motoristas.IdMotorista,
	motoristas.NomeMotorista Motorista,
	rotas.DataReferencia,
	rotas.TotalPacotes,
	DataHoraColeta,
	rotas.PacotesEntregues,
	rotas.PacotesNaoEntregue,
	rotas.PacotesPendentes,
	case when rotas.TotalPacotes = PacotesEntregues + PacotesNaoEntregue then 1 else 0 end RotaFinalizada,
	rotas.DataUltimaEntrega,
	rotas.KmColetado,
	rotas.LinkMapa,
	rotas.TipoVeiculo,


 DataHoraInicio,

	
	case
    when DATEPART(HOUR,rotas.DataHoraCarga) between 0 and 11 
    then '0h - 11h'
    when DATEPART(HOUR,rotas.DataHoraCarga) between 12 and 15 
    then '12h - 15hs'
    when DATEPART(HOUR,rotas.DataHoraCarga) between 16 and 17 
    then '16hs - 17hs'
    when DATEPART(HOUR,rotas.DataHoraCarga) between 18 and 23 
    then '18hs - 23hs'
    end FiltroCarregamento,
    Paradas,
	--CidadeReferencia,
    CidadeDistante as CidadeReferencia,
    DistanciaTotal,
	case when tlm_cd_risco_ajudante = 'risco' then 'Sim' else 'Não' end as LancRisco,
	UsuarioIrisys,
	CidadeDistante,
	CASE 
    WHEN station.NomeStation = 'LM Hub_SP_Campinas_São Martinho' THEN 'CPS'
    ELSE NomeAmigavel
END AS SiglaHubMedida, -- Teste diante solicitação da adição de novas siglas para o HUB. Caso seja validado, faremos isso internamente, antes da view.
	CASE
		WHEN rotas.TotalPacotes = 0 
			OR rotas.TotalPacotes IS NULL
			THEN 0
		ELSE rotas.PacotesEntregues / (rotas.TotalPacotes * 1.0)
	END	AS PerformacePacotes
,CASE 
    WHEN LTRIM(RTRIM(rotas.Placa)) = '' THEN '-'
    ELSE isnull(rotas.Placa,'-')
END AS Placa
,case when DATEPART(hour,DataHoraInicio) < 12 then 'AM'
	  WHEN FORMAT(DataHoraInicio, 'HH:mm') BETWEEN '15:40' AND '17:30' THEN 'SD'
	  ELSE 'PM' end Ciclo
	  ,
CASE WHEN 
rotas.IDTRANSPORTADORA = 20230021 THEN 
CAST(DataReferencia AS date) 
ELSE 
Cast(Datahorainicio as date) END  as InicioDaRota,

	CASE
    WHEN rotas.IdTransportadora = 20230021 THEN
        CASE
            --  Se a coleta e o incio forem de dias diferentes, usa a data da coleta
            WHEN CONVERT(date, rotas.DataHoraColeta) <> CONVERT(date, rotas.DataHoraInicio)
                THEN 
                    -- Se  houve entrega em outro dia (redelivery), adiciona legenda
                    CASE 
                        WHEN CONVERT(date, rotas.DataReferencia) < CONVERT(date, rotas.DataUltimaEntrega)
                            THEN FORMAT(rotas.DataUltimaEntrega, 'yyyy-MM-dd HH:mm:ss') + ' (Redelivery)'
                        ELSE 
                            FORMAT(rotas.DataHoraInicio, 'yyyy-MM-dd HH:mm:ss')
                    END
            --  mesmo dia, mostra normalmente
            ELSE FORMAT(rotas.DataHoraInicio, 'yyyy-MM-dd HH:mm:ss')
        END
    ELSE
        FORMAT(rotas.DataHoraInicio, 'yyyy-MM-dd HH:mm:ss')
END AS DataHoraInicioExib,
CASE
    WHEN TipoOperacao IS NOT NULL THEN TipoOperacao
    ELSE 
        CASE 
            WHEN CodigoRota LIKE 'AT%' THEN 'LM'
            WHEN CodigoRota LIKE 'LT%' THEN 'LH'
            WHEN ISNUMERIC(CodigoRota) = 1 THEN 'FM'
            ELSE NULL
        END
END AS TipoRota
,
	CASE
    WHEN rotas.IdTransportadora = 20230021 THEN
        CASE
            --  Se a coleta e o incio forem de dias diferentes, usa a data da coleta
            WHEN CONVERT(date, rotas.DataHoraColeta) <> CONVERT(date, rotas.DataHoraInicio)
                THEN 
                    -- Se  houve entrega em outro dia (redelivery), adiciona legenda
                    CASE 
                        WHEN CONVERT(date, rotas.DataReferencia) < CONVERT(date, rotas.DataUltimaEntrega)
                            THEN  'Redelivery'
                        ELSE 
                            'Padrão'
                    END
            --  mesmo dia, mostra normalmente
            ELSE 'Padrão'
        END
    ELSE
       'Padrão'
END AS FiltroRedelivery,
DataHoraDesignacaoRota


	-- case when datepart(HOUR, DataHoraInicio) >= 12 then 'PM' ELSE 'AM' end  CicloPM

from
	(
-- select  * from  tb_spe_rotas_v4 WITH(NOLOCK)
-- UNION ALL
select  Id
,CodigoRota
,IdTransportadora
,DataReferencia
,DataHoraInicio
,DataHoraFim
,DataHoraColeta
,IdStation
,IdMotorista
,IdStatus
,DataAtualizacao
,Excluido
,TotalPacotes
,PacotesEntregues
,PacotesNaoEntregue
,PacotesPendentes
,DataUltimaEntrega
,case when KmColetado is null then KmPacotes else KmColetado end KmColetado
,LinkMapa
,TipoVeiculo
,DataHoraInicio DataHoraCarga
,Paradas
,CidadeReferencia
,DistanciaTotal
,UsuarioIrisys
,KmApp
,LinkMapaApp
,QuantidadeApontamento
,LinkAppInterno
,Apuracao
,UsouAPP
,CidadeDistante
,NomeHub as nomehubrotas
,placa
,TipoOperacao
,DataHoraDesignacaoRota
from  tb_spe_rotas_v5 WITH(NOLOCK)

    ) AS ROTAS 
	LEFT join tb_spe_motoristas motoristas with(nolock) on rotas.IdMotorista = motoristas.IdMotorista and rotas.IdTransportadora = motoristas.IdTransportadora
	left join tb_spe_station station with(nolock) on rotas.IdStation = station.IdStation
	left join (
				select 
					a.tlm_cd_rota
					,a.tlm_cd_risco_ajudante

				from tb_lancamentos_manuais as a
				inner join (
					select 
					tlm_cd_lancamento_manual	
					,tlm_cd_rota
					,ROW_NUMBER() over(partition by tlm_cd_rota order by tlm_cd_lancamento_manual desc) ordem
					from tb_lancamentos_manuais
					where tlm_cd_cliente = 27
					and tlm_cd_risco_ajudante = 'Risco'
					--and tlm_cd_rota = 'AT202405131ORMZ'
				) as b
				on a.tlm_cd_lancamento_manual = b.tlm_cd_lancamento_manual
				and b.ordem = 1
	) as lanc
	on cast(rotas.CodigoRota as varchar(50)) = lanc.tlm_cd_rota


where 1=1
	and rotas.Excluido = 0
	and ((rotas.TotalPacotes > 0 or (rotas.IdTransportadora in (20230008) and rotas.CodigoRota like 'to%' ))
	or (ROTAS.Excluido =  0 and rotas.IdTransportadora in (20230024)))
	--AND codigorota = 'AT2024060722LRC'
	--and rotas.DataReferencia = '2024-06-18'
	
	--select * from tb_spe_rotas_v4 where CodigoRota = 'AT2024060520ZJ6'

	--select * from tb_spe_motoristas where IdMotorista = 90895

GO
