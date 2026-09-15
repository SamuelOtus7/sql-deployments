-- ============================================================
-- BASELINE: dbo.vw_pbi_auditoria_km_rotas_v2
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pbi_auditoria_km_rotas_v2]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================================
   vw_pbi_auditoria_km_rotas_v2
   ----------------------------------------------------------------------------
   Versão otimizada de vw_pbi_auditoria_km_rotas focada em KmColetadoFin /
   TipoKmColetado para rotas LM.

   Diferenças estruturais vs. view original:
   - Parte direto de tb_ml_rotas (LM), sem vw_ml_rotas_financeiro/UNION ALL FM
   - pré-fatura: OUTER APPLY TOP 1 (seek na PK) em vez de ROW_NUMBER sobre 3 mi
   - DRA: OUTER APPLY MAX (seek no índice) em vez de GROUP BY sobre 4,3 mi
   - Sem os 9 LEFT JOINs de frete_transportadora e sem SELECT DISTINCT
   - Sem tb_looker_ambulancias, tb_dra_tipo_veiculo, tb_validacao_mapas
   - Parâmetros de KM resolvidos por OUTER APPLY (unique seek em uk_parametros)
   ============================================================================ */
CREATE VIEW [dbo].[vw_pbi_auditoria_km_rotas_v2]
AS
WITH fin AS (
    SELECT
        CAST(r.IdRota AS BIGINT)            AS IdRota,
        r.IdTransportadora,
        r.DataReferencia,
        'LM'                                AS TipoRota,

        ISNULL(TRY_CONVERT(decimal(18,4), r.KmTotal), 0)             AS KmSilosTotal,
        ISNULL(TRY_CONVERT(decimal(18,4), km.pontosAppRotasTotalKm), 0) AS KmAppIrisys,
        ISNULL(TRY_CONVERT(decimal(18,4), km.pontosRotasPacotesKm), 0)   AS KmLatLongPacotes,
        ISNULL(TRY_CONVERT(decimal(18,4), rtt.KmTotal), 0)              AS KmRtt,
        ISNULL(TRY_CONVERT(decimal(18,4), trevo.bkt_vl_km_ideal), 0)    AS KmTrevo,
        ISNULL(TRY_CONVERT(decimal(18,4), dra.KmDraHistorico), 0)       AS KmDraHistorico,
        ISNULL(TRY_CONVERT(decimal(18,4), pre.FimIntervalo), 0)         AS PrefFimIntervalo,

        p1.ParamKmLabel    AS ParamKm1Label,
        p2.ParamKmLabel    AS ParamKm2Label,
        p3.ParamKmLabel    AS ParamKm3Label,
        p4.ParamKmLabel    AS ParamKm4Label,
        ISNULL(pMenor.ParamMenorValorKm, 'false') AS ParamMenorValorKm,

        CASE
            WHEN ISNULL(TRY_CONVERT(decimal(18,4), km.pontosAppRotasTotalKm), 0) = 0 THEN 0
            WHEN ISNULL(TRY_CONVERT(decimal(18,4), dra.KmDraHistorico), 0) = 0 THEN 0
            WHEN CAST(ISNULL(TRY_CONVERT(decimal(18,4), km.pontosAppRotasTotalKm), 0) AS decimal(18,4))
                 / ISNULL(TRY_CONVERT(decimal(18,4), dra.KmDraHistorico), 0) * 100 >= 90
             AND CAST(ISNULL(TRY_CONVERT(decimal(18,4), km.pontosAppRotasTotalKm), 0) AS decimal(18,4))
                 / ISNULL(TRY_CONVERT(decimal(18,4), dra.KmDraHistorico), 0) * 100 <= 110
            THEN 1 ELSE 0
        END AS FlagUsoDevidoFin

    FROM dbo.tb_ml_rotas AS r WITH (NOLOCK)

    INNER JOIN dbo.tb_clientes AS c WITH (NOLOCK)
        ON r.IdTransportadora = c.cli_id_logistics
       AND c.cli_cd_codigo_cliente <> 7

    LEFT JOIN dbo.tb_fin_base_km_trevo AS trevo WITH (NOLOCK)
        ON trevo.bkt_cd_base_km_trevo = r.IdTrevo

    LEFT JOIN dbo.tb_ml_processamento_km_rotas AS km WITH (NOLOCK)
        ON km.idRota = r.IdRota

    LEFT JOIN dbo.tb_ml_bsc_rtt AS rtt WITH (NOLOCK)
        ON rtt.IdRota = r.IdRota
       AND rtt.Ano  = YEAR(r.DataReferencia)
       AND rtt.Mes  = MONTH(r.DataReferencia)
       AND rtt.Quinzena = CASE WHEN DAY(r.DataReferencia) <= 15 THEN 1 ELSE 2 END

    OUTER APPLY (
        SELECT MAX(dhr.dhr_vl_quilometros_percorridos) AS KmDraHistorico
        FROM dbo.tb_dra_historico_rotas AS dhr WITH (NOLOCK)
        WHERE dhr.dhr_cd_cliente = r.IdTransportadora
          AND dhr.dhr_dt_data    = r.DataReferencia
          AND dhr.dhr_nr_rota    = r.IdRota
    ) dra

    OUTER APPLY (
        SELECT TOP 1 pre.FimIntervalo
        FROM dbo.tb_fin_prefatura AS pre WITH (NOLOCK)
        WHERE pre.IdTransportadora = r.IdTransportadora
          AND pre.IdRota = CAST(r.IdRota AS varchar(50))
        ORDER BY pre.DataTermino DESC, pre.DataInicio DESC
    ) pre

    OUTER APPLY (
        SELECT l.lst_ds_label AS ParamKmLabel
        FROM dbo.tb_parametros AS p WITH (NOLOCK)
        INNER JOIN dbo.tb_lista AS l WITH (NOLOCK)
            ON l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
           AND p.prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))
        WHERE p.prm_nm_parametro  = 'Km a ser utilizado.'
          AND p.prm_cod_cliente   = c.cli_cd_codigo_cliente
          AND p.prm_in_ativo      = 1
          AND p.prm_in_excluido   = 0
    ) p1

    OUTER APPLY (
        SELECT l.lst_ds_label AS ParamKmLabel
        FROM dbo.tb_parametros AS p WITH (NOLOCK)
        INNER JOIN dbo.tb_lista AS l WITH (NOLOCK)
            ON l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
           AND p.prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))
        WHERE p.prm_nm_parametro  = 'Km a ser utilizado 2'
          AND p.prm_cod_cliente   = c.cli_cd_codigo_cliente
          AND p.prm_in_ativo      = 1
          AND p.prm_in_excluido   = 0
    ) p2

    OUTER APPLY (
        SELECT l.lst_ds_label AS ParamKmLabel
        FROM dbo.tb_parametros AS p WITH (NOLOCK)
        INNER JOIN dbo.tb_lista AS l WITH (NOLOCK)
            ON l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
           AND p.prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))
        WHERE p.prm_nm_parametro  = 'Km a ser utilizado 3'
          AND p.prm_cod_cliente   = c.cli_cd_codigo_cliente
          AND p.prm_in_ativo      = 1
          AND p.prm_in_excluido   = 0
    ) p3

    OUTER APPLY (
        SELECT l.lst_ds_label AS ParamKmLabel
        FROM dbo.tb_parametros AS p WITH (NOLOCK)
        INNER JOIN dbo.tb_lista AS l WITH (NOLOCK)
            ON l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
           AND p.prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))
        WHERE p.prm_nm_parametro  = 'Km a ser utilizado 4'
          AND p.prm_cod_cliente   = c.cli_cd_codigo_cliente
          AND p.prm_in_ativo      = 1
          AND p.prm_in_excluido   = 0
    ) p4

    OUTER APPLY (
        SELECT LOWER(LTRIM(RTRIM(p.prm_ds_valor))) AS ParamMenorValorKm
        FROM dbo.tb_parametros AS p WITH (NOLOCK)
        WHERE p.prm_nm_parametro  = 'Considerar menor valor entre KM'
          AND p.prm_cod_cliente   = c.cli_cd_codigo_cliente
          AND p.prm_in_ativo      = 1
          AND p.prm_in_excluido   = 0
    ) pMenor

    WHERE r.Excluido    = 0
      AND r.StatusRota <> 'planned'
      AND r.TotalPacotes > 0
)
SELECT
    fin.IdRota,
    fin.IdTransportadora,
    fin.DataReferencia,
    fin.TipoRota,

    CAST(
        CASE
            WHEN ISNULL(COALESCE(
                CASE WHEN fin.ParamMenorValorKm = 'true'
                     AND NULLIF(fk.km_p1, 0) IS NOT NULL
                     AND NULLIF(fk.km_p2, 0) IS NOT NULL
                     AND NULLIF(fk.km_p1, 0) <= NULLIF(fk.km_p2, 0)
                    THEN NULLIF(fk.km_p1, 0)
                    ELSE COALESCE(NULLIF(fk.km_p1, 0), NULLIF(fk.km_p2, 0))
                END,
                NULLIF(fk.km_p3, 0), NULLIF(fk.km_p4, 0)
            ), 0) = 0
            THEN 1
            ELSE COALESCE(
                CASE WHEN fin.ParamMenorValorKm = 'true'
                     AND NULLIF(fk.km_p1, 0) IS NOT NULL
                     AND NULLIF(fk.km_p2, 0) IS NOT NULL
                     AND NULLIF(fk.km_p1, 0) <= NULLIF(fk.km_p2, 0)
                    THEN NULLIF(fk.km_p1, 0)
                    ELSE COALESCE(NULLIF(fk.km_p1, 0), NULLIF(fk.km_p2, 0))
                END,
                NULLIF(fk.km_p3, 0), NULLIF(fk.km_p4, 0))
        END AS decimal(18,4)) AS KmColetadoFin,

    CASE
        WHEN ISNULL(COALESCE(
            CASE WHEN fin.ParamMenorValorKm = 'true'
                 AND NULLIF(fk.km_p1, 0) IS NOT NULL
                 AND NULLIF(fk.km_p2, 0) IS NOT NULL
                 AND NULLIF(fk.km_p1, 0) <= NULLIF(fk.km_p2, 0)
                THEN ft.tipo_km_p1
                ELSE COALESCE(ft.tipo_km_p1, ft.tipo_km_p2)
            END,
            ft.tipo_km_p3, ft.tipo_km_p4), '-') = '-'
        THEN 'Km não coletado. Aplicado Km mínimo.'
        ELSE COALESCE(
            CASE WHEN fin.ParamMenorValorKm = 'true'
                 AND NULLIF(fk.km_p1, 0) IS NOT NULL
                 AND NULLIF(fk.km_p2, 0) IS NOT NULL
                 AND NULLIF(fk.km_p1, 0) <= NULLIF(fk.km_p2, 0)
                THEN ft.tipo_km_p1
                ELSE COALESCE(ft.tipo_km_p1, ft.tipo_km_p2)
            END,
            ft.tipo_km_p3, ft.tipo_km_p4)
    END AS TipoKmColetado

