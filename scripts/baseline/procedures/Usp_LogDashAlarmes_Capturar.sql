-- ============================================================
-- BASELINE: dbo.Usp_LogDashAlarmes_Capturar
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_LogDashAlarmes_Capturar]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_LogDashAlarmes_Capturar]
    @ApenasEmFalha BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @dh_captura DATETIME2(3) = SYSDATETIME();

    INSERT INTO [dbo].[tb_log_dash_alarmes] (
        [dh_captura],
        [id_transportadora],
        [nm_cliente],
        [nm_alarme],
        [cd_valor],
        [ds_status],
        [qt_falhas],
        [ds_motivo]
    )
    SELECT
        @dh_captura,
        v.[id_transportadora],
        v.[cli_ds_nome],
        v.[TipoAlarme],
        CAST(v.[Valor] AS TINYINT),
        CASE v.[Valor]
            WHEN 0 THEN N'OK'
            WHEN 1 THEN N'Em falha'
            WHEN 2 THEN N'Monitoramento desativado (parâmetro)'
            ELSE N'Desconhecido'
        END,
        CASE WHEN v.[Valor] = 1 THEN 1 ELSE 0 END,
        CASE v.[TipoAlarme]
            WHEN N'ML Coleta Pct' THEN N'Última escrita de coleta de rotas ML com atraso > 15 min ou sem dados.'
            WHEN N'tb_ml lh_rotas' THEN N'Última atualização LH rotas com atraso > 15 min.'
            WHEN N'ML LH ROTAS' THEN N'Última coleta ML_LH_ROUTES com atraso > 15 min.'
            WHEN N'Amb lkr' THEN N'ETL Looker ambulâncias sem atualização no dia anterior ou sem data.'
            WHEN N'PNR Silos' THEN N'Coleta ML_PNR sem registro recente (> 15 min) ou nula.'
            WHEN N'Coleta Rota ML' THEN N'Totalizador ML sem escrita recente (> 15 min) ou nula (após referência configurada).'
            WHEN N'Flex Frota' THEN N'Último evento Flex há mais de 24 h ou inexistente.'
            WHEN N'Sem Rtt' THEN N'Existem rotas com Km RTT nulo (regra OrigemSaida).'
            WHEN N'Cidade Meli' THEN N'Percentual de rotas sem cidade distante acima do limite com coleta antiga.'
            WHEN N'Cidade SPE' THEN N'Mesma regra de cidade para rotas Shopee.'
            WHEN N'Integ Mot' THEN N'Coleta DRIVER_ML fora da janela esperada ou nula.'
            WHEN N'ml pacotes' THEN N'Processamento de pacotes (rotas do dia) com atraso > 15 min ou nulo.'
            WHEN N'Dados Comp.' THEN N'Pacote not_delivered com coleta recente sem dados do comprador.'
            ELSE N'Alarme não mapeado no motivo.'
        END
    FROM [dbo].[vw_dash_alarmes] AS v
    WHERE @ApenasEmFalha = 0
       OR v.[Valor] = 1;
END
 
GO
