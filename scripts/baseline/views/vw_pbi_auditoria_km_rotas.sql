-- ============================================================
-- BASELINE: dbo.vw_pbi_auditoria_km_rotas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pbi_auditoria_km_rotas]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [dbo].[vw_pbi_auditoria_km_rotas]
AS

WITH prefatura_unica AS (
    SELECT
        pre.IdTransportadora,
        pre.IdRota,
        pre.InicioIntervalo,
        pre.FimIntervalo,
        pre.IntervaloFaixa,
        ROW_NUMBER() OVER (
            PARTITION BY pre.IdTransportadora, pre.IdRota
            ORDER BY pre.DataTermino DESC, pre.DataInicio DESC
        ) AS rn
    FROM dbo.tb_fin_prefatura AS pre WITH (NOLOCK)
),
dra_km AS (
    SELECT
        dhr.dhr_nr_rota,
        dhr.dhr_cd_cliente,
        dhr.dhr_dt_data,
        MAX(dhr.dhr_vl_quilometros_percorridos) AS KmDraHistorico
    FROM dbo.tb_dra_historico_rotas AS dhr WITH (NOLOCK)
    GROUP BY
        dhr.dhr_nr_rota,
        dhr.dhr_cd_cliente,
        dhr.dhr_dt_data
),
frete_transportadora AS (
    select 
        *
        ,ROW_NUMBER() over(
            partition by
                bft_cd_transportadora,
                bft_cd_service_center,
                bft_cd_tipo_veiculo
            order by
                bft_vl_inicio_faixa
        ) as OrdemFaixa  
    from vw_fin_base_frete_transportadora
    where bft_estado is null
),
base AS (
    SELECT
        CAST(r.IdRota AS BIGINT) AS IdRota,
        r.DataReferencia,
        r.TipoRota,
        r.IdTransportadora,
        c.cli_cd_codigo_cliente AS TenantId,
        r.ServiceCenter AS ServiceCenterOrigem,
        CASE
            WHEN NULLIF(LTRIM(RTRIM(r.OrigemSaida)), '') IS NOT NULL
             AND r.ServiceCenter <> r.OrigemSaida
            THEN r.OrigemSaida
            ELSE r.ServiceCenter
        END AS ServiceCenter,
        r.Placa,
        r.NomeMotorista,
        r.TipoVeiculo,
        r.StatusRota,
        ml.CidadeDistante,

        ISNULL(r.TotalPacotes, 0) as TotalPacotes,
        ISNULL(r.PacotesEntregues, 0) AS PacotesEntregues,
        ISNULL(r.PacotesNaoEntregue, 0) as PacotesNaoEntregue,
        ISNULL(r.PacotesPendentes, 0) as PacotesPendentes,
        ISNULL(r.PacotesTransferidos, 0) as PacotesTransferidos,

        CASE
            WHEN ISNULL(r.PacotesEntregues, 0) > 0
            THEN 1
            ELSE 0
        END AS FlagRotaComEntrega,

        /* KM por fonte — LM */
        CASE
            WHEN r.TipoRota = 'LM'
            THEN ISNULL(TRY_CONVERT(decimal(18, 4), r.KmTotal), 0)
            ELSE 0
        END AS KmSilosTotal,

        CASE
            WHEN r.TipoRota = 'LM'
            THEN ISNULL(TRY_CONVERT(decimal(18, 4), r.KmLogistics), 0)
            ELSE 0
        END AS KmSilosLogistics,

        CASE
            WHEN r.TipoRota = 'LM'
            THEN ISNULL(TRY_CONVERT(decimal(18, 4), km.pontosAppRotasTotalKm), 0)
            ELSE 0
        END AS KmAppIrisys,

        CASE
            WHEN r.TipoRota = 'LM'
            THEN ISNULL(TRY_CONVERT(decimal(18, 4), km.pontosRotasPacotesKm), 0)
            ELSE 0
        END AS KmLatLongPacotes,

        CASE
            WHEN r.TipoRota = 'LM'
            THEN ISNULL(TRY_CONVERT(decimal(18, 4), rtt.KmTotal), 0)
            ELSE 0
        END AS KmRtt,

        CASE
            WHEN r.TipoRota = 'LM'
            THEN ISNULL(TRY_CONVERT(decimal(18, 4), maps.vmp_kmpagamento), 0)
            ELSE 0
        END AS KmValidacaoMapas,

        CASE
            WHEN r.TipoRota = 'LM'
            THEN ISNULL(TRY_CONVERT(decimal(18, 4), dra.KmDraHistorico), 0)
            ELSE 0
        END AS KmDraHistorico,

        CASE
            WHEN r.TipoRota = 'LM'
            THEN ISNULL(TRY_CONVERT(decimal(18, 4), trevo.bkt_vl_km_ideal), 0)
            ELSE 0
        END AS KmTrevo,

        bkt_ds_link_google as LinkTrevo,


        /* KM FM */
        --CASE WHEN r.TipoRota = 'FM' THEN ISNULL(r.KmTotal, 0) ELSE 0 END AS KmFmPercorrido,

        /* Prefatura — faixa informativa */
        ISNULL(TRY_CONVERT(decimal(18, 4), pre.InicioIntervalo), 0) AS PrefInicioIntervalo,
        ISNULL(TRY_CONVERT(decimal(18, 4), pre.FimIntervalo), 0) AS PrefFimIntervalo,

        ISNULL(
            NULLIF(
                LTRIM(RTRIM(pre.IntervaloFaixa)),
                ''
            ),
            CASE
                WHEN pre.InicioIntervalo IS NOT NULL
                 AND pre.FimIntervalo IS NOT NULL
                THEN
                    CAST(pre.InicioIntervalo AS VARCHAR(20))
                    + '/'
                    + CAST(pre.FimIntervalo AS VARCHAR(20))
                ELSE ''
            END
        ) AS PrefIntervaloFaixa,

        /* Parâmetros de KM do cliente */
        p1.ParamKmLabel AS ParamKm1Label,
        p2.ParamKmLabel AS ParamKm2Label,
        p3.ParamKmLabel AS ParamKm3Label,
        p4.ParamKmLabel AS ParamKm4Label,
        ISNULL(pMenor.ParamMenorValorKm, 'false') AS ParamMenorValorKm,
        ISNULL(pMinimo.ParamKmMinimo, 'false') AS ParamKmMinimo,
        r.Ciclo_Novo

    FROM dbo.vw_ml_rotas_financeiro AS r WITH (NOLOCK)

    INNER JOIN dbo.tb_clientes AS c WITH (NOLOCK)
        ON r.IdTransportadora = c.cli_id_logistics
       AND c.cli_cd_codigo_cliente <> 7

    LEFT JOIN dbo.tb_ml_rotas AS ml WITH (NOLOCK)
        ON r.TipoRota = 'LM'
       AND r.IdRota = ml.IdRota
       AND ml.Excluido = 0
       AND ml.StatusRota <> 'planned' 

    LEFT JOIN tb_fin_base_km_trevo as trevo
        ON bkt_cd_base_km_trevo = ml.IdTrevo

    LEFT JOIN dbo.tb_ml_processamento_km_rotas AS km WITH (NOLOCK)
        ON r.TipoRota = 'LM'
       AND km.idrota = r.IdRota

    LEFT JOIN dbo.tb_ml_bsc_rtt AS rtt WITH (NOLOCK)
        ON r.TipoRota = 'LM'
       AND rtt.IdRota = r.IdRota
       AND rtt.Ano = YEAR(r.DataReferencia)
       AND rtt.Mes = MONTH(r.DataReferencia)
       AND rtt.Quinzena =
            CASE
                WHEN DAY(r.DataReferencia) <= 15 THEN 1
                ELSE 2
            END

    LEFT JOIN dbo.tb_validacao_mapas AS maps WITH (NOLOCK)
        ON r.TipoRota = 'LM'
       AND maps.vmp_cd_rota = r.IdRota

    LEFT JOIN dra_km AS dra
        ON r.IdRota = dra.dhr_nr_rota
       AND r.IdTransportadora = dra.dhr_cd_cliente
       AND r.DataReferencia = dra.dhr_dt_data

    LEFT JOIN prefatura_unica AS pre
        ON pre.rn = 1
       AND pre.IdRota = r.IdRota
       AND pre.IdTransportadora = r.IdTransportadora

    OUTER APPLY (
        SELECT
            l.lst_ds_label AS ParamKmLabel
        FROM dbo.tb_parametros AS p WITH (NOLOCK)
        INNER JOIN dbo.tb_lista AS l WITH (NOLOCK)
            ON l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
           AND p.prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))
        WHERE p.prm_nm_parametro = 'Km a ser utilizado.'
          AND p.prm_cod_cliente = c.cli_cd_codigo_cliente
          AND p.prm_in_ativo = 1
          AND p.prm_in_excluido = 0
    ) AS p1

    OUTER APPLY (
        SELECT
            l.lst_ds_label AS ParamKmLabel
        FROM dbo.tb_parametros AS p WITH (NOLOCK)
        INNER JOIN dbo.tb_lista AS l WITH (NOLOCK)
            ON l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
           AND p.prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))
        WHERE p.prm_nm_parametro = 'Km a ser utilizado 2'
          AND p.prm_cod_cliente = c.cli_cd_codigo_cliente
          AND p.prm_in_ativo = 1
          AND p.prm_in_excluido = 0
    ) AS p2

    OUTER APPLY (
        SELECT
            l.lst_ds_label AS ParamKmLabel
        FROM dbo.tb_parametros AS p WITH (NOLOCK)
        INNER JOIN dbo.tb_lista AS l WITH (NOLOCK)
            ON l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
           AND p.prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))
        WHERE p.prm_nm_parametro = 'Km a ser utilizado 3'
          AND p.prm_cod_cliente = c.cli_cd_codigo_cliente
          AND p.prm_in_ativo = 1
          AND p.prm_in_excluido = 0
    ) AS p3

    OUTER APPLY (
        SELECT
            l.lst_ds_label AS ParamKmLabel
        FROM dbo.tb_parametros AS p WITH (NOLOCK)
        INNER JOIN dbo.tb_lista AS l WITH (NOLOCK)
            ON l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
           AND p.prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))
        WHERE p.prm_nm_parametro = 'Km a ser utilizado 4'
          AND p.prm_cod_cliente = c.cli_cd_codigo_cliente
          AND p.prm_in_ativo = 1
          AND p.prm_in_excluido = 0
    ) AS p4

    OUTER APPLY (
        SELECT
            LOWER(LTRIM(RTRIM(p.prm_ds_valor))) AS ParamMenorValorKm
        FROM dbo.tb_parametros AS p WITH (NOLOCK)
        WHERE p.prm_nm_parametro = 'Considerar menor valor entre KM'
          AND p.prm_cod_cliente = c.cli_cd_codigo_cliente
          AND p.prm_in_ativo = 1
          AND p.prm_in_excluido = 0
    ) AS pMenor

    OUTER APPLY (
        SELECT
            LOWER(LTRIM(RTRIM(p.prm_ds_valor))) AS ParamKmMinimo
        FROM dbo.tb_parametros AS p WITH (NOLOCK)
        WHERE p.prm_nm_parametro = 'Aplicar Km mínimo'
          AND p.prm_cod_cliente = c.cli_cd_codigo_cliente
          AND p.prm_in_ativo = 1
          AND p.prm_in_excluido = 0
    ) AS pMinimo

    /* Filtro de data removido: PBI aplica filtro no relatório;
       UspFinOrigemRotas precisa de histórico completo para períodos de pagamento. */
)

