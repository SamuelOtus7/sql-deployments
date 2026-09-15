-- ============================================================
-- BASELINE: dbo.UspAlarmePacotesPendentesShopee
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAlarmePacotesPendentesShopee]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspAlarmePacotesPendentesShopee]
AS
BEGIN
    DROP TABLE IF EXISTS #aux;

    -- Total de pacotes por transportadora/dia (TODOS os status)
    WITH Totais AS (
        SELECT 
            a.IdTransportadora,
            CAST(a.DataReferencia AS DATE) AS DataRef,
            COUNT(*) AS TotalPacotes
        FROM tb_spe_pacotes_v5 a
		        JOIN tb_clientes b ON a.IdTransportadora = b.cli_id_shopee

        WHERE 
            DataReferencia BETWEEN CAST(GETDATE() - 7 AS DATE) AND CAST(GETDATE() - 2 AS DATE)
            AND Excluido = 0
            AND b.cli_in_ativo = 1
            AND b.cli_cd_codigo_cliente <> 7
        GROUP BY IdTransportadora, CAST(DataReferencia AS DATE)
    ),

    -- Apenas pacotes PENDENTES
    Pendentes AS (
        SELECT 
            a.IdTransportadora,
            b.cli_ds_nome AS Transportadora,
            CAST(a.DataReferencia AS DATE) AS DataRef,
            COUNT(*) AS QtdePacotesPendentes
        FROM tb_spe_pacotes_v5 a
        JOIN tb_clientes b ON a.IdTransportadora = b.cli_id_shopee
        WHERE 
            a.DataReferencia BETWEEN CAST(GETDATE() - 7 AS DATE) AND CAST(GETDATE() - 2 AS DATE)
            AND a.StatusEntrega = 'DELIVERING'
            AND a.Excluido = 0
            AND b.cli_in_ativo = 1
            AND b.cli_cd_codigo_cliente <> 7
        GROUP BY a.IdTransportadora, CAST(a.DataReferencia AS DATE), b.cli_ds_nome
    )

    -- Junta pendentes + totais e filtra onde ultrapassa 8%
    SELECT 
        p.IdTransportadora,
        p.Transportadora,
        p.DataRef AS DataReferencia,
        p.QtdePacotesPendentes
    INTO #aux
    FROM Pendentes p
    INNER JOIN Totais t 
        ON p.IdTransportadora = t.IdTransportadora 
       AND p.DataRef = t.DataRef
    WHERE 
        t.TotalPacotes > 0 AND 
        p.QtdePacotesPendentes / t.TotalPacotes > 0.07
    ORDER BY 
        p.IdTransportadora,
        p.DataRef,
        p.Transportadora;

    -- Geração de mensagem de alerta
    IF EXISTS (SELECT 1 FROM #aux)
    BEGIN
        DECLARE @coleta VARCHAR(MAX);
        DECLARE @mensagem VARCHAR(MAX);

        SELECT  @coleta = SUBSTRING( 
          ( 
            SELECT CHAR(10) + CONCAT(Transportadora, ' | Qtd: ', QtdePacotesPendentes, ' | Data: ', CONVERT(VARCHAR, DataReferencia, 103)) + CHAR(10) + CHAR(10)
            FROM #aux
            FOR XML PATH('')
        ), 2 , 9999);

        SET @mensagem = '*[Pacotes pendentes]*' + CHAR(10) +
                        'Temos pacotes pendentes para as transportadoras abaixo. Acionar time de Dados para verificar atualizacao dos pacotes na db_Irisys_Json.dbo.tb_spe_webhook.' + CHAR(10) + CHAR(10) +
                        @coleta + CHAR(10) + CHAR(10);

        RAISERROR(@mensagem, 16, 1);
    END
END
GO
