-- ============================================================
-- BASELINE: dbo.vw_fato_pagamentos_pbi
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fato_pagamentos_pbi]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_fato_pagamentos_pbi] AS
SELECT
    a.ppr_cd_pagamento_rota,
    a.ppr_cd_motorista,
    TRY_CONVERT(bigint, a.ppr_cd_rota) AS ppr_cd_rota_num,
    a.ppr_cd_periodo,
    a.ppr_data_referencia,
    fk.cd_faixa_km AS sk_faixa_km,
    tv.sk_tipo_veiculo,
    ci.sk_cidade,
    cl.sk_ciclo,
    fpi.sk_faixa_prefatura,
    tvp.sk_tipo_veiculo_prefatura,
    cp.sk_ciclo_prefatura,
    a.ppr_qt_pacotes,
    a.ppr_qt_pacotes_entregues,
    a.ppr_qt_pontos,
    a.ppr_qt_paradas,
    a.ppr_vl_base,
    a.ppr_vl_paradas,
    a.ppr_vl_pontos,
    a.ppr_vl_risco,
    a.ppr_vl_ajudante,
    a.ppr_vl_dom_fer,
    a.ppr_vl_lancamentos,
    a.ppr_vl_total,
    a.ppr_vl_pedagio,
    a.ppr_vl_recarga,
    a.ppr_vl_adicional_km,
    a.ppr_total_km,
    a.ppr_nm_cidade,
    a.ppr_ds_tipo_veiculo,
    a.ppr_ds_ciclo,
    CASE WHEN pre.KmCiclo = 'AMBULANCE' THEN 'Sim' ELSE 'Não' END AS AmbulanciaPreFatura,
    CASE
        WHEN a.ppr_ds_tipo_veiculo IS NOT NULL OR pre.Veiculo IS NOT NULL
        THEN CASE
            WHEN a.ppr_ds_tipo_veiculo = pre.Veiculo + CASE WHEN pre.ContinuacaoVeiculo IS NOT NULL THEN ' - ' + pre.ContinuacaoVeiculo ELSE '' END
            THEN 'Igual' ELSE 'Diferente'
        END
    END AS ValidacaoVeiculoPreFatura,
    a.ppr_usou_app AS usouapp,
    esp.cd_espelho,
    esp.Status AS StatusEspelho,
    esp.DataContestacao,
    esp.ValorNFS,
    esp.ValorLiquido,
    esp.ValorDesconto
FROM dbo.tb_pgto_periodo_rota a WITH (NOLOCK)
INNER JOIN dbo.tb_pgto_periodo b WITH (NOLOCK) ON a.ppr_cd_periodo = b.pgp_cd_periodo
LEFT JOIN dbo.tb_dim_faixa_km fk ON fk.ds_faixa_original = a.ppr_cd_faixa_km
LEFT JOIN dbo.vw_dim_tipo_veiculo tv
    ON UPPER(LTRIM(RTRIM(a.ppr_ds_tipo_veiculo))) COLLATE Latin1_General_CI_AI
     = UPPER(LTRIM(RTRIM(tv.Tipo_Veiculo))) COLLATE Latin1_General_CI_AI
LEFT JOIN dbo.vw_dim_cidade ci ON ci.Cidade = a.ppr_nm_cidade
LEFT JOIN dbo.vw_dim_ciclo cl ON cl.Ciclo = a.ppr_ds_ciclo
LEFT JOIN dbo.vw_dim_espelhos esp ON a.ppr_cd_motorista_nfs = esp.cd_espelho
OUTER APPLY (
    SELECT TOP 1 *
    FROM dbo.tb_fin_prefatura pre2 WITH (NOLOCK)
    WHERE pre2.IdRota = a.ppr_cd_rota
    ORDER BY pre2.DataTermino DESC
) pre
LEFT JOIN dbo.vw_dim_faixa_prefatura fpi ON fpi.Faixa_Prefatura = pre.IntervaloFaixa
LEFT JOIN dbo.vw_dim_tipo_veiculo_prefatura tvp ON tvp.Tipo_Veiculo_prefatura = pre.Veiculo
LEFT JOIN dbo.vw_dim_ciclo_prefatura cp ON cp.Ciclo_Prefatura = pre.CicloPM
WHERE a.ppr_in_excluido = 0 AND b.pgp_in_excluido = 0;
GO