SELECT
    fin.*,

    CAST(
        CASE
            WHEN ISNULL(
                COALESCE(
                    CASE
                        WHEN fin.ParamMenorValorKm = 'true'
                         AND NULLIF(fin_km.km_p1, 0) IS NOT NULL
                         AND NULLIF(fin_km.km_p2, 0) IS NOT NULL
                         AND NULLIF(fin_km.km_p1, 0) <= NULLIF(fin_km.km_p2, 0)
                        THEN NULLIF(fin_km.km_p1, 0)
                        ELSE COALESCE(NULLIF(fin_km.km_p1, 0), NULLIF(fin_km.km_p2, 0))
                    END,
                    NULLIF(fin_km.km_p3, 0),
                    NULLIF(fin_km.km_p4, 0)
                ), 0) = 0
            THEN 1 --Km Minimo
            ELSE COALESCE(
                    CASE
                        WHEN fin.ParamMenorValorKm = 'true'
                         AND NULLIF(fin_km.km_p1, 0) IS NOT NULL
                         AND NULLIF(fin_km.km_p2, 0) IS NOT NULL
                         AND NULLIF(fin_km.km_p1, 0) <= NULLIF(fin_km.km_p2, 0)
                        THEN NULLIF(fin_km.km_p1, 0)
                        ELSE COALESCE(NULLIF(fin_km.km_p1, 0), NULLIF(fin_km.km_p2, 0))
                    END,
                    NULLIF(fin_km.km_p3, 0),
                    NULLIF(fin_km.km_p4, 0)
                )
        END
    AS decimal(18,4)) AS KmColetadoFin

    , CASE
            WHEN ISNULL(
                COALESCE(
                    CASE
                        WHEN fin.ParamMenorValorKm = 'true'
                         AND NULLIF(fin_km.km_p1, 0) IS NOT NULL
                         AND NULLIF(fin_km.km_p2, 0) IS NOT NULL
                         AND NULLIF(fin_km.km_p1, 0) <= NULLIF(fin_km.km_p2, 0)
                        THEN fin_tipo_km.tipo_km_p1
                        ELSE COALESCE(fin_tipo_km.tipo_km_p1,fin_tipo_km.tipo_km_p2)
                    END,
                    fin_tipo_km.tipo_km_p3,
                    fin_tipo_km.tipo_km_p4)
               , '-') = '-'
            THEN 'Km não coletado. Aplicado Km mínimo.'
            ELSE COALESCE(
                    CASE
                        WHEN fin.ParamMenorValorKm = 'true'
                         AND NULLIF(fin_km.km_p1, 0) IS NOT NULL
                         AND NULLIF(fin_km.km_p2, 0) IS NOT NULL
                         AND NULLIF(fin_km.km_p1, 0) <= NULLIF(fin_km.km_p2, 0)
                        THEN fin_tipo_km.tipo_km_p1
                        ELSE COALESCE(fin_tipo_km.tipo_km_p1,fin_tipo_km.tipo_km_p2)
                    END,
                    fin_tipo_km.tipo_km_p3,
                    fin_tipo_km.tipo_km_p4
                )
        END TipoKmColetado

