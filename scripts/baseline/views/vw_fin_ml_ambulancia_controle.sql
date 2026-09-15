-- ============================================================
-- BASELINE: dbo.vw_fin_ml_ambulancia_controle
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_ml_ambulancia_controle]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_fin_ml_ambulancia_controle] AS
SELECT
    p.IdTransportadora,
    p.Ano,
    p.Mes,
    p.Quinzena,
    p.IdRota,
    CONCAT_WS('|', p.IdTransportadora, p.Ano, p.Mes, p.IdRota) AS ChaveRota,
    p.ServiceCenter,
    p.Veiculo,
    p.Placa,
    p.Motorista,
    p.DataInicio,
    p.DataTermino,
    p.Total AS ValorPrefatura,
    ISNULL(a.VlAmbulanciaAprovado, 0) AS VlAmbulanciaAprovado,
    CASE
        WHEN a.QtPagar > 0 THEN 'APROVADA'
        WHEN a.QtNegada > 0 THEN 'NEGADA'
        ELSE 'SEM_LANCAMENTO'
    END AS StatusAmbulancia,
    ISNULL(a.QtPagar, 0) AS QtAprovada,
    ISNULL(a.QtNegada, 0) AS QtNegada,
    ISNULL(a.QtTotal, 0) AS QtLancamentos,
    a.MotivoNegociacao
FROM dbo.tb_fin_prefatura p
LEFT JOIN (
    SELECT
        c.pfc_cd_transportadora,
        c.pfc_nu_ano,
        c.pfc_nu_mes,
        c.pfc_cd_rota,
        SUM(CASE WHEN c.pfc_ds_status_final = 'PAGAR' THEN c.pfc_vl_servico ELSE 0 END) AS VlAmbulanciaAprovado,
        SUM(CASE WHEN c.pfc_ds_status_final = 'PAGAR' THEN 1 ELSE 0 END) AS QtPagar,
        SUM(CASE WHEN c.pfc_ds_status_final = 'NO PAGAR' THEN 1 ELSE 0 END) AS QtNegada,
        COUNT(*) AS QtTotal,
        MIN(c.pfc_ds_motivo_aprovacao) AS MotivoNegociacao
    FROM dbo.tb_fin_prefatura_complementar c
    WHERE c.pfc_ds_conceito_billing LIKE 'authorized_ambulance%'
    GROUP BY c.pfc_cd_transportadora, c.pfc_nu_ano, c.pfc_nu_mes, c.pfc_cd_rota
) a ON a.pfc_cd_transportadora = p.IdTransportadora
   AND a.pfc_nu_ano = p.Ano
   AND a.pfc_nu_mes = p.Mes
   AND a.pfc_cd_rota = p.IdRota
WHERE p.KmCiclo = 'AMBULANCE'
GO
