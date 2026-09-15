-- ============================================================
-- BASELINE: dbo.vw_pbi_pgto_vs_receb
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pbi_pgto_vs_receb]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_pbi_pgto_vs_receb]
AS
WITH periodos_recentes AS (
    SELECT
        pgp_cd_periodo,
        pgp_dt_inicio,
        pgp_dt_fim
    FROM dbo.tb_pgto_periodo
    WHERE pgp_dt_inicio >= DATEADD(month, -2, GETDATE())
      AND pgp_in_excluido = 0
),
range_datas AS (
    SELECT
        MIN(pgp_dt_inicio) AS dt_inicio,
        MAX(pgp_dt_fim)    AS dt_fim
    FROM periodos_recentes
),
rotas_periodo AS (
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
        ,pr.pgp_dt_inicio                                   AS ppr_dt_periodo_inicio
        ,YEAR(pr.pgp_dt_inicio)                              AS ppr_nu_ano
        ,MONTH(pr.pgp_dt_inicio)                             AS ppr_nu_mes
        ,CASE WHEN DAY(pr.pgp_dt_inicio) <= 15 THEN 1 ELSE 2 END AS ppr_nu_quinzena
    FROM dbo.tb_pgto_periodo_rota ppr
    INNER JOIN periodos_recentes pr ON pr.pgp_cd_periodo = ppr.ppr_cd_periodo
    WHERE TRY_CAST(ppr.ppr_cd_rota AS bigint) IS NOT NULL
),
view_filtrada AS (
    SELECT
        km.IdRota
        ,km.ServiceCenter
        ,km.DataReferencia
        ,km.CidadeDistante
        ,km.DeltaFaixa_AppIrisys
        ,km.DeltaFaixa_LatLongPacotes
        ,km.PrefIntervaloFaixa
        ,km.FlagUsoDevidoFin
        ,km.FaixaKmAppIrisys
        ,km.FaixaKMLatLongPacotes
    FROM dbo.vw_pbi_auditoria_km_rotas km
    CROSS JOIN range_datas rd
    WHERE km.DataReferencia BETWEEN rd.dt_inicio AND rd.dt_fim
),
periodos_ref AS (
    SELECT DISTINCT
         YEAR(pgp_dt_inicio)                                  AS ano
        ,MONTH(pgp_dt_inicio)                                 AS mes
        ,CASE WHEN DAY(pgp_dt_inicio) <= 15 THEN 1 ELSE 2 END AS quinzena
    FROM periodos_recentes
),
complementar_agg AS (
    SELECT
         pfc.pfc_cd_transportadora
        ,pfc.pfc_nu_ano
        ,pfc.pfc_nu_mes
        ,pfc.pfc_nu_quinzena
        ,pfc.pfc_cd_rota
        ,SUM(pfc.pfc_vl_servico) AS vl_complementar
    FROM dbo.tb_fin_prefatura_complementar pfc
    WHERE EXISTS (
        SELECT 1
        FROM periodos_ref pr2
        WHERE pr2.ano      = pfc.pfc_nu_ano
          AND pr2.mes      = pfc.pfc_nu_mes
          AND pr2.quinzena = pfc.pfc_nu_quinzena
    )
    GROUP BY
         pfc.pfc_cd_transportadora
        ,pfc.pfc_nu_ano
        ,pfc.pfc_nu_mes
        ,pfc.pfc_nu_quinzena
        ,pfc.pfc_cd_rota
)
SELECT
    rp.ppr_cd_periodo                        AS periodo_codigo
    ,case when kmciclo = 'AMBULANCE' then 'Sim' else 'Não' end AS Ambulancia
    ,km.ServiceCenter                        AS Base
    ,pf.IdRota                               AS rota
    ,km.CidadeDistante                       AS cidade
    ,Veiculo   AS tipo_veiculo
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
    ,isnull(ca.vl_complementar     ,0)       AS vl_complementar
    ,(pf.Total + isnull(ca.vl_complementar,0)) AS vl_receber_total
    ,(pf.Total - rp.ppr_vl_base)             AS delta_rota
    ,(pf.Total - rp.ppr_vl_total)            AS delta_total
    ,((pf.Total + isnull(ca.vl_complementar,0)) - rp.ppr_vl_total) AS delta_total_c
    ,case when kmciclo = 'AMBULANCE' then 'Ambulância' else km.PrefIntervaloFaixa end AS PrefIntervaloFaixa
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
FROM rotas_periodo       rp
JOIN dbo.tb_fin_prefatura pf  ON pf.IdRota = rp.ppr_cd_rota
JOIN view_filtrada        km  ON km.IdRota = rp.ppr_cd_rota_num
LEFT JOIN complementar_agg ca
       ON ca.pfc_cd_transportadora = pf.IdTransportadora
      AND ca.pfc_cd_rota            = pf.IdRota
      AND ca.pfc_nu_ano             = rp.ppr_nu_ano
      AND ca.pfc_nu_mes             = rp.ppr_nu_mes
      AND ca.pfc_nu_quinzena        = rp.ppr_nu_quinzena;
GO