FROM (
    SELECT DISTINCT
        a.*,

    CASE
        WHEN amb_id_rota IS NULL THEN 1
        ELSE 0
    END AS Ambulancia,

    CAST(frete_faixa_KmLatLongPacotes.bft_vl_inicio_faixa AS VARCHAR(5))
        + '/'
        + CAST(frete_faixa_KmLatLongPacotes.bft_vl_fim_faixa AS VARCHAR(5))
        AS FaixaKMLatLongPacotes,

    frete_faixa_KmLatLongPacotes.OrdemFaixa
        AS OrdemLatLongPacotes,

    CAST(frete_faixa_KmSilosTotal.bft_vl_inicio_faixa AS VARCHAR(5))
        + '/'
        + CAST(frete_faixa_KmSilosTotal.bft_vl_fim_faixa AS VARCHAR(5))
        AS FaixaKmSilosTotal,

    frete_faixa_KmSilosTotal.OrdemFaixa
        AS OrdemSilosTotal,

    CAST(frete_faixa_KmSilosLogistics.bft_vl_inicio_faixa AS VARCHAR(5))
        + '/'
        + CAST(frete_faixa_KmSilosLogistics.bft_vl_fim_faixa AS VARCHAR(5))
        AS FaixaKmSilosLogistics,

    frete_faixa_KmSilosLogistics.OrdemFaixa
        AS OrdemFaixaSilosLogistics,

    CAST(frete_faixa_KmAppIrisys.bft_vl_inicio_faixa AS VARCHAR(5))
        + '/'
        + CAST(frete_faixa_KmAppIrisys.bft_vl_fim_faixa AS VARCHAR(5))
        AS FaixaKmAppIrisys,

    CASE
        WHEN a.PrefIntervaloFaixa = '' THEN 1
        ELSE frete_faixa_KmAppIrisys.OrdemFaixa
    END AS OrdemFaixaAppIrisys,

    CAST(frete_faixa_KmRtt.bft_vl_inicio_faixa AS VARCHAR(5))
        + '/'
        + CAST(frete_faixa_KmRtt.bft_vl_fim_faixa AS VARCHAR(5))
        AS FaixaKmRtt,

    frete_faixa_KmRtt.OrdemFaixa
        AS OrdemFaixaRtt,

    CAST(frete_faixa_KmValidacaoMapas.bft_vl_inicio_faixa AS VARCHAR(5))
        + '/'
        + CAST(frete_faixa_KmValidacaoMapas.bft_vl_fim_faixa AS VARCHAR(5))
        AS FaixaKmValidacaoMapas,

    frete_faixa_KmValidacaoMapas.OrdemFaixa
        AS OrdemValidacaoMapas,

    CAST(frete_faixa_KmDraHistorico.bft_vl_inicio_faixa AS VARCHAR(5))
        + '/'
        + CAST(frete_faixa_KmDraHistorico.bft_vl_fim_faixa AS VARCHAR(5))
        AS FaixaKmDraHistorico,

    frete_faixa_KmDraHistorico.OrdemFaixa
        AS OrdemDraHistorico,

    /* TREVO */
    CAST(frete_faixa_KmTrevo.bft_vl_inicio_faixa AS VARCHAR(5))
        + '/'
        + CAST(frete_faixa_KmTrevo.bft_vl_fim_faixa AS VARCHAR(5))
        AS FaixaKmTrevo,

    frete_faixa_KmTrevo.OrdemFaixa
        AS OrdemFaixaTrevo,

    CASE
        WHEN a.PrefIntervaloFaixa = '' THEN 1
        ELSE frete_faixa_KmPrefatura.OrdemFaixa
    END AS OrdemPrefatura,

    CASE
        WHEN a.PrefIntervaloFaixa = '' THEN 1
        ELSE frete_faixa_KmPrefatura.OrdemFaixa
    END
        - CASE
            WHEN a.PrefIntervaloFaixa = '' THEN 1
            ELSE frete_faixa_KmPrefatura.OrdemFaixa
        END
        AS DeltaFaixa_Prefatura,

    frete_faixa_KmLatLongPacotes.OrdemFaixa
        - CASE
            WHEN a.PrefIntervaloFaixa = '' THEN 1
            ELSE frete_faixa_KmPrefatura.OrdemFaixa
        END
        AS DeltaFaixa_LatLongPacotes,

    frete_faixa_KmSilosTotal.OrdemFaixa
        - CASE
            WHEN a.PrefIntervaloFaixa = '' THEN 1
            ELSE frete_faixa_KmPrefatura.OrdemFaixa
        END
        AS DeltaFaixa_SilosTotal,

    frete_faixa_KmSilosLogistics.OrdemFaixa
        - CASE
            WHEN a.PrefIntervaloFaixa = '' THEN 1
            ELSE frete_faixa_KmPrefatura.OrdemFaixa
        END
        AS DeltaFaixa_SilosLogistics,

    CASE
        WHEN CASE
                WHEN a.PrefIntervaloFaixa = '' THEN 1
                ELSE frete_faixa_KmAppIrisys.OrdemFaixa
             END IS NULL
         AND CASE
                WHEN a.PrefIntervaloFaixa = '' THEN 1
                ELSE frete_faixa_KmPrefatura.OrdemFaixa
             END IS NULL
        THEN 0
        ELSE
            CASE
                WHEN a.PrefIntervaloFaixa = '' THEN 1
                ELSE frete_faixa_KmAppIrisys.OrdemFaixa
            END
            - CASE
                WHEN a.PrefIntervaloFaixa = '' THEN 1
                ELSE frete_faixa_KmPrefatura.OrdemFaixa
            END
    END AS DeltaFaixa_AppIrisys,

    frete_faixa_KmRtt.OrdemFaixa
        - CASE
            WHEN a.PrefIntervaloFaixa = '' THEN 1
            ELSE frete_faixa_KmPrefatura.OrdemFaixa
        END
        AS DeltaFaixa_Rtt,

    frete_faixa_KmValidacaoMapas.OrdemFaixa
        - CASE
            WHEN a.PrefIntervaloFaixa = '' THEN 1
            ELSE frete_faixa_KmPrefatura.OrdemFaixa
        END
        AS DeltaFaixa_ValidacaoMapas,

    frete_faixa_KmDraHistorico.OrdemFaixa
        - CASE
            WHEN a.PrefIntervaloFaixa = '' THEN 1
            ELSE frete_faixa_KmPrefatura.OrdemFaixa
        END
        AS DeltaFaixa_DraHistorico,

    /* TREVO */
    frete_faixa_KmTrevo.OrdemFaixa
        - CASE
            WHEN a.PrefIntervaloFaixa = '' THEN 1
            ELSE frete_faixa_KmPrefatura.OrdemFaixa
        END
        AS DeltaFaixa_Trevo

    ,
    /* Delta KM Param1 vs RTT — faixas para PBI */
    CASE
        WHEN (CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) IS NULL OR a.KmRtt IS NULL THEN NULL
        WHEN ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) < -100 THEN '< -100'
        WHEN ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) >= -100 AND ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) < -10 THEN '-100 a -10'
        WHEN ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) >= -10 AND ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) <= 10 THEN '-10 a 10'
        WHEN ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) > 10 AND ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) <= 100 THEN '10 a 100'
        WHEN ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) > 100 THEN '> 100'
    END AS FaixaDeltaKmParam1Rtt,

    CASE
        WHEN (CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) IS NULL OR a.KmRtt IS NULL THEN NULL
        WHEN ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) < -100 THEN 1
        WHEN ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) >= -100 AND ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) < -10 THEN 2
        WHEN ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) >= -10 AND ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) <= 10 THEN 3
        WHEN ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) > 10 AND ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) <= 100 THEN 4
        WHEN ((CASE a.ParamKm1Label
            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))
            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))
            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))
            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))
            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))
            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))
            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                CAST(
                    CASE
                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes
                        ELSE a.KmAppIrisys
                    END AS decimal(18,4)
                )
            ELSE NULL
        END) - a.KmRtt) > 100 THEN 5
    END AS OrdemFaixaDeltaKmParam1Rtt


    ,

    /* Delta KM Param1 vs DRA Historico — faixas para PBI */

    CASE

        WHEN (CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) IS NULL OR a.KmDraHistorico IS NULL THEN NULL

        WHEN ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) < -100 THEN '< -100'

        WHEN ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) >= -100 AND ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) < -10 THEN '-100 a -10'

        WHEN ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) >= -10 AND ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) <= 10 THEN '-10 a 10'

        WHEN ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) > 10 AND ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) <= 100 THEN '10 a 100'

        WHEN ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) > 100 THEN '> 100'

    END AS FaixaDeltaKmParam1DraHistorico,



    CASE

        WHEN (CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) IS NULL OR a.KmDraHistorico IS NULL THEN NULL

        WHEN ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) < -100 THEN 1

        WHEN ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) >= -100 AND ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) < -10 THEN 2

        WHEN ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) >= -10 AND ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) <= 10 THEN 3

        WHEN ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) > 10 AND ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) <= 100 THEN 4

        WHEN ((CASE a.ParamKm1Label

            WHEN 'KM do app Irisys' THEN CAST(a.KmAppIrisys AS decimal(18,4))

            WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(a.KmLatLongPacotes AS decimal(18,4))

            WHEN 'Km por trevo a trevo' THEN CAST(a.KmTrevo AS decimal(18,4))

            WHEN 'Km do RTT' THEN CAST(a.KmRtt AS decimal(18,4))

            WHEN 'Faixa km da prefatura' THEN CAST(a.PrefFimIntervalo AS decimal(18,4))

            WHEN 'Km coletado do Silos' THEN CAST(a.KmSilosTotal AS decimal(18,4))

            WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN

                CAST(

                    CASE

                        WHEN a.KmAppIrisys = 0 THEN a.KmLatLongPacotes

                        ELSE a.KmAppIrisys

                    END AS decimal(18,4)

                )

            ELSE NULL

        END) - a.KmDraHistorico) > 100 THEN 5

    END AS OrdemFaixaDeltaKmParam1DraHistorico

    ,

    /* Delta e atingimento fixo KmAppIrisys vs KmDraHistorico */
    CAST(a.KmAppIrisys - a.KmDraHistorico AS decimal(18,4))
        AS DeltaKmAppIrisysDraHistorico,

    CASE
        WHEN a.KmDraHistorico IS NULL OR a.KmDraHistorico = 0 THEN NULL
        ELSE CAST(
            CAST(a.KmAppIrisys AS decimal(18,4)) / a.KmDraHistorico * 100
            AS decimal(10,2)
        )
    END AS PercentualAtingimentoAppIrisysDraHistorico,

    /* Delta e atingimento fixo KmRtt vs KmDraHistorico */
    CAST(a.KmRtt - a.KmDraHistorico AS decimal(18,4))
        AS DeltaKmRttDraHistorico,

    CASE
        WHEN a.KmDraHistorico IS NULL OR a.KmDraHistorico = 0 THEN NULL
        ELSE CAST(
            CAST(a.KmRtt AS decimal(18,4)) / a.KmDraHistorico * 100
            AS decimal(10,2)
        )
    END AS PercentualAtingimentoRttDraHistorico,

    CASE
        WHEN a.KmRtt IS NULL OR a.KmDraHistorico IS NULL THEN NULL
        WHEN (a.KmRtt - a.KmDraHistorico) < -100 THEN '< -100'
        WHEN (a.KmRtt - a.KmDraHistorico) >= -100 AND (a.KmRtt - a.KmDraHistorico) < -10 THEN '-100 a -10'
        WHEN (a.KmRtt - a.KmDraHistorico) >= -10 AND (a.KmRtt - a.KmDraHistorico) <= 10 THEN '-10 a 10'
        WHEN (a.KmRtt - a.KmDraHistorico) > 10 AND (a.KmRtt - a.KmDraHistorico) <= 100 THEN '10 a 100'
        WHEN (a.KmRtt - a.KmDraHistorico) > 100 THEN '> 100'
    END AS FaixaDeltaKmRttDraHistorico,

    CASE
        WHEN a.KmRtt IS NULL OR a.KmDraHistorico IS NULL THEN NULL
        WHEN (a.KmRtt - a.KmDraHistorico) < -100 THEN 1
        WHEN (a.KmRtt - a.KmDraHistorico) >= -100 AND (a.KmRtt - a.KmDraHistorico) < -10 THEN 2
        WHEN (a.KmRtt - a.KmDraHistorico) >= -10 AND (a.KmRtt - a.KmDraHistorico) <= 10 THEN 3
        WHEN (a.KmRtt - a.KmDraHistorico) > 10 AND (a.KmRtt - a.KmDraHistorico) <= 100 THEN 4
        WHEN (a.KmRtt - a.KmDraHistorico) > 100 THEN 5
    END AS OrdemFaixaDeltaKmRttDraHistorico,

    /* FlagUsoDevidoFin: percentual 90-110% vs DRA */
    CASE
        WHEN a.KmAppIrisys IS NULL OR a.KmAppIrisys = 0 THEN 0
        WHEN a.KmDraHistorico IS NULL OR a.KmDraHistorico = 0 THEN 0
        WHEN CAST(a.KmAppIrisys AS decimal(18,4)) / a.KmDraHistorico * 100 >= 90
         AND CAST(a.KmAppIrisys AS decimal(18,4)) / a.KmDraHistorico * 100 <= 110
        THEN 1
        ELSE 0
    END AS FlagUsoDevidoFin