FROM fin
CROSS APPLY (
    SELECT
        CASE
            WHEN fin.ParamKm1Label = 'KM do app Irisys' AND fin.FlagUsoDevidoFin = 1
                THEN NULLIF(CAST(fin.KmAppIrisys AS decimal(18,4)), 0)
            WHEN fin.ParamKm1Label = 'KM do app Irisys' AND fin.FlagUsoDevidoFin = 0
                THEN CAST(NULL AS decimal(18,4))
            ELSE NULLIF(CASE fin.ParamKm1Label
                WHEN 'KM do app Irisys' THEN CAST(fin.KmAppIrisys AS decimal(18,4))
                WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(fin.KmLatLongPacotes AS decimal(18,4))
                WHEN 'Km por trevo a trevo' THEN CAST(fin.KmTrevo AS decimal(18,4))
                WHEN 'Km do RTT' THEN CAST(fin.KmRtt AS decimal(18,4))
                WHEN 'Faixa km da prefatura' THEN CAST(fin.PrefFimIntervalo AS decimal(18,4))
                WHEN 'Km coletado do Silos' THEN CAST(fin.KmSilosTotal AS decimal(18,4))
                WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                    CAST(CASE WHEN ISNULL(fin.KmAppIrisys,0)=0 THEN fin.KmLatLongPacotes ELSE fin.KmAppIrisys END AS decimal(18,4))
                WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN CAST(fin.KmDraHistorico AS decimal(18,4))
                ELSE NULL END, 0)
        END AS km_p1,
        NULLIF(CASE fin.ParamKm2Label
            WHEN 'KM do app Irisys' THEN CAST(fin.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(fin.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(fin.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(fin.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(fin.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(fin.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(CASE WHEN ISNULL(fin.KmAppIrisys,0)=0 THEN fin.KmLatLongPacotes ELSE fin.KmAppIrisys END AS decimal(18,4))
            WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN CAST(fin.KmDraHistorico AS decimal(18,4))
            ELSE NULL END, 0) AS km_p2,
        NULLIF(CASE fin.ParamKm3Label
            WHEN 'KM do app Irisys' THEN CAST(fin.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(fin.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(fin.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(fin.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(fin.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(fin.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(CASE WHEN ISNULL(fin.KmAppIrisys,0)=0 THEN fin.KmLatLongPacotes ELSE fin.KmAppIrisys END AS decimal(18,4))
            WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN CAST(fin.KmDraHistorico AS decimal(18,4))
            ELSE NULL END, 0) AS km_p3,
        NULLIF(CASE fin.ParamKm4Label
            WHEN 'KM do app Irisys' THEN CAST(fin.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(fin.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(fin.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(fin.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(fin.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(fin.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(CASE WHEN ISNULL(fin.KmAppIrisys,0)=0 THEN fin.KmLatLongPacotes ELSE fin.KmAppIrisys END AS decimal(18,4))
            WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN CAST(fin.KmDraHistorico AS decimal(18,4))
            ELSE NULL END, 0) AS km_p4
) fk
CROSS APPLY (
    SELECT
        CASE
            WHEN fin.ParamKm1Label = 'KM do app Irisys' AND fin.FlagUsoDevidoFin = 1 THEN 'KM do app Irisys'
            WHEN fin.ParamKm1Label = 'KM do app Irisys' AND fin.FlagUsoDevidoFin = 0 THEN NULL
            ELSE NULLIF(CASE fin.ParamKm1Label
                WHEN 'KM do app Irisys' THEN 'KM do app Irisys'
                WHEN 'KM latitude e longetude dos Pacotes' THEN 'KM latitude e longetude dos Pacotes'
                WHEN 'Km por trevo a trevo' THEN 'Km por trevo a trevo'
                WHEN 'Km do RTT' THEN 'Km do RTT'
                WHEN 'Faixa km da prefatura' THEN 'Faixa km da prefatura'
                WHEN 'Km coletado do Silos' THEN 'Km coletado do Silos'
                WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN 'Km do app Irisys ou KM lat e long dos pacotes.'
                WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN 'Km de contingencia coletado de tb_dra_historico_rotas'
                ELSE NULL END, '-')
        END AS tipo_km_p1,
        NULLIF(CASE fin.ParamKm2Label
            WHEN 'KM do app Irisys' THEN 'KM do app Irisys'
            WHEN 'KM latitude e longetude dos Pacotes' THEN 'KM latitude e longetude dos Pacotes'
            WHEN 'Km por trevo a trevo' THEN 'Km por trevo a trevo'
            WHEN 'Km do RTT' THEN 'Km do RTT'
            WHEN 'Faixa km da prefatura' THEN 'Faixa km da prefatura'
            WHEN 'Km coletado do Silos' THEN 'Km coletado do Silos'
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN 'Km do app Irisys ou KM lat e long dos pacotes.'
            WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN 'Km de contingencia coletado de tb_dra_historico_rotas'
            ELSE NULL END, '-') AS tipo_km_p2,
        NULLIF(CASE fin.ParamKm3Label
            WHEN 'KM do app Irisys' THEN 'KM do app Irisys'
            WHEN 'KM latitude e longetude dos Pacotes' THEN 'KM latitude e longetude dos Pacotes'
            WHEN 'Km por trevo a trevo' THEN 'Km por trevo a trevo'
            WHEN 'Km do RTT' THEN 'Km do RTT'
            WHEN 'Faixa km da prefatura' THEN 'Faixa km da prefatura'
            WHEN 'Km coletado do Silos' THEN 'Km coletado do Silos'
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN 'Km do app Irisys ou KM lat e long dos pacotes.'
            WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN 'Km de contingencia coletado de tb_dra_historico_rotas'
            ELSE NULL END, '-') AS tipo_km_p3,
        NULLIF(CASE fin.ParamKm4Label
            WHEN 'KM do app Irisys' THEN 'KM do app Irisys'
            WHEN 'KM latitude e longetude dos Pacotes' THEN 'KM latitude e longetude dos Pacotes'
            WHEN 'Km por trevo a trevo' THEN 'Km por trevo a trevo'
            WHEN 'Km do RTT' THEN 'Km do RTT'
            WHEN 'Faixa km da prefatura' THEN 'Faixa km da prefatura'
            WHEN 'Km coletado do Silos' THEN 'Km coletado do Silos'
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN 'Km do app Irisys ou KM lat e long dos pacotes.'
            WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN 'Km de contingencia coletado de tb_dra_historico_rotas'
            ELSE NULL END, '-') AS tipo_km_p4
) ft;
GO
