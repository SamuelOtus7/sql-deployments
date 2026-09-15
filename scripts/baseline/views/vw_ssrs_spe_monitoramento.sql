-- ============================================================
-- BASELINE: dbo.vw_ssrs_spe_monitoramento
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_spe_monitoramento]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_ssrs_spe_monitoramento]
as


select 
    IdTransportadora
    ,NomeMotorista
    ,ServiceCenter
    ,IdRota
    ,UltimaEntrega
    ,TotalPacotes
    ,PacotesEntregues
    ,PacotesPendentes
    ,Insucesso
    ,PacotesTransferidos
    ,Reclamacoes
    ,RotaFinalizada
    ,TotalRotas
    ,RotaEmCurso
    ,Progresso
    ,DataHoraInicio
    ,NomeHub
    ,Hub
    ,PacotesNaoEntregue
    ,MediaPacotesPorHora
    ,TempoTotalRotaHoras
    ,HorarioInicioRota
    ,DataHoraDesignacaoRota
from tb_ssrs_spe_monitoramento nolock
WHERE DataReferencia = cast(getdate() as date) 

/*
select 
    r.IdTransportadora,
    r.Motorista as NomeMotorista,
    r.NomeHub as servicecenter,
    r.CodigoRota as idrota,
    format(r.DataUltimaEntrega,'HH:mm') as UltimaEntrega,
    sum(r.TotalPacotes) as TotalPacotes,
    sum(r.PacotesEntregues) as PacotesEntregues,
    sum(r.PacotesPendentes) as PacotesPendentes,
    sum(r.PacotesNaoEntregue) as Insucesso,
    0 as PacotesTransferidos,
    0 as Reclamacoes,
    sum(r.RotaFinalizada) as RotaFinalizada,
    COUNT(r.CodigoRota) as TotalRotas,
    COUNT(r.CodigoRota)-sum(r.RotaFinalizada) as RotaEmCurso,
    case 
        when sum(r.TotalPacotes) = 0 then 0 
        else (cast(sum(r.pacotesentregues) as float) / cast(sum(r.TotalPacotes) as float)) 
    end as Progresso,
    r.Datahorainicio,
    r.NomeHub as Nomehub,
    r.Hub,
    sum(r.PacotesNaoEntregue) as PacotesNaoEntregue,
    r.codigorota,
    
    -- Novo campo: média de pacotes por hora
    case 
        when DATEDIFF(minute, r.Datahorainicio, p.DataHoraEntregaMax) = 0 then sum(r.PacotesEntregues)
        else cast(sum(r.PacotesEntregues) as float) / (DATEDIFF(minute, r.Datahorainicio, p.DataHoraEntregaMax)/60.0)
    end as MediaPacotesPorHora
	  ,  DATEDIFF(minute, r.Datahorainicio, p.DataHoraEntregaMax)/60.0 as TempoTotalRotaHoras
	  ,format(r.Datahorainicio, 'HH:mm') as HorarioInicioRota


from dbo.vw_rotas_spe_v4 r
inner join tb_clientes b
    on r.IdTransportadora = b.cli_id_shopee
inner join (
    select 
        IdTransportadora, 
        CodigoRota, 
        max(DataHoraEntrega) as DataHoraEntregaMax
    from dbo.vw_pacotes_spe_v4
    group by IdTransportadora, CodigoRota
) p
    on r.IdTransportadora = p.IdTransportadora
    and r.CodigoRota = p.CodigoRota

where b.cli_in_ativo = 1
and cast(r.DataHoraInicio as date) = cast(GETDATE() as  date)
and b.cli_cd_codigo_cliente <> 7

group by 
    r.CodigoRota,
    format(r.DataUltimaEntrega,'HH:mm'),
    r.IdTransportadora,
    r.NomeHub,
    r.Hub,
    r.Motorista,
    r.datahorainicio,
    p.DataHoraEntregaMax
*/

GO