FROM base AS a

LEFT JOIN tb_looker_ambulancias AS amb
    ON a.IdRota = amb_id_rota

LEFT JOIN tb_dra_tipo_veiculo AS vei
    ON a.TipoVeiculo = tvl_nm_tipo_veiculo

LEFT JOIN frete_transportadora AS frete_faixa_KmLatLongPacotes
    ON vei.tvl_cd_tipo_veiculo =
        frete_faixa_KmLatLongPacotes.bft_cd_tipo_veiculo
   AND a.TenantId =
        frete_faixa_KmLatLongPacotes.bft_cd_transportadora
   AND frete_faixa_KmLatLongPacotes.bft_cd_service_center =
        a.ServiceCenterOrigem
   AND frete_faixa_KmLatLongPacotes.bft_estado IS NULL
   AND a.KmLatLongPacotes >=
        (TRY_CONVERT(decimal(18, 4), frete_faixa_KmLatLongPacotes.bft_vl_inicio_faixa) - 1)
   AND a.KmLatLongPacotes <=
        TRY_CONVERT(decimal(18, 4), frete_faixa_KmLatLongPacotes.bft_vl_fim_faixa)

LEFT JOIN frete_transportadora AS frete_faixa_KmSilosLogistics
    ON vei.tvl_cd_tipo_veiculo =
        frete_faixa_KmSilosLogistics.bft_cd_tipo_veiculo
   AND a.TenantId =
        frete_faixa_KmSilosLogistics.bft_cd_transportadora
   AND frete_faixa_KmSilosLogistics.bft_cd_service_center =
        a.ServiceCenterOrigem
   AND frete_faixa_KmSilosLogistics.bft_estado IS NULL
   AND a.KmSilosLogistics >
        (TRY_CONVERT(decimal(18, 4), frete_faixa_KmSilosLogistics.bft_vl_inicio_faixa) - 1)
   AND a.KmSilosLogistics <=
        TRY_CONVERT(decimal(18, 4), frete_faixa_KmSilosLogistics.bft_vl_fim_faixa)

