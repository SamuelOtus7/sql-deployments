-- ============================================================
-- BASELINE: dbo.usp_pgto_vs_recebimento_cliente
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_pgto_vs_recebimento_cliente]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_pgto_vs_recebimento_cliente]
    @pgp_cd_periodo INT
AS
BEGIN
    SET NOCOUNT ON;

    DROP TABLE IF EXISTS #rotas_periodo;

    SELECT
        ppr.ppr_cd_rota,
        TRY_CAST(ppr.ppr_cd_rota AS bigint) AS ppr_cd_rota_num,
        ppr.ppr_data_referencia,
        ppr.ppr_vl_base,
        ppr.ppr_vl_total
    INTO #rotas_periodo
    FROM dbo.tb_pgto_periodo_rota ppr
    WHERE ppr.ppr_cd_periodo = @pgp_cd_periodo;

    CREATE CLUSTERED INDEX IX_rotas_periodo_num_data
        ON #rotas_periodo (ppr_cd_rota_num, ppr_data_referencia);

    CREATE NONCLUSTERED INDEX IX_rotas_periodo_rota_str
        ON #rotas_periodo (ppr_cd_rota)
        INCLUDE (ppr_vl_base, ppr_vl_total, ppr_data_referencia);

    SELECT
        @pgp_cd_periodo                       AS periodo_codigo,
        pf.IdRota                             AS rota,
        km.CidadeDistante                     AS cidade,
        rp.ppr_vl_base                        AS vl_pago_rota,
        rp.ppr_vl_total                       AS vl_pago_total,
        pf.Total                              AS vl_receber_cliente,
        (pf.Total - rp.ppr_vl_base)           AS delta_rota,
        (pf.Total - rp.ppr_vl_total)          AS delta_total,
        km.DeltaFaixa_AppIrisys               AS delta_faixa_app,
        km.DeltaFaixa_LatLongPacotes          AS delta_faixa_latlong,
        CASE
            WHEN km.FlagUsoDevidoFin = 0
                THEN km.DeltaFaixa_LatLongPacotes
            ELSE km.DeltaFaixa_AppIrisys
        END                                   AS delta_faixa_pagamento
    FROM #rotas_periodo            rp
    JOIN dbo.tb_fin_prefatura      pf  ON pf.IdRota = rp.ppr_cd_rota
    JOIN dbo.vw_pbi_auditoria_km_rotas km
                                      ON km.IdRota = rp.ppr_cd_rota_num
                                      AND km.DataReferencia = rp.ppr_data_referencia
    ORDER BY pf.IdRota;

    DROP TABLE IF EXISTS #rotas_periodo;
END
GO
