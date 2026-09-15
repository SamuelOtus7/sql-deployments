-- ============================================================
-- BASELINE: dbo.vw_fin_ml_complementar_rota
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_ml_complementar_rota]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_fin_ml_complementar_rota] AS
SELECT
    c.pfc_cd_transportadora AS IdTransportadora,
    c.pfc_nu_ano AS Ano,
    c.pfc_nu_mes AS Mes,
    MIN(c.pfc_nu_quinzena) AS Quinzena,
    c.pfc_cd_rota AS IdRota,
    CONCAT_WS('|', c.pfc_cd_transportadora, c.pfc_nu_ano, c.pfc_nu_mes, c.pfc_cd_rota) AS ChaveRota,
    COUNT(*) AS QtConceitos,
    SUM(CASE WHEN c.pfc_ds_status_final = 'PAGAR' THEN c.pfc_vl_servico ELSE 0 END) AS VlPagar,
    SUM(CASE WHEN c.pfc_ds_status_final = 'RECUPERAR' THEN c.pfc_vl_servico ELSE 0 END) AS VlRecuperar,
    ABS(SUM(CASE WHEN c.pfc_ds_status_final = 'RECUPERAR' THEN c.pfc_vl_servico ELSE 0 END)) AS VlRecuperarAbs,
    SUM(CASE WHEN c.pfc_ds_status_final = 'NO PAGAR' THEN 1 ELSE 0 END) AS QtNegada,
    SUM(c.pfc_vl_servico) AS VlComplementarLiquido,
    SUM(CASE WHEN c.pfc_ds_status_final = 'PAGAR' THEN 1 ELSE 0 END) AS QtPagar,
    SUM(CASE WHEN c.pfc_ds_status_final = 'RECUPERAR' THEN 1 ELSE 0 END) AS QtRecuperar,
    SUM(CASE WHEN c.pfc_ds_conceito_billing LIKE 'incentivos%' THEN c.pfc_vl_servico ELSE 0 END) AS VlIncentivos,
    SUM(CASE WHEN c.pfc_ds_conceito_billing LIKE 'authorized_ambulance%' THEN c.pfc_vl_servico ELSE 0 END) AS VlAmbulancia,
    SUM(CASE WHEN c.pfc_ds_conceito_billing LIKE 'additional_kms%' THEN c.pfc_vl_servico ELSE 0 END) AS VlAdicionalKm,
    SUM(CASE WHEN c.pfc_ds_conceito_billing LIKE 'rentals_costs%' THEN c.pfc_vl_servico ELSE 0 END) AS VlEnergiaEletrico,
    SUM(CASE WHEN c.pfc_ds_conceito_billing LIKE 'variable_cost%' THEN c.pfc_vl_servico ELSE 0 END) AS VlAdicionalParada,
    SUM(CASE WHEN c.pfc_ds_conceito_billing LIKE 'ops_adherence%' THEN c.pfc_vl_servico ELSE 0 END) AS VlOpsAdherence,
    SUM(CASE WHEN c.pfc_ds_conceito_billing LIKE 'no_show%' THEN c.pfc_vl_servico ELSE 0 END) AS VlNoShow,
    SUM(CASE WHEN c.pfc_ds_conceito_billing LIKE 'unused_vehicles%' OR c.pfc_ds_conceito_billing LIKE 'canceled_sdd%' THEN c.pfc_vl_servico ELSE 0 END) AS VlOutros,
    MAX(c.pfc_dt_processamento) AS DtProcessamento,
    MIN(c.pfc_ds_service_center) AS ServiceCenter,
    MIN(c.pfc_ds_tipo_veiculo) AS VeiculoComplementar
FROM dbo.tb_fin_prefatura_complementar c
GROUP BY c.pfc_cd_transportadora, c.pfc_nu_ano, c.pfc_nu_mes, c.pfc_cd_rota
GO
