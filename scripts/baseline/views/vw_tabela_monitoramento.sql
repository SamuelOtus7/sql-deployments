-- ============================================================
-- BASELINE: dbo.vw_tabela_monitoramento
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_tabela_monitoramento]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tabela_monitoramento] as 

SELECT 
    Tipo,
    CidadeBase AS Cidade,
    ServiceCenter AS Base,
	DataReferencia,
	IdTransportadora,
 

    COUNT(DISTINCT NomeMotorista) AS Motoristas,
    COUNT(DISTINCT IdRota) AS Rotas,
    SUM(PacotesEntregues) + SUM(PacotesNaoEntregue) + SUM(PacotesPendentes) AS Pacotes,
    SUM(PacotesEntregues) AS Entregues,
    SUM(PacotesNaoEntregue) AS Insucessos,
    SUM(PacotesPendentes) AS Pendentes,
    SUM(QuantidadeReclamacoes) AS Reclamações,
    SUM(CASE WHEN AlarmeRotaEntregaAtraso > 0 THEN 1 ELSE 0 END) AS Atrasadas,
    SUM(CASE WHEN QuantidadeAmbulancia > 0 THEN 1 ELSE 0 END) AS [Rotas amb.],
    CASE 
        WHEN SUM(CASE WHEN QuantidadeAmbulancia = 0 THEN 
            PacotesEntregues + PacotesNaoEntregue + PacotesPendentes ELSE 0 END) = 0 THEN NULL
        ELSE 
            CAST(SUM(CASE WHEN QuantidadeAmbulancia = 0 THEN PacotesEntregues ELSE 0 END) AS FLOAT) /
            SUM(CASE WHEN QuantidadeAmbulancia = 0 THEN 
                PacotesEntregues + PacotesNaoEntregue + PacotesPendentes ELSE 0 END)
    END AS [% Performance]
FROM vw_rotas
where DataReferencia between '2025-03-25' and cast(getdate() as date)
 
GROUP BY 
    Tipo,
    CidadeBase,
    ServiceCenter,
	DataReferencia,
	IdTransportadora

GO