LEFT JOIN frete_transportadora AS frete_faixa_KmSilosTotal
    ON vei.tvl_cd_tipo_veiculo =
        frete_faixa_KmSilosTotal.bft_cd_tipo_veiculo
   AND a.TenantId =
        frete_faixa_KmSilosTotal.bft_cd_transportadora
   AND frete_faixa_KmSilosTotal.bft_cd_service_center =
        a.ServiceCenterOrigem
   AND frete_faixa_KmSilosTotal.bft_estado IS NULL
   AND a.KmSilosTotal >
        (TRY_CONVERT(decimal(18, 4), frete_faixa_KmSilosTotal.bft_vl_inicio_faixa) - 1)
   AND a.KmSilosTotal <=
        TRY_CONVERT(decimal(18, 4), frete_faixa_KmSilosTotal.bft_vl_fim_faixa)

LEFT JOIN frete_transportadora AS frete_faixa_KmAppIrisys
    ON vei.tvl_cd_tipo_veiculo =
        frete_faixa_KmAppIrisys.bft_cd_tipo_veiculo
   AND a.TenantId =
        frete_faixa_KmAppIrisys.bft_cd_transportadora
   AND frete_faixa_KmAppIrisys.bft_cd_service_center =
        a.ServiceCenterOrigem
   AND frete_faixa_KmAppIrisys.bft_estado IS NULL
   AND a.KmAppIrisys >
        (TRY_CONVERT(decimal(18, 4), frete_faixa_KmAppIrisys.bft_vl_inicio_faixa) - 1)
   AND a.KmAppIrisys <=
        TRY_CONVERT(decimal(18, 4), frete_faixa_KmAppIrisys.bft_vl_fim_faixa)

