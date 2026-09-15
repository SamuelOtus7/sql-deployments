-- ============================================================
-- BASELINE: dbo.UspSPE_GetLoad_Rotas_Prefatura
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPE_GetLoad_Rotas_Prefatura]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSPE_GetLoad_Rotas_Prefatura]
AS
BEGIN
    SET NOCOUNT ON;

    /* =========================================================
       1) Fonte: 1 linha por rota (pacote mais recente)
          + TotalPacotes da rota
       ========================================================= */

    IF OBJECT_ID('tempdb..#RotasFonte') IS NOT NULL
        DROP TABLE #RotasFonte;

    SELECT
        IdTransportadora,
        Rota,
        DataReferencia,
        Data_da_Prestacao_do_Servico,
        Data_da_Entrega,
        Hub,
        Tipo_do_Servico,
        Tipo_do_Veiculo,
        Placa,
        Resultado,
        TotalPacotes
    INTO #RotasFonte
    FROM
    (
        SELECT
            p.IdTransportadora,
            p.Rota,

            CAST(p.Data_da_Prestacao_do_Servico AS DATE) AS DataReferencia,
            p.Data_da_Prestacao_do_Servico,
            p.Data_da_Entrega,
            p.Hub,
            p.Tipo_do_Servico,
            p.Tipo_do_Veiculo,
            p.Placa,
            p.Resultado,

            COUNT(*) OVER
            (
                PARTITION BY
                    p.IdTransportadora,
                    p.Rota
            ) AS TotalPacotes,

            ROW_NUMBER() OVER
            (
                PARTITION BY
                    p.IdTransportadora,
                    p.Rota
                ORDER BY
                    ISNULL(p.Data_da_Entrega, p.Data_da_Prestacao_do_Servico) DESC
            ) AS rn
        FROM dbo.tb_spe_pacotes_prefatura p
        WHERE p.Rota IS NOT NULL
    ) x
    WHERE rn = 1;

    /* =========================================================
       2) MERGE – tabela de rotas prefatura
       ========================================================= */

    MERGE dbo.tb_spe_rotas_prefatura AS T
    USING #RotasFonte AS S
        ON  T.IdTransportadora = S.IdTransportadora
        AND T.CodigoRota       = S.Rota

    WHEN MATCHED THEN
        UPDATE SET
            T.DataReferencia        = S.DataReferencia,
            T.DataHoraInicio        = S.Data_da_Prestacao_do_Servico,
            T.DataHoraFim           = S.Data_da_Entrega,
            T.DataHoraUltimaEntrega = S.Data_da_Entrega,
            T.NomeHub               = S.Hub,
            T.TipoOperacao          = S.Tipo_do_Servico,
            T.TipoVeiculo           = S.Tipo_do_Veiculo,
            T.Placa                 = S.Placa,
            T.Resultado             = S.Resultado,
            T.TotalPacotes          = S.TotalPacotes   -- <<< AQUI

    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            IdTransportadora,
            CodigoRota,
            DataReferencia,
            DataHoraInicio,
            DataHoraFim,
            DataHoraUltimaEntrega,
            NomeHub,
            TipoOperacao,
            TipoVeiculo,
            Placa,
            Resultado,
            TotalPacotes
        )
        VALUES
        (
            S.IdTransportadora,
            S.Rota,
            S.DataReferencia,
            S.Data_da_Prestacao_do_Servico,
            S.Data_da_Entrega,
            S.Data_da_Entrega,
            S.Hub,
            S.Tipo_do_Servico,
            S.Tipo_do_Veiculo,
            S.Placa,
            S.Resultado,
            S.TotalPacotes           -- <<< AQUI
        );

END;
GO
