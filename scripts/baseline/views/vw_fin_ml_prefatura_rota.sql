-- ============================================================
-- BASELINE: dbo.vw_fin_ml_prefatura_rota
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_ml_prefatura_rota]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_fin_ml_prefatura_rota] AS
SELECT
    p.IdTransportadora,
    p.Ano,
    p.Mes,
    p.Quinzena,
    p.IdRota,
    CONCAT_WS('|', p.IdTransportadora, p.Ano, p.Mes, p.IdRota) AS ChaveRota,
    p.Veiculo,
    p.ContinuacaoVeiculo,
    p.ServiceCenter,
    p.KmCiclo,
    CASE
        WHEN p.KmCiclo = 'KMs RANGE' THEN 'KMs RANGE'
        WHEN p.KmCiclo = 'PART TIME ROUTE' THEN 'PART TIME'
        WHEN p.KmCiclo = 'PART TIME D ROUTE' OR p.KmCiclo = 'ART TIME D ROUTE' THEN 'PART TIME D'
        WHEN p.KmCiclo = 'SATURDAY DAY ROUTE' THEN 'SATURDAY'
        WHEN p.KmCiclo = 'HOLIDAY DAY ROUTE' THEN 'HOLIDAY'
        WHEN p.KmCiclo = 'AMBULANCE' THEN 'AMBULANCE'
        WHEN p.KmCiclo IS NULL THEN 'NAO_INFORMADO'
        ELSE 'NAO_MAPEADO'
    END AS TipoCicloNormalizado,
    CASE
        WHEN p.KmCiclo = 'ART TIME D ROUTE' THEN 1 ELSE 0
    END AS FlgTipoCicloNaoMapeado,
    CASE
        WHEN p.IntervaloFaixa IS NOT NULL THEN 'FAIXA_KM'
        WHEN p.VLParada IS NOT NULL AND p.VLParada > 0 THEN 'POR_PARADA'
        WHEN p.KmCiclo = 'AMBULANCE' THEN 'AMBULANCIA'
        ELSE 'VALOR_FIXO'
    END AS ModeloPagamento,
    p.CicloPM AS TurnoDeclarado,
    CASE
        WHEN p.CicloPM IS NULL THEN 'NAO_INFORMADO'
        WHEN p.CicloPM = 'AM' THEN 'AM'
        WHEN p.CicloPM = 'PM' THEN 'PM'
        ELSE 'OUTRO'
    END AS TurnoDeclaradoRotulo,
    p.IntervaloFaixa,
    p.InicioIntervalo,
    p.FimIntervalo,
    p.Placa,
    p.Motorista,
    p.DataInicio,
    p.DataTermino,
    p.Quantidade,
    p.PrecoUnitario,
    p.Total AS ValorPrefatura,
    p.Parada AS QtParadas,
    p.VLParada AS ValorParada,
    CASE
        WHEN ABS(p.Total - ISNULL(p.Quantidade,0) * ISNULL(p.PrecoUnitario,0)) > 0.01 THEN 1
        ELSE 0
    END AS FlgTotalInconsistente,
    p.EnderecoNaoVisitado,
    p.DataAtualizacao
FROM dbo.tb_fin_prefatura p
GO