LEFT JOIN frete_transportadora AS frete_faixa_KmRtt
    ON vei.tvl_cd_tipo_veiculo =
        frete_faixa_KmRtt.bft_cd_tipo_veiculo
   AND a.TenantId =
        frete_faixa_KmRtt.bft_cd_transportadora
   AND frete_faixa_KmRtt.bft_cd_service_center =
        a.ServiceCenterOrigem
   AND frete_faixa_KmRtt.bft_estado IS NULL
   AND a.KmRtt >
        (TRY_CONVERT(decimal(18, 4), frete_faixa_KmRtt.bft_vl_inicio_faixa) - 1)
   AND a.KmRtt <=
        TRY_CONVERT(decimal(18, 4), frete_faixa_KmRtt.bft_vl_fim_faixa)

LEFT JOIN frete_transportadora AS frete_faixa_KmValidacaoMapas
    ON vei.tvl_cd_tipo_veiculo =
        frete_faixa_KmValidacaoMapas.bft_cd_tipo_veiculo
   AND a.TenantId =
        frete_faixa_KmValidacaoMapas.bft_cd_transportadora
   AND frete_faixa_KmValidacaoMapas.bft_cd_service_center =
        a.ServiceCenterOrigem
   AND frete_faixa_KmValidacaoMapas.bft_estado IS NULL
   AND a.PrefInicioIntervalo >
        (TRY_CONVERT(decimal(18, 4), frete_faixa_KmValidacaoMapas.bft_vl_inicio_faixa) - 1)
   AND a.PrefInicioIntervalo <=
        TRY_CONVERT(decimal(18, 4), frete_faixa_KmValidacaoMapas.bft_vl_fim_faixa)

