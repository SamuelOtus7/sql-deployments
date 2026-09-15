-- ============================================================
-- BASELINE: dbo.USPPgtoVsRecebimento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[USPPgtoVsRecebimento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[USPPgtoVsRecebimento]
AS
BEGIN
    SET NOCOUNT ON;

    -- Fase 1: isolar períodos dos últimos 2 meses
    DROP TABLE IF EXISTS #periodos_recentes;

    SELECT pgp_cd_periodo, pgp_dt_inicio, pgp_dt_fim
    INTO #periodos_recentes
    FROM dbo.tb_pgto_periodo
    WHERE pgp_dt_inicio >= DATEADD(month, -2, GETDATE())
      AND pgp_in_excluido = 0;

    CREATE CLUSTERED INDEX IX_periodos_recentes
        ON #periodos_recentes (pgp_cd_periodo);

    -- Fase 1b: isolar rotas dos períodos
    DROP TABLE IF EXISTS #rotas_periodo;

    SELECT
         ppr.ppr_cd_periodo
        ,ppr.ppr_cd_rota
        ,TRY_CAST(ppr.ppr_cd_rota AS bigint) AS ppr_cd_rota_num
        ,ppr.ppr_vl_base
        ,ppr.ppr_vl_paradas
        ,ppr.ppr_vl_pontos
        ,ppr.ppr_vl_risco
        ,ppr.ppr_vl_ajudante
        ,ppr.ppr_vl_dom_fer
        ,ppr.ppr_vl_lancamentos
        ,ppr.ppr_vl_pedagio
        ,ppr.ppr_vl_aluguel
        ,ppr.ppr_vl_desconto
        ,ppr.ppr_vl_recarga
        ,ppr.ppr_vl_pacotes
        ,ppr.ppr_vl_bonus
        ,ppr.ppr_vl_adicional_KM
        ,ppr.ppr_vl_bonus_ds
        ,ppr.ppr_vl_total
        ,ppr.ppr_ds_tipo_veiculo
    INTO #rotas_periodo
    FROM dbo.tb_pgto_periodo_rota ppr
    INNER JOIN #periodos_recentes pr ON pr.pgp_cd_periodo = ppr.ppr_cd_periodo
    WHERE TRY_CAST(ppr.ppr_cd_rota AS bigint) IS NOT NULL;

    CREATE CLUSTERED INDEX IX_rotas_periodo_num
        ON #rotas_periodo (ppr_cd_rota_num);

    CREATE NONCLUSTERED INDEX IX_rotas_periodo_str
        ON #rotas_periodo (ppr_cd_rota)
        INCLUDE (ppr_cd_periodo, ppr_vl_base, ppr_vl_total, ppr_ds_tipo_veiculo);

    -- Fase 2: pré-filtrar a view por range de datas dos períodos
    DECLARE @dt_inicio DATE, @dt_fim DATE;
    SELECT @dt_inicio = MIN(pgp_dt_inicio), @dt_fim = MAX(pgp_dt_fim)
    FROM #periodos_recentes;

    DROP TABLE IF EXISTS #view_periodo;

    SELECT
        km.IdRota,
        km.ServiceCenter,
        km.DataReferencia,
        km.CidadeDistante,
        km.DeltaFaixa_AppIrisys,
        km.DeltaFaixa_LatLongPacotes,
        km.PrefIntervaloFaixa,
        km.FlagUsoDevidoFin,
        km.FaixaKmAppIrisys,
        km.FaixaKMLatLongPacotes
    INTO #view_periodo
    FROM dbo.vw_pbi_auditoria_km_rotas km
    WHERE km.DataReferencia BETWEEN @dt_inicio AND @dt_fim;

    CREATE CLUSTERED INDEX IX_view_periodo_rota
        ON #view_periodo (IdRota);

    -- Fase 3 + 4: JOINs a partir dos conjuntos já filtrados
    SELECT
        rp.ppr_cd_periodo                        AS periodo_codigo
        ,km.ServiceCenter                        AS Base
        ,pf.IdRota                               AS rota
        ,km.CidadeDistante                       AS cidade
        ,rp.ppr_ds_tipo_veiculo                  AS tipo_veiculo
        ,isnull(rp.ppr_vl_base         ,0)       AS vl_rota
        ,isnull(rp.ppr_vl_paradas      ,0)       AS vl_adicional_paradas
        ,isnull(rp.ppr_vl_pontos       ,0)       AS vl_adicional_pontos
        ,isnull(rp.ppr_vl_risco        ,0)       AS vl_risco
        ,isnull(rp.ppr_vl_ajudante     ,0)       AS vl_ajudante
        ,isnull(rp.ppr_vl_dom_fer      ,0)       AS vl_adicional_domfer
        ,isnull(rp.ppr_vl_lancamentos  ,0)       AS vl_lancamento_manual
        ,isnull(rp.ppr_vl_pedagio      ,0)       AS vl_pedagio
        ,isnull(rp.ppr_vl_aluguel      ,0)       AS vl_aluguel
        ,isnull(rp.ppr_vl_desconto     ,0)       AS vl_desconto
        ,isnull(rp.ppr_vl_recarga      ,0)       AS vl_recarga
        ,isnull(rp.ppr_vl_pacotes      ,0)       AS vl_adicional_pacotes
        ,isnull(rp.ppr_vl_bonus        ,0)       AS vl_bonus
        ,isnull(rp.ppr_vl_adicional_KM ,0)       AS vl_adicional_km
        ,isnull(rp.ppr_vl_bonus_ds     ,0)       AS vl_bonus_ds
        ,isnull(rp.ppr_vl_total        ,0)       AS vl_pago_total
        ,pf.Total                                AS vl_receber_cliente
        ,(pf.Total - rp.ppr_vl_base)             AS delta_rota
        ,(pf.Total - rp.ppr_vl_total)            AS delta_total
        ,km.PrefIntervaloFaixa                   AS PrefIntervaloFaixa
        ,CASE
            WHEN km.FlagUsoDevidoFin = 0
                THEN km.FaixaKMLatLongPacotes
            ELSE km.FaixaKmAppIrisys
        END                                      AS faixa_pagamento
        ,CASE
            WHEN km.FlagUsoDevidoFin = 0
                THEN km.DeltaFaixa_LatLongPacotes
            ELSE km.DeltaFaixa_AppIrisys
        END                                      AS delta_faixa_pagamento
    FROM #rotas_periodo       rp
    JOIN dbo.tb_fin_prefatura pf  ON pf.IdRota = rp.ppr_cd_rota
    JOIN #view_periodo        km  ON km.IdRota = rp.ppr_cd_rota_num
    ORDER BY rp.ppr_cd_periodo, pf.IdRota;

    DROP TABLE IF EXISTS #periodos_recentes;
    DROP TABLE IF EXISTS #rotas_periodo;
    DROP TABLE IF EXISTS #view_periodo;
END
GO
