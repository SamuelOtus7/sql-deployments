-- ============================================================
-- BASELINE: dbo.vw_fin_resultado_quinzenal_old_19_12_25
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_resultado_quinzenal_old_19_12_25]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- dbo.vw_fin_resultado_quinzenal fonte

CREATE view [dbo].[vw_fin_resultado_quinzenal_old_19_12_25]   
as  
SELECT   
    ROW_NUMBER() OVER (PARTITION BY 1 ORDER BY a.IdTransportadora, a.Ano, a.Mes, a.Quinzena) AS Id,  
    A.IdTransportadora,  
    A.Ano,  
    A.NomeMes,  
    A.Mes,  
    A.Quinzena,  
    A.NomeQuinzena,  
    A.Rotas,  
    A.PreFatura,  
    A.Complementar,  
    A.ValorFinal,  
    A.ValorContestacao,  
    A.PercentualConstetacao,  
    B.LostPackages,  
    B.Pnr,  
    B.EnderecoNaoVisitado,  
    A.QtdParada,  
    A.ValorParada  ,
	lst_cd_lista,
	A.ValorParada +  B.Pnr + B.LostPackages TotalDescontos
FROM (  
    SELECT  
        IdTransportadora,  
        Ano,  
        NomeMes,  
        Mes,  
        Quinzena,  
        NomeQuinzena,  
        COUNT(1) AS Rotas,  
        SUM(TotalPreFatura) AS PreFatura,  
        SUM(ReceitaDA) - SUM(TotalPreFatura) AS Complementar,  
        SUM(ReceitaDA) AS ValorFinal,  
        SUM(ReceitaDA) - SUM(TotalPreFatura) AS ValorContestacao,  
        SUM(Parada) AS QtdParada,  
        SUM(VlParada) AS ValorParada  
,  
        CASE   
            WHEN SUM(TotalPreFatura) = 0 THEN 0.0   
            ELSE (SUM(ReceitaDA) - SUM(TotalPreFatura)) / SUM(TotalPreFatura)   
        END AS PercentualConstetacao,  
        lst_cd_lista  
    FROM  
        vw_validacao_financeiro AS a  
        INNER JOIN tb_clientes AS b  
            ON b.cli_id_logistics = a.IdTransportadora  
        INNER JOIN tb_lista AS c  
            ON cli_cd_codigo_cliente = lst_cd_cliente  
            AND lst_nm_lista = 'Clientes transportadoras'  
            AND lst_ds_label = 'Mercado Livre' 
    WHERE   
        cli_cd_codigo_cliente <> 7   
    GROUP BY  
        IdTransportadora,  
        Ano,  
        NomeMes,  
        Mes,  
        Quinzena,  
        NomeQuinzena,  
        lst_cd_lista  
) AS A   
LEFT JOIN (  
    SELECT   
        idtransportadora,  
        Ano,  
        Mes,  
        Quinzena,  
        SUM(CASE WHEN Descricao = 'Lost Packages Penalty' THEN Total ELSE 0 END) AS LostPackages,  
        SUM(CASE WHEN Descricao = 'Pnr Packages Penalty' THEN Total ELSE 0 END) AS Pnr,  
        SUM(CASE WHEN Descricao = 'Vehicle Daily Not Visited' THEN Total ELSE 0 END) AS EnderecoNaoVisitado  
    FROM   
        [dbo].[tb_fin_prefatura_descontos]  
      
    GROUP BY  
        idtransportadora,  
        Ano,  
        Mes,  
        Quinzena  
) AS B   
    ON A.IdTransportadora = B.idtransportadora  
    AND A.Ano = B.Ano  
    AND A.Mes = B.Mes  
    AND A.Quinzena = B.Quinzena;
GO