LEFT JOIN frete_transportadora AS frete_faixa_KmDraHistorico
    ON vei.tvl_cd_tipo_veiculo =
        frete_faixa_KmDraHistorico.bft_cd_tipo_veiculo
   AND a.TenantId =
        frete_faixa_KmDraHistorico.bft_cd_transportadora
   AND frete_faixa_KmDraHistorico.bft_cd_service_center =
        a.ServiceCenterOrigem
   AND frete_faixa_KmDraHistorico.bft_estado IS NULL
   AND a.KmDraHistorico >
        (TRY_CONVERT(decimal(18, 4), frete_faixa_KmDraHistorico.bft_vl_inicio_faixa) - 1)
   AND a.KmDraHistorico <=
        TRY_CONVERT(decimal(18, 4), frete_faixa_KmDraHistorico.bft_vl_fim_faixa)

/* TREVO */
LEFT JOIN frete_transportadora AS frete_faixa_KmTrevo
    ON vei.tvl_cd_tipo_veiculo =
        frete_faixa_KmTrevo.bft_cd_tipo_veiculo
   AND a.TenantId =
        frete_faixa_KmTrevo.bft_cd_transportadora
   AND frete_faixa_KmTrevo.bft_cd_service_center =
        a.ServiceCenterOrigem
   AND frete_faixa_KmTrevo.bft_estado IS NULL
   AND a.KmTrevo >
        (TRY_CONVERT(decimal(18, 4), frete_faixa_KmTrevo.bft_vl_inicio_faixa) - 1)
   AND a.KmTrevo <=
        TRY_CONVERT(decimal(18, 4), frete_faixa_KmTrevo.bft_vl_fim_faixa)

LEFT JOIN frete_transportadora AS frete_faixa_KmPrefatura
    ON vei.tvl_cd_tipo_veiculo =
        frete_faixa_KmPrefatura.bft_cd_tipo_veiculo
   AND a.TenantId =
        frete_faixa_KmPrefatura.bft_cd_transportadora
   AND frete_faixa_KmPrefatura.bft_cd_service_center =
        a.ServiceCenterOrigem
   AND frete_faixa_KmPrefatura.bft_estado IS NULL
   AND a.PrefInicioIntervalo >
        (TRY_CONVERT(decimal(18, 4), frete_faixa_KmPrefatura.bft_vl_inicio_faixa) - 1)
   AND a.PrefInicioIntervalo <=
        TRY_CONVERT(decimal(18, 4), frete_faixa_KmPrefatura.bft_vl_fim_faixa)

) AS fin

CROSS APPLY (
    SELECT
        CASE
            WHEN fin.ParamKm1Label = 'KM do app Irisys' AND fin.FlagUsoDevidoFin = 1
                THEN NULLIF(CAST(fin.KmAppIrisys AS decimal(18,4)), 0)
            WHEN fin.ParamKm1Label = 'KM do app Irisys' AND fin.FlagUsoDevidoFin = 0
                THEN CAST(NULL AS decimal(18,4))
            ELSE NULLIF(
                CASE fin.ParamKm1Label
                    WHEN 'KM do app Irisys' THEN CAST(fin.KmAppIrisys AS decimal(18,4))
                    WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(fin.KmLatLongPacotes AS decimal(18,4))
                    WHEN 'Km por trevo a trevo' THEN CAST(fin.KmTrevo AS decimal(18,4))
                    WHEN 'Km do RTT' THEN CAST(fin.KmRtt AS decimal(18,4))
                    WHEN 'Faixa km da prefatura' THEN CAST(fin.PrefFimIntervalo AS decimal(18,4))
                    WHEN 'Km coletado do Silos' THEN CAST(fin.KmSilosTotal AS decimal(18,4))
                    WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                        CAST(CASE WHEN ISNULL(fin.KmAppIrisys, 0) = 0 THEN fin.KmLatLongPacotes ELSE fin.KmAppIrisys END AS decimal(18,4))
                    WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN CAST(fin.KmDraHistorico AS decimal(18,4))
                    ELSE NULL
                END, 0)
        END AS km_p1,
        NULLIF(
            CASE fin.ParamKm2Label
                WHEN 'KM do app Irisys' THEN CAST(fin.KmAppIrisys AS decimal(18,4))
                WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(fin.KmLatLongPacotes AS decimal(18,4))
                WHEN 'Km por trevo a trevo' THEN CAST(fin.KmTrevo AS decimal(18,4))
                WHEN 'Km do RTT' THEN CAST(fin.KmRtt AS decimal(18,4))
                WHEN 'Faixa km da prefatura' THEN CAST(fin.PrefFimIntervalo AS decimal(18,4))
                WHEN 'Km coletado do Silos' THEN CAST(fin.KmSilosTotal AS decimal(18,4))
                WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                    CAST(CASE WHEN ISNULL(fin.KmAppIrisys, 0) = 0 THEN fin.KmLatLongPacotes ELSE fin.KmAppIrisys END AS decimal(18,4))
                WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN CAST(fin.KmDraHistorico AS decimal(18,4))
                ELSE NULL
            END, 0) AS km_p2,
        NULLIF(
            CASE fin.ParamKm3Label
                WHEN 'KM do app Irisys' THEN CAST(fin.KmAppIrisys AS decimal(18,4))
                WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(fin.KmLatLongPacotes AS decimal(18,4))
                WHEN 'Km por trevo a trevo' THEN CAST(fin.KmTrevo AS decimal(18,4))
                WHEN 'Km do RTT' THEN CAST(fin.KmRtt AS decimal(18,4))
                WHEN 'Faixa km da prefatura' THEN CAST(fin.PrefFimIntervalo AS decimal(18,4))
                WHEN 'Km coletado do Silos' THEN CAST(fin.KmSilosTotal AS decimal(18,4))
                WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                    CAST(CASE WHEN ISNULL(fin.KmAppIrisys, 0) = 0 THEN fin.KmLatLongPacotes ELSE fin.KmAppIrisys END AS decimal(18,4))
                WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN CAST(fin.KmDraHistorico AS decimal(18,4))
                ELSE NULL
            END, 0) AS km_p3,
        NULLIF(
            CASE fin.ParamKm4Label
                WHEN 'KM do app Irisys' THEN CAST(fin.KmAppIrisys AS decimal(18,4))
                WHEN 'KM latitude e longetude dos Pacotes' THEN CAST(fin.KmLatLongPacotes AS decimal(18,4))
                WHEN 'Km por trevo a trevo' THEN CAST(fin.KmTrevo AS decimal(18,4))
                WHEN 'Km do RTT' THEN CAST(fin.KmRtt AS decimal(18,4))
                WHEN 'Faixa km da prefatura' THEN CAST(fin.PrefFimIntervalo AS decimal(18,4))
                WHEN 'Km coletado do Silos' THEN CAST(fin.KmSilosTotal AS decimal(18,4))
                WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN
                    CAST(CASE WHEN ISNULL(fin.KmAppIrisys, 0) = 0 THEN fin.KmLatLongPacotes ELSE fin.KmAppIrisys END AS decimal(18,4))
                WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN CAST(fin.KmDraHistorico AS decimal(18,4))
                ELSE NULL
            END, 0) AS km_p4
) AS fin_km

