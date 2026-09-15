-- ============================================================
-- BASELINE: dbo.usp_fin_TrataDadosUploadSpe
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_fin_TrataDadosUploadSpe]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[usp_fin_TrataDadosUploadSpe]
AS
BEGIN
    SET NOCOUNT ON;

    -- Remove a temporária se já existir
    IF OBJECT_ID('tempdb..#ValoresExtraidos') IS NOT NULL
        DROP TABLE #ValoresExtraidos;

    -- Cria a tabela temporária com o campo original ValorAjudante
    CREATE TABLE #ValoresExtraidos (
        Rota VARCHAR(100),
		NomeTransportadora Varchar(100),
        PeriodoAnoMesQuinzena VARCHAR(20),
        TrackingNumber VARCHAR(100),
		hub			VARCHAR(255),
		operacao	VARCHAR(100),
        ValorAjudante VARCHAR(MAX),
        vl_valor_ajudante varchar(100),
        vl_valor_incentivo varchar(100),
        flg_risco varchar(100)
    );

    -- Insere os dados extraídos na temporária
    INSERT INTO #ValoresExtraidos (
        Rota,
		NomeTransportadora,
        PeriodoAnoMesQuinzena,
        TrackingNumber,
		Hub,
		operacao,
        ValorAjudante,
        vl_valor_ajudante,
        vl_valor_incentivo,
        flg_risco
    )
    SELECT
        tb.Rota,
		tb.NomeTransportadora,
        tb.PeriodoAnoMesQuinzena,
        tb.TrackingNumber,
		tb.hub,
		tb.operacao,
        tb.ValorAjudante,
        TRY_CAST(LTRIM(RTRIM(SUBSTRING(tb.ValorAjudante, 
            CHARINDEX('Valor ajudante:', tb.ValorAjudante) + LEN('Valor ajudante:'), 
            CHARINDEX(';', tb.ValorAjudante) - CHARINDEX('Valor ajudante:', tb.ValorAjudante) - LEN('Valor ajudante:')))) AS DECIMAL(18,2)),

        TRY_CAST(LTRIM(RTRIM(SUBSTRING(tb.ValorAjudante,
            CHARINDEX('Valor incentivo:', tb.ValorAjudante) + LEN('Valor incentivo:'), 
            CHARINDEX(';', tb.ValorAjudante, CHARINDEX('Valor incentivo:', tb.ValorAjudante)) 
                - CHARINDEX('Valor incentivo:', tb.ValorAjudante) - LEN('Valor incentivo:')))) AS DECIMAL(18,2)),

        TRY_CAST(LTRIM(RTRIM(SUBSTRING(tb.ValorAjudante,
            CHARINDEX('Flag Risco:', tb.ValorAjudante) + LEN('Flag Risco:'), 
            LEN(tb.ValorAjudante)))) AS INT)
    FROM tb_fin_spe_prefatura_upload tb
    WHERE 
        tb.ValorAjudante IS NOT NULL
        AND tb.ValorAjudante LIKE '%Valor ajudante:%'
        AND tb.ValorAjudante LIKE '%Valor incentivo:%'
        AND tb.ValorAjudante LIKE '%Flag Risco:%'
		--and NomeTransportadora = '1329461926'
		--and rota = 'AT202503141JD3C' and TrackingNumber = 'BR254961923475O'

    -- Atualiza os campos direto na tabela original
    UPDATE tb
    SET 
        tb.Valorajudante = tmp.vl_valor_ajudante,
        tb.Valorincentivo = tmp.vl_valor_incentivo,
        tb.FlagRisco = tmp.flg_risco
    FROM tb_fin_spe_prefatura_upload tb
    INNER JOIN #ValoresExtraidos tmp
        ON tb.Rota = tmp.Rota
        AND tb.PeriodoAnoMesQuinzena = tmp.PeriodoAnoMesQuinzena
        AND tb.TrackingNumber = tmp.TrackingNumber
		AND tb.NomeTransportadora = tmp.NomeTransportadora
		AND tb.hub = tmp.hub
		and tb.operacao = tmp.operacao

	

END

GO
