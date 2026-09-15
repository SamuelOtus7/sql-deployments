-- ============================================================
-- BASELINE: dbo.USPssrsSPEMonitoramento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[USPssrsSPEMonitoramento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USPssrsSPEMonitoramento]   (
@idtransportadora int 
) as 

begin 

  --SET NOCOUNT off;

    DECLARE @DataHoje DATE = CAST(GETDATE() AS DATE);
    --declare @idtransportadora int = 20230015;

    drop table if exists #TempDadosRotas

    SELECT 
        r.IdTransportadora,
        r.Motorista AS NomeMotorista,
        r.NomeHub AS ServiceCenter,
        r.CodigoRota AS IdRota,
        FORMAT(r.DataUltimaEntrega,'HH:mm') AS UltimaEntrega,
        SUM(r.TotalPacotes) AS TotalPacotes,
        SUM(r.PacotesEntregues) AS PacotesEntregues,
        SUM(r.PacotesPendentes) AS PacotesPendentes,
        SUM(r.PacotesNaoEntregue) AS Insucesso,
        0 AS PacotesTransferidos,
        0 AS Reclamacoes,
        SUM(r.RotaFinalizada) AS RotaFinalizada,
        COUNT(r.CodigoRota) AS TotalRotas,
        COUNT(r.CodigoRota) - SUM(r.RotaFinalizada) AS RotaEmCurso,
        CASE 
            WHEN SUM(r.TotalPacotes) = 0 THEN 0 
            ELSE CAST(SUM(r.PacotesEntregues) AS FLOAT) / NULLIF(CAST(SUM(r.TotalPacotes) AS FLOAT), 0)
        END AS Progresso,
        r.DataHoraInicio,
        r.NomeHub,
        r.Hub,
        SUM(r.PacotesNaoEntregue) AS PacotesNaoEntregue,
        
        CASE 
            WHEN DATEDIFF(MINUTE, r.DataHoraInicio, p.DataHoraEntregaMax) = 0 
                THEN SUM(r.PacotesEntregues)
            ELSE CAST(SUM(r.PacotesEntregues) AS float) / 
                    NULLIF((DATEDIFF(MINUTE, r.DataHoraInicio, p.DataHoraEntregaMax)/60.0), 0)
        END AS MediaPacotesPorHora,

        DATEDIFF(MINUTE, r.DataHoraInicio, p.DataHoraEntregaMax)/60.0 AS TempoTotalRotaHoras,
        FORMAT(r.DataHoraInicio, 'HH:mm') AS HorarioInicioRota,
        r.datareferencia
        ,r.DataHoraDesignacaoRota
        INTO #TempDadosRotas
    FROM dbo.vw_rotas_spe_v4 r
    INNER JOIN tb_clientes b ON r.IdTransportadora = b.cli_id_shopee
    INNER JOIN (
        SELECT 
            IdTransportadora, 
            CodigoRota, 
            MAX(DataHoraEntrega) AS DataHoraEntregaMax
        FROM dbo.tb_spe_pacotes_v5
        where excluido = 0 
        GROUP BY IdTransportadora, CodigoRota
    ) p ON r.IdTransportadora = p.IdTransportadora AND r.CodigoRota = p.CodigoRota
    WHERE 
        b.cli_in_ativo = 1

        --Alterado por Saulo Barros em 14/05 para considerar também rotas que não iniciaram mas estão com data de designação
        --AND CAST(r.DataHoraInicio AS DATE) = @DataHoje
        and (
                (
                    r.DataHoraInicio >= @DataHoje
                    and r.DataHoraInicio < dateadd(day,1,@DataHoje)
                )
                or
                (
                    r.DataHoraDesignacaoRota >= @DataHoje
                    and r.DataHoraDesignacaoRota < dateadd(day,1,@DataHoje)
                )
            )
        --Fim ajuste Saulo

        AND b.cli_cd_codigo_cliente <> 7
        and  r.IdTransportadora = @idtransportadora
    GROUP BY 
        r.CodigoRota,
        FORMAT(r.DataUltimaEntrega,'HH:mm'),
        r.IdTransportadora,
        r.NomeHub,
        r.Hub,
        r.Motorista,
        r.DataHoraInicio,
        p.DataHoraEntregaMax,
        r.datareferencia,
        r.DataHoraDesignacaoRota;
        

    -- MERGE com tabela destino
    MERGE dbo.tb_ssrs_spe_monitoramento AS TARGET
    USING #TempDadosRotas AS SOURCE
    ON (
        TARGET.IdTransportadora = SOURCE.IdTransportadora
        AND TARGET.IdRota = SOURCE.IdRota
        AND TARGET.DataReferencia = @DataHoje
    )
    WHEN MATCHED THEN
        UPDATE SET 
            NomeMotorista = SOURCE.NomeMotorista,
            ServiceCenter = SOURCE.ServiceCenter,
            UltimaEntrega = SOURCE.UltimaEntrega,
            TotalPacotes = SOURCE.TotalPacotes,
            PacotesEntregues = SOURCE.PacotesEntregues,
            PacotesPendentes = SOURCE.PacotesPendentes,
            Insucesso = SOURCE.Insucesso,
            PacotesTransferidos = SOURCE.PacotesTransferidos,
            Reclamacoes = SOURCE.Reclamacoes,
            RotaFinalizada = SOURCE.RotaFinalizada,
            TotalRotas = SOURCE.TotalRotas,
            RotaEmCurso = SOURCE.RotaEmCurso,
            Progresso = SOURCE.Progresso,
            DataHoraInicio = SOURCE.DataHoraInicio,
            NomeHub = SOURCE.NomeHub,
            Hub = SOURCE.Hub,
            PacotesNaoEntregue = SOURCE.PacotesNaoEntregue,
            MediaPacotesPorHora = SOURCE.MediaPacotesPorHora,
            TempoTotalRotaHoras = SOURCE.TempoTotalRotaHoras,
            HorarioInicioRota = SOURCE.HorarioInicioRota,
            DataHoraDesignacaoRota = SOURCE.DataHoraDesignacaoRota
            
    WHEN NOT MATCHED THEN
        INSERT (
            IdTransportadora, NomeMotorista, ServiceCenter, IdRota, UltimaEntrega,
            TotalPacotes, PacotesEntregues, PacotesPendentes, Insucesso,
            PacotesTransferidos, Reclamacoes, RotaFinalizada, TotalRotas, RotaEmCurso,
            Progresso, DataHoraInicio , NomeHub, Hub, PacotesNaoEntregue,
            MediaPacotesPorHora, TempoTotalRotaHoras, HorarioInicioRota, DataReferencia, DataHoraDesignacaoRota
        )
        VALUES (
            SOURCE.IdTransportadora, SOURCE.NomeMotorista, SOURCE.ServiceCenter, SOURCE.IdRota, SOURCE.UltimaEntrega,
            SOURCE.TotalPacotes, SOURCE.PacotesEntregues, SOURCE.PacotesPendentes, SOURCE.Insucesso,
            SOURCE.PacotesTransferidos, SOURCE.Reclamacoes, SOURCE.RotaFinalizada, SOURCE.TotalRotas, SOURCE.RotaEmCurso,
            SOURCE.Progresso, SOURCE.DataHoraInicio, SOURCE.NomeHub, SOURCE.Hub, SOURCE.PacotesNaoEntregue,
            SOURCE.MediaPacotesPorHora, SOURCE.TempoTotalRotaHoras, SOURCE.HorarioInicioRota, @DataHoje, DataHoraDesignacaoRota
        );

END;
GO