CROSS APPLY (
    SELECT
        CASE
            WHEN fin.ParamKm1Label = 'KM do app Irisys' AND fin.FlagUsoDevidoFin = 1
                THEN 'KM do app Irisys'
            WHEN fin.ParamKm1Label = 'KM do app Irisys' AND fin.FlagUsoDevidoFin = 0
                THEN NULL
            ELSE NULLIF(
                CASE fin.ParamKm1Label
                    WHEN 'KM do app Irisys' THEN 'KM do app Irisys'
                    WHEN 'KM latitude e longetude dos Pacotes' THEN 'KM latitude e longetude dos Pacotes'
                    WHEN 'Km por trevo a trevo' THEN 'Km por trevo a trevo'
                    WHEN 'Km do RTT' THEN 'Km do RTT'
                    WHEN 'Faixa km da prefatura' THEN 'Faixa km da prefatura'
                    WHEN 'Km coletado do Silos' THEN 'Km coletado do Silos'
                    WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN 'Km do app Irisys ou KM lat e long dos pacotes.'
                    WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN 'Km de contingencia coletado de tb_dra_historico_rotas'
                    ELSE NULL
                END, '-')
        END AS tipo_km_p1,
        NULLIF(
            CASE fin.ParamKm2Label
                    WHEN 'KM do app Irisys' THEN 'KM do app Irisys'
                    WHEN 'KM latitude e longetude dos Pacotes' THEN 'KM latitude e longetude dos Pacotes'
                    WHEN 'Km por trevo a trevo' THEN 'Km por trevo a trevo'
                    WHEN 'Km do RTT' THEN 'Km do RTT'
                    WHEN 'Faixa km da prefatura' THEN 'Faixa km da prefatura'
                    WHEN 'Km coletado do Silos' THEN 'Km coletado do Silos'
                    WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN 'Km do app Irisys ou KM lat e long dos pacotes.'
                    WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN 'Km de contingencia coletado de tb_dra_historico_rotas'
                    ELSE NULL
            END, '-') AS tipo_km_p2,
        NULLIF(
            CASE fin.ParamKm3Label
                    WHEN 'KM do app Irisys' THEN 'KM do app Irisys'
                    WHEN 'KM latitude e longetude dos Pacotes' THEN 'KM latitude e longetude dos Pacotes'
                    WHEN 'Km por trevo a trevo' THEN 'Km por trevo a trevo'
                    WHEN 'Km do RTT' THEN 'Km do RTT'
                    WHEN 'Faixa km da prefatura' THEN 'Faixa km da prefatura'
                    WHEN 'Km coletado do Silos' THEN 'Km coletado do Silos'
                    WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN 'Km do app Irisys ou KM lat e long dos pacotes.'
                    WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN 'Km de contingencia coletado de tb_dra_historico_rotas'
                    ELSE NULL
            END, '-') AS tipo_km_p3,
        NULLIF(
            CASE fin.ParamKm4Label
                    WHEN 'KM do app Irisys' THEN 'KM do app Irisys'
                    WHEN 'KM latitude e longetude dos Pacotes' THEN 'KM latitude e longetude dos Pacotes'
                    WHEN 'Km por trevo a trevo' THEN 'Km por trevo a trevo'
                    WHEN 'Km do RTT' THEN 'Km do RTT'
                    WHEN 'Faixa km da prefatura' THEN 'Faixa km da prefatura'
                    WHEN 'Km coletado do Silos' THEN 'Km coletado do Silos'
                    WHEN 'Km do app Irisys ou KM lat e long dos pacotes.' THEN 'Km do app Irisys ou KM lat e long dos pacotes.'
                    WHEN 'Km de contingencia coletado de tb_dra_historico_rotas' THEN 'Km de contingencia coletado de tb_dra_historico_rotas'
                    ELSE NULL
            END, '-') AS tipo_km_p4
) AS fin_tipo_km
GO
