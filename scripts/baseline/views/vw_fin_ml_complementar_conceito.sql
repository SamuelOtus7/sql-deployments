-- ============================================================
-- BASELINE: dbo.vw_fin_ml_complementar_conceito
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_ml_complementar_conceito]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_fin_ml_complementar_conceito] AS
SELECT
    c.pfc_cd_transportadora AS IdTransportadora,
    c.pfc_nu_ano AS Ano,
    c.pfc_nu_mes AS Mes,
    c.pfc_nu_quinzena AS Quinzena,
    c.pfc_cd_rota AS IdRota,
    CONCAT_WS('|', c.pfc_cd_transportadora, c.pfc_nu_ano, c.pfc_nu_mes, c.pfc_cd_rota) AS ChaveRota,
    c.pfc_ds_conceito_billing AS ConceitoBilling,
    CASE
        WHEN c.pfc_ds_conceito_billing LIKE 'incentivos%' THEN 'Incentivo Combustivel'
        WHEN c.pfc_ds_conceito_billing LIKE 'authorized_ambulance%' THEN 'Ambulancia'
        WHEN c.pfc_ds_conceito_billing LIKE 'additional_kms%' THEN 'Faixa de KM'
        WHEN c.pfc_ds_conceito_billing LIKE 'rentals_costs%' THEN 'Energia Eletrico'
        WHEN c.pfc_ds_conceito_billing LIKE 'variable_cost%' THEN 'Adicional Parada'
        WHEN c.pfc_ds_conceito_billing LIKE 'ops_adherence%' THEN 'Ops Adherence'
        WHEN c.pfc_ds_conceito_billing LIKE 'no_show%' THEN 'No Show'
        WHEN c.pfc_ds_conceito_billing LIKE 'unused_vehicles%' OR c.pfc_ds_conceito_billing LIKE 'canceled_sdd%' THEN 'Outros'
        ELSE 'Nao Mapeado'
    END AS ConceitoAgrupado,
    c.pfc_vl_servico AS ValorServico,
    c.pfc_ds_status_final AS StatusFinal,
    CASE
        WHEN c.pfc_ds_status_final = 'PAGAR' THEN 'CREDITO'
        WHEN c.pfc_ds_status_final = 'RECUPERAR' THEN 'DEBITO'
        WHEN c.pfc_ds_status_final = 'NO PAGAR' THEN 'NEGADO'
        ELSE 'Nao Classificado'
    END AS TipoEfeito,
    CASE WHEN c.pfc_ds_status_final = 'PAGAR' THEN c.pfc_vl_servico ELSE 0 END AS VlPagar,
    CASE WHEN c.pfc_ds_status_final = 'RECUPERAR' THEN c.pfc_vl_servico ELSE 0 END AS VlRecuperar,
    ABS(CASE WHEN c.pfc_ds_status_final = 'RECUPERAR' THEN c.pfc_vl_servico ELSE 0 END) AS VlRecuperarAbs,
    CASE WHEN c.pfc_ds_status_final = 'NO PAGAR' THEN 0 ELSE 0 END AS VlNegado,
    CASE WHEN c.pfc_ds_status_final = 'NO PAGAR' THEN 1 ELSE 0 END AS FlgNegado,
    c.pfc_ds_motivo_aprovacao AS MotivoNegociacao,
    c.pfc_ds_service_center AS ServiceCenter,
    c.pfc_ds_tipo_veiculo AS VeiculoComplementar,
    c.pfc_ds_placa_base AS PlacaComplementar,
    c.pfc_cd_motorista AS MotoristaCodigo,
    c.pfc_ds_new_ds,
    c.pfc_dt_rota,
    c.pfc_dt_processamento,
    c.pfc_ds_periodo,
    c.pfc_qt_paradas_atualizada AS QtParadasAtualizada,
    c.pfc_qt_paradas_anterior AS QtParadasAnterior,
    c.pfc_ds_faixa_km AS FaixaKm,
    c.pfc_ds_nova_faixa_km AS NovaFaixaKm,
    c.pfc_ds_tipo_entidade AS TipoEntidade,
    c.pfc_cd_provider AS ProviderId
FROM dbo.tb_fin_prefatura_complementar c
GO
